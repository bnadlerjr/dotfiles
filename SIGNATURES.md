# Signatures

## Call Tree

### Backend — automation run failure path

```diff
  Automations.trigger_workflows/2
  └─ Execution.execute_workflow/3
     └─ Execution.process_steps/4
        └─ Execution.handle_workflow_failure/4
           ├─ Execution.format_failure_reason/1
           ├─ Execution.mark_as_failed/2
+          ├─ AutomationFailureNotifier.notify/2                    # fire-and-forget, :: :ok
+          │  ├─ Feature.current_market_has_flag?/1                 # gate 1: DEV_in_app_notifications
+          │  └─ AutomationFailureNotifier.do_notify/2
+          │     ├─ Staff.filter_active_user_ids/2                  # gate 2: active + non-protected
+          │     ├─ AutomationFailureNotifier.market_day_window/0
+          │     │  ├─ Utils.timezone/0                             # read once, threaded
+          │     │  ├─ Dates.start_of_day_localized/2
+          │     │  └─ Dates.end_of_day_localized/2
+          │     ├─ Notifications.recipient_notified?/5             # gate 3: per-day dedup
+          │     │  ├─ Notifications.join_recipients_for_user/2     # existing private composer
+          │     │  ├─ Notifications.filter_by_event_types/2        # existing private composer
+          │     │  ├─ Notifications.filter_by_context_value/3      # NEW private composer
+          │     │  └─ Notifications.filter_by_inserted_between/3   # NEW private composer
+          │     └─ AutomationFailureNotifier.emit/3
+          │        ├─ AutomationFailureNotifier.build_payload/2
+          │        └─ Notifications.create_notification/3
+          │           └─ Notifications.broadcast_notification_added/2
+          │              ├─ Instinct.broadcast/4                   # Phoenix PubSub
+          │              └─ Instinct.Utils.publish_subscription/2  # Absinthe
           └─ Execution.normalize_error/2
```

### Frontend — rendering an `AUTOMATION_FAILURE` notification

```diff
  useNotificationArrivals()                    # subscription → toast
  ├─ getDelivery(eventType)                    # unchanged; empty map → {mode: 'toast+list'}
  ├─ parseNotificationPayload(payload)
  ├─ notificationTitle(payload, formatEventType(eventType))
+ │  └─ formatEventType — NEW case → "Automation failed"
  ├─ notificationBody(payload, formatEventType(eventType))
  └─ notificationHasAction(eventType)          # unchanged; false → no action node

  NotificationFeedRow / NotificationsTable
  ├─ NotificationTypeAvatar(eventType)
+ │  └─ TYPE_ICONS — NEW entry → ErrorOutline
  ├─ formatEventType(eventType)
  └─ notificationBody(payload, label)

  NotificationsFilters
  └─ eventTypeDescription(eventType)
+    └─ NEW case → "An automation run failed."
```

## Signatures

### `chunky-kong/lib/instinct/notifications/notification_types.ex`

```diff
   @types [
     :automation,
+    :automation_failure,
     :comm_log_email_failure,
     :direct_booking,
     Instinct.Integrations.ServicesSyncNotifier.event_type()
   ]
```

No `unreleased?/1` clause. Like `:integration_services_sync_completed`, the type is always *available*; only emission is gated, inside the notifier.

### `chunky-kong/lib/instinct/notifications/automation_failure_notifier.ex` (new)

