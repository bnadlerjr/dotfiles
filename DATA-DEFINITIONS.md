# Data Definitions

## Notification Type Catalog (`chunky-kong/lib/instinct/notifications/notification_types.ex`)

```diff
   @types [
     :automation,
+    :automation_failure,
     :comm_log_email_failure,
     :direct_booking,
     Instinct.Integrations.ServicesSyncNotifier.event_type()
   ]
```

No `unreleased?/1` clause is added. Like `:integration_services_sync_completed`, the type is always *available*; only its emission is gated, on `DEV_in_app_notifications` inside the notifier.

## `Notification` Event Type Enum (`chunky-kong/lib/instinct/notifications/notification.ex`)

No source change. The enum is bound at compile time from the catalog, so its value set widens by one:

```elixir
# @event_types = NotificationTypes.list_all_types()
[
  :automation,
  :automation_failure,
  :comm_log_email_failure,
  :direct_booking,
  :integration_services_sync_completed
]

field(:event_type, Ecto.Enum, values: @event_types)
```

## Notification Payload for `:automation_failure`

No schema change — `Notification.Payload` already carries `title`, `body`, and a free-form `context` map. The type-specific shape produced by the notifier:

```elixir
%{
  title: "Automation failed",
  body: ~s(Your automation "Overdue Lab Follow-up" failed to run. Check the Audit Log for details.),
  context: %{
    "automationWorkflowId" => "123",
    "automationWorkflowRunId" => "456"
  }
}
```

Context keys are camelCase strings with stringified ids, matching every existing producer and the frontend's `coerceContextId`. `automationWorkflowRunId` is carried even though no click-through action exists yet (Design Decision 7/9), so a future deep link needs no backend change.

## Notifier Module Constants (`chunky-kong/lib/instinct/notifications/automation_failure_notifier.ex`)

```elixir
defmodule Instinct.Notifications.AutomationFailureNotifier do
  @flag "DEV_in_app_notifications"
  @event_type :automation_failure
  @title "Automation failed"
end
```

## Database Schema

No migration. `notifications`, `notification_recipients`, `automation_workflows`, and `automation_workflow_runs` are all unchanged:

- No guard table (Decision 2 — dedup is a query against existing notifications).
- No new column on `notifications`; the automation id lives inside the existing `payload` jsonb.
- No new index. The dedup predicate is bounded by one recipient and one market-local day, riding the existing `notification_recipients (user_id, viewed_at)` index with an unindexed jsonb match over that recipient's small day window (carried as an Open Risk).

The dedup predicate's shape, for reference — it reads existing structures only:

```elixir
# payload -> 'context' ->> 'automationWorkflowId' == to_string(workflow.id)
fragment("?->'context'->>'automationWorkflowId'", n.payload)
```

## GraphQL Enum (`chunky-kong/lib/instinct_api/schema/notifications/types.ex`)

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

`:notification` object, `:page_of_notifications`, and `:list_notifications_params` are unchanged — the new type flows through `payload: JSON!` and is filterable via the existing `event_types` field with no signature change.

## Generated Frontend Enum (`kong-fu/src/archived/graphql/schema.ts`)

Regenerated from the Absinthe schema, not hand-edited:

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

## Frontend Payload Context Type (`kong-fu/src/features/notifications/utils/notificationContent.ts`)

New exported type alongside `DirectBookingContext`, `IntegrationServicesSyncContext`, and `CommLogEmailFailureContext`:

```ts
/**
 * The fields an AUTOMATION_FAILURE payload's `context` carries. Neither field is
 * needed to render the notification — the body names the automation — so this
 * exists for the eventual "View in Audit Log" action.
 */
export type AutomationFailureContext = {
  automationWorkflowId: string;
  automationWorkflowRunId: string | null;
};
```

`NotificationPayload` itself is unchanged.

## Frontend Icon Map (`kong-fu/src/features/notifications/components/popover/NotificationFeedRow.tsx`)

```diff
 const TYPE_ICONS: Record<string, React.ComponentType<{sx?: object}>> = {
   [NotificationEventType.DirectBooking]: EventAvailableOutlined,
   [NotificationEventType.CommLogEmailFailure]: MailOutline,
   [NotificationEventType.IntegrationServicesSyncCompleted]: SyncOutlined,
+  [NotificationEventType.AutomationFailure]: ErrorOutline,
 };
```

`ErrorOutline` is a placeholder in the error family — the icon was not settled in the design interview. Without an entry the row still renders, falling back to `NotificationsNoneOutlined`.

## Frontend Delivery and Action Maps — Unchanged

Both are stated here because both are extension points a new event type would plausibly touch, and neither does:

```ts
// notificationDelivery.ts — stays empty; AUTOMATION_FAILURE resolves to the
// DEFAULT_DELIVERY of {mode: 'toast+list'}, which is exactly what the AC asks for.
const DELIVERY_BY_EVENT_TYPE: Record<string, Delivery> = {};

// notificationActions.tsx — AUTOMATION_FAILURE is deliberately absent (Decision 7:
// no click-through; the Audit Log is admin-gated and has no workflow URL param).
const ACTIONABLE_EVENT_TYPES: ReadonlySet<string> = new Set([
  NotificationEventType.CommLogEmailFailure,
  NotificationEventType.DirectBooking,
  NotificationEventType.IntegrationServicesSyncCompleted,
]);
```

## Data Handling Note

The new payload carries an automation name and two internal ids, and is addressed to one staff user id — no customer PII, no PHI, and nothing leaves Instinct-controlled systems. The recipient is filtered through `Staff.filter_active_user_ids/2` with `exclude_protected: true`, so deactivated accounts and the AUTO service account never receive a row. Access control is unchanged: `list_notifications/2`'s inner join on `user_id` and the per-user Absinthe subscription topic remain the only gates.