```elixir
defmodule Instinct.Notifications.AutomationFailureNotifier do
  @moduledoc """
  Emission of the `:automation_failure` in-app notification.

  Called from the `:failed` terminal transition in
  `Instinct.Automations.Execution`. Tells the person who last saved an
  automation that one of its runs failed, at most once per automation per
  recipient per market-local day, so a failure storm produces one heads-up
  rather than a flood.

  Three sequential gates: the market's `DEV_in_app_notifications` flag, an
  active non-protected recipient, and the per-day dedup lookup. Any gate
  failing is a silent `:ok`.

  Emission never raises into the caller — the run row is already committed by
  the time we run, so a notification failure is logged and swallowed and can
  never alter the run's outcome. The Audit Log is unaffected in every case.
  """

  alias Instinct.Automations.Workflow
  alias Instinct.Automations.WorkflowRun
  alias Instinct.Feature
  alias Instinct.Notifications
  alias Instinct.Staff
  alias Instinct.Utils
  alias Instinct.Utils.Dates

  require Logger

  @flag "DEV_in_app_notifications"
  @event_type :automation_failure
  @title "Automation failed"
  @context_key "automationWorkflowId"

  @doc """
  Emits an `:automation_failure` notification for a failed run of `workflow` to
  `workflow.updated_by_id` — the staff user who last saved the automation.

  Pre:
    * `workflow_run` has already been persisted as `:failed`; its `id` is
      committed and safe to carry in the payload context.
    * `workflow` carries `id`, `name`, and `updated_by_id` (all `null: false`);
      no association preload is required.

  Post:
    * Returns `:ok` unconditionally, including on every gate miss and on any
      raised exception. The caller discards the value.
    * On the happy path, exactly one `notifications` row and one
      `notification_recipients` row (`viewed_at: nil`) exist for this recipient,
      and both broadcasts have fired.
    * No-ops — no rows, no broadcast — when the market lacks
      `DEV_in_app_notifications`, when the recipient is deactivated or a
      protected (system) account, when the recipient was already notified about
      this automation earlier in the current market-local day, or when the run
      did not finish as `:failed`.
    * Never returns `{:error, _}` and never propagates a raise.

  Known race: two runs of the same automation failing concurrently can both
  observe "not yet notified" and both insert. Accepted — see Design Decision 2.
  """
  @spec notify(Workflow.t(), WorkflowRun.t()) :: :ok
  def notify(%Workflow{} = workflow, %WorkflowRun{status: :failed} = workflow_run)

  # Total by construction: a `:completed`, `:skipped`, or `:in_progress` run is
  # a silent no-op rather than a FunctionClauseError on a fire-and-forget path.
  @spec notify(Workflow.t(), WorkflowRun.t()) :: :ok
  def notify(_workflow, _workflow_run)

  # Gates 2 and 3, then emission. Split out so the flag check reads as the
  # single entry condition in `notify/2`.
  #
  # Pre: the flag is on.
  # Post: `:ok`; emits at most one notification.
  @spec do_notify(Workflow.t(), WorkflowRun.t()) :: :ok
  defp do_notify(workflow, workflow_run)

  # The automation's recipient, or `nil`.
  #
  # One call to `Staff.filter_active_user_ids/2` satisfies both the
  # deactivated-creator scenario and the protected-account exclusion.
  #
  # Post: `nil` when the user is inactive or protected; otherwise their id.
  @spec recipient_id(Workflow.t()) :: integer() | nil
  defp recipient_id(workflow)

  # The current market-local calendar day, expressed as a UTC half-open-ish
  # interval suitable for comparing against `notifications.inserted_at`.
  #
  # The timezone is read once and used for both bounds so the start and end
  # cannot disagree across a DST boundary mid-call.
  #
  # Post: `{start_utc, end_utc}` with `start_utc <= end_utc`.
  @spec market_day_window() :: {DateTime.t(), DateTime.t()}
  defp market_day_window()

  # Builds and inserts the notification.
  #
  # Pre: `user_id` is an active, non-protected staff user; no notification for
  #      this `(automation, recipient, day)` exists.
  # Post: `:ok`. An insert failure is logged at `:error` and swallowed.
  @spec emit(Workflow.t(), WorkflowRun.t(), integer()) :: :ok
  defp emit(workflow, workflow_run, user_id)

  # The `:automation_failure` payload.
  #
  # `workflow.name` rather than the revision's snapshot name, so the copy
  # matches what the recipient sees when they open the Audit Log. The run id is
  # carried even though no click-through action exists yet, so a future deep
  # link needs no backend change. `failure_reason` is deliberately excluded —
  # it is free-form text from an arbitrary error term.
  #
  # Post: `%{title: String.t(), body: String.t(), context: %{String.t() => String.t()}}`
  #       with camelCase string context keys and stringified ids.
  @spec build_payload(Workflow.t(), WorkflowRun.t()) :: map()
  defp build_payload(workflow, workflow_run)
end
```

### `chunky-kong/lib/instinct/notifications/notifications.ex`

New public predicate — the dedup lookup. Lives here because it composes the existing private query builders.

```elixir
@doc """
Returns true when `user_id` already has a notification of `event_type` whose
payload context carries `{context_key, context_value}`, inserted within the
inclusive `from`..`to` window.

Asks the question producers actually mean — "was this person already told?" —
rather than inferring it from the originating event, so a window in which the
notification was never created self-corrects instead of staying suppressed.

Pre:
  * `event_type` is a member of `NotificationTypes.list_all_types/0`.
  * `context_value` is the stringified form the producer wrote into
    `payload.context`; comparison is exact-match on text, not JSON-typed.
  * `from` and `to` bound a window narrow enough to keep the scan small — the
    `context` predicate is unindexed. Recipient filtering rides the existing
    `notification_recipients (user_id, viewed_at)` index.

Post:
  * Pure read; no side effects.
  * `false` for a user with no matching recipient row, including a user id that
    does not exist.
"""
@spec recipient_notified?(
        atom(),
        integer(),
        {String.t(), String.t()},
        DateTime.t(),
        DateTime.t()
      ) :: boolean()
def recipient_notified?(event_type, user_id, {context_key, context_value}, from, to)
    when is_atom(event_type) and is_integer(user_id) and
           is_binary(context_key) and is_binary(context_value)
```

New private composers, alongside `filter_by_viewed/2`, `filter_by_event_types/2`, and `filter_by_content/2`:

```diff
   defp filter_by_content(query, _), do: query

+  # Matches an exact value at `payload -> 'context' ->> key`. Mirrors the
+  # `fragment("?->>'body'", n.payload)` idiom in `filter_by_content/2`, one
+  # level deeper. Unindexed — callers must bound the query some other way.
+  defp filter_by_context_value(query, context_key, context_value)
+
+  # Inclusive `inserted_at` window. Callers pass UTC instants; a market-local
+  # calendar day is converted to UTC by the caller, not here.
+  defp filter_by_inserted_between(query, from, to)
+
   # Escape LIKE/ILIKE wildcards so user-supplied search terms are matched
   # literally rather than as patterns.
   defp escape_like(term) do
```

### `chunky-kong/lib/instinct/automations/execution.ex`

The only change to the automations tree: one fire-and-forget call, after the transition commits and before the telemetry metadata is assembled.

```diff
   defp handle_workflow_failure(workflow, workflow_run, subject, reason) do
     formatted_reason = format_failure_reason(reason)
     {:ok, workflow_run} = mark_as_failed(workflow_run, formatted_reason)

+    # Fire-and-forget: spec'd `:: :ok`, rescues internally, so a notification
+    # failure can never alter the run's outcome or the telemetry metadata.
+    AutomationFailureNotifier.notify(workflow, workflow_run)
+
     error = normalize_error(reason, workflow_run)

     {{:error, error},
      %{
        result: :error,
        subject: subject,
        workflow_run: workflow_run,
        workflow: workflow,
        error: error
      }}
   end
```

```diff
   alias Instinct.Automations.WorkflowRun
+  alias Instinct.Notifications.AutomationFailureNotifier
```

`handle_workflow_success/3`, `handle_workflow_skipped/4`, and `create_skipped_workflow_run/3` are unchanged — skipped and completed runs have no notification path at all.

### `chunky-kong/lib/instinct_api/schema/notifications/types.ex`

```diff
   @desc "The category of a notification"
   enum :notification_event_type do
     value(:automation, description: "Automation workflow notification action")
+    value(:automation_failure, description: "An automation run failed")
     value(:comm_log_email_failure, description: "Comm log outbound email failed to send")
     value(:direct_booking, description: "Pet Portal direct booking")
     value(:integration_services_sync_completed, description: "Integration services sync finished")
   end
```

`:notification`, `:page_of_notifications`, and `:list_notifications_params` are unchanged — the new type flows through `payload: JSON!` and is filterable via the existing `event_types` field.

### `kong-fu/src/archived/graphql/schema.ts` (generated — regenerate, do not hand-edit)

```diff
 /** The category of a notification */
 export enum NotificationEventType {
   /** Automation workflow notification action */
   Automation = 'AUTOMATION',
+  /** An automation run failed */
+  AutomationFailure = 'AUTOMATION_FAILURE',
   /** Comm log outbound email failed to send */
   CommLogEmailFailure = 'COMM_LOG_EMAIL_FAILURE',
   /** Pet Portal direct booking */
   DirectBooking = 'DIRECT_BOOKING',
   /** Integration services sync finished */
   IntegrationServicesSyncCompleted = 'INTEGRATION_SERVICES_SYNC_COMPLETED'
 }
```

### `kong-fu/src/features/notifications/utils/notificationContent.ts`

```diff
 export function formatEventType(eventType: string): string {
   switch (eventType) {
+    case NotificationEventType.AutomationFailure:
+      return t('Automation failed');
     case NotificationEventType.CommLogEmailFailure:
       return t('Comm Log email failed');
```

```diff
 export function eventTypeDescription(eventType: string): string {
   switch (eventType) {
+    case NotificationEventType.AutomationFailure:
+      return t('An automation run failed.');
     case NotificationEventType.CommLogEmailFailure:
       return t('A comm log email failed to send.');
```

Both labels are fallbacks only — `notificationTitle`/`notificationBody` prefer the payload's own `title`/`body`, which the notifier always supplies. `eventTypeDescription` is what the Type filter renders.

New exported context type, alongside `DirectBookingContext`, `IntegrationServicesSyncContext`, and `CommLogEmailFailureContext`:

```ts
/**
 * The fields an AUTOMATION_FAILURE payload's `context` carries. Neither field
 * is needed to render the notification — the body names the automation — so
 * this exists for the eventual "View in Audit Log" action.
 *
 * Deliberately has no `parse…Context` companion: the other three exist to
 * decide whether an action can render, and AUTOMATION_FAILURE has no action
 * (Design Decision 7). Add one alongside the action, not before it.
 */
export type AutomationFailureContext = {
  automationWorkflowId: string;
  automationWorkflowRunId: string | null;
};
```

`NotificationPayload`, `parseNotificationPayload`, `coerceContextId`, `notificationBody`, and `notificationTitle` are unchanged.

### `kong-fu/src/features/notifications/components/popover/NotificationFeedRow.tsx`

```diff
+import ErrorOutline from '@mui/icons-material/ErrorOutline';
```

```diff
 const TYPE_ICONS: Record<string, React.ComponentType<{sx?: object}>> = {
   [NotificationEventType.DirectBooking]: EventAvailableOutlined,
   [NotificationEventType.CommLogEmailFailure]: MailOutline,
   [NotificationEventType.IntegrationServicesSyncCompleted]: SyncOutlined,
+  [NotificationEventType.AutomationFailure]: ErrorOutline,
 };
```

`ErrorOutline` is a placeholder in the error family — the icon was never settled in the design interview. Without an entry the row still renders via the `NotificationsNoneOutlined` fallback in `NotificationTypeAvatar`.

### Unchanged extension points, stated because a new event type would plausibly touch them

```ts
// notificationDelivery.ts — stays empty. AUTOMATION_FAILURE resolves to
// DEFAULT_DELIVERY of {mode: 'toast+list'}, which is exactly what the AC asks
// for: a toast while working, plus a persistent list entry.
const DELIVERY_BY_EVENT_TYPE: Record<string, Delivery> = {};

// notificationActions.tsx — AUTOMATION_FAILURE is deliberately absent. The
// Audit Log is behind `admin_automations` and has no workflow URL param, so
// `useNotificationAction` hits `default: return null` and the row renders
// without an action button.
const ACTIONABLE_EVENT_TYPES: ReadonlySet<string> = new Set([
  NotificationEventType.CommLogEmailFailure,
  NotificationEventType.DirectBooking,
  NotificationEventType.IntegrationServicesSyncCompleted,
]);
```

No migration, no new table, no new column, no new index — `notifications`, `notification_recipients`, `automation_workflows`, and `automation_workflow_runs` are all unchanged.
