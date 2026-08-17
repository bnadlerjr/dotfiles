# Test List

## Event type catalog

[ ] Given the notification type catalog, when `list_all_types/0` is called, then `:automation_failure` is included

[ ] Given no feature flags enabled, when `list_available_types/0` is called, then `:automation_failure` is still included

[ ] Given a notification changeset with `event_type: :automation_failure` and a valid payload, when it is inserted, then the row persists and reloads with `event_type: :automation_failure`

[ ] Given the GraphQL schema, when `availableNotificationTypes` is queried, then `AUTOMATION_FAILURE` is among the returned values

## Dedup predicate — `recipient_notified?/5`

[ ] Given a user with no notifications, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given a user id that does not exist, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given an `:automation_failure` notification for the user whose context `automationWorkflowId` matches and whose `inserted_at` is inside the window, when `recipient_notified?/5` is called, then it returns `true`

[ ] Given a matching notification addressed to a different user, when `recipient_notified?/5` is called for our user, then it returns `false`

[ ] Given a notification for the user with a different `event_type` but the same context value and window, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given a notification for the user with a different `automationWorkflowId`, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given a notification for the user whose payload context has no `automationWorkflowId` key, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given a matching notification inserted one microsecond before the window start, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given a matching notification inserted one microsecond after the window end, when `recipient_notified?/5` is called, then it returns `false`

[ ] Given a matching notification inserted exactly at the window start, when `recipient_notified?/5` is called, then it returns `true`

[ ] Given a matching notification inserted exactly at the window end, when `recipient_notified?/5` is called, then it returns `true`

[ ] Given a matching notification the user has already viewed, when `recipient_notified?/5` is called, then it still returns `true`

## Notifier — happy path

[ ] Given the market lacks `DEV_in_app_notifications`, when a failed run is notified, then `:ok` is returned and no notification rows exist

[ ] Given the flag is on and an automation "Overdue Lab Follow-up" last saved by an active Dr. Reyes, when a failed run is notified, then exactly one notification exists with `event_type: :automation_failure`

[ ] Given the same, when the notification is created, then its payload title is "Automation failed" and its body names "Overdue Lab Follow-up"

[ ] Given the same, when the notification is created, then its payload context holds `"automationWorkflowId"` and `"automationWorkflowRunId"` as strings matching the workflow and run ids

[ ] Given the same, when the notification is created, then exactly one recipient row exists, for Dr. Reyes, with `viewed_at: nil`

[ ] Given the same, when the notification is created, then the notifier returns `:ok`

[ ] Given the failure reason is a long free-form error string, when the notification is created, then the body does not contain the failure reason

[ ] Given Dr. Reyes is subscribed to her notification topic, when a failed run is notified, then she receives a `{Notifications, [:notification, :added], %Notification{}}` message

[ ] Given a second staff user is subscribed to their own topic, when a failed run of Dr. Reyes' automation is notified, then that user receives no message

## Notifier — gates and suppression

[ ] Given a run with status `:skipped`, when the notifier is called with it, then `:ok` is returned and no notification exists

[ ] Given a run with status `:completed`, when the notifier is called with it, then `:ok` is returned and no notification exists

[ ] Given a run with status `:in_progress`, when the notifier is called with it, then `:ok` is returned and no notification exists

[ ] Given the automation was last saved by a deactivated staff user, when a failed run is notified, then no notification exists and `:ok` is returned

[ ] Given the automation was last saved by a protected service account, when a failed run is notified, then no notification exists and `:ok` is returned

[ ] Given Dr. Reyes was already notified today about "Overdue Lab Follow-up", when another run of it fails today, then no second notification is created and she still has exactly one entry for that automation today

[ ] Given Dr. Reyes was notified about "Overdue Lab Follow-up" and that notification's `inserted_at` is pinned to yesterday market-local, when a run fails today, then a second notification is created

[ ] Given Dr. Reyes was already notified today about "Overdue Lab Follow-up", when a run of "Discharge Instructions" fails the same day, then she is notified naming "Discharge Instructions"

[ ] Given a prior notification for the same automation today addressed to a different staff user, when a run fails and the current recipient has not been notified, then the current recipient is notified

[ ] Given Dr. Reyes was already notified today about "Overdue Lab Follow-up" and the automation is then saved by another active user, when a run fails later the same day, then the new recipient is notified and Dr. Reyes receives nothing further

[ ] Given a prior notification whose `inserted_at` falls on the previous market-local day but the same UTC day, when a run fails, then a new notification is created

[ ] Given a prior notification whose `inserted_at` falls on the same market-local day but a different UTC day, when a run fails, then no new notification is created

## Notifier — containment

[ ] Given `create_notification/3` returns an error, when a failed run is notified, then `:ok` is returned, no notification rows exist, and the error is logged

[ ] Given the recipient's user row is deleted between the active-user check and the insert, when a failed run is notified, then the raised error is rescued and `:ok` is returned

## Execution wiring

[ ] Given the flag is on and a workflow whose action fails, when the workflow is executed, then the run row is persisted as `:failed` and one `:automation_failure` notification exists

[ ] Given the same, when the workflow is executed, then `execute_workflow/3` still returns `{:error, error}` with the same error term as before

[ ] Given the notifier raises internally, when a workflow fails, then the run row is still `:failed` and the caller's return value is unchanged

[ ] Given the flag is on and a workflow whose conditions are not met, when it is triggered, then a `:skipped` run is recorded and no notification exists

[ ] Given the flag is on and a workflow whose action returns a skip, when it is executed, then the run is `:skipped` and no notification exists

[ ] Given the flag is on and a workflow that succeeds, when it is executed, then the run is `:completed` and no notification exists

[ ] Given the flag is on and a step that raises an uncaught exception, when the workflow is triggered, then the run remains `:in_progress` and no notification exists

[ ] Given a workflow with no active revision, when it is triggered, then the run is `:failed` and a notification is created

[ ] Given a failed run, when the workflow is executed, then the `[:instinct, :automations, :run, :stop]` telemetry is emitted with the same failure metadata as before

## GraphQL surface

[ ] Given Dr. Reyes has an `:automation_failure` notification, when she queries `notifications`, then the entry is returned with `eventType: AUTOMATION_FAILURE` and its payload title, body, and context

[ ] Given Dr. Reyes has notifications of several types, when she queries `notifications` filtered to `eventTypes: [AUTOMATION_FAILURE]`, then only the automation failure entries are returned

## Frontend

[ ] Given the event type `AUTOMATION_FAILURE`, when `formatEventType` is called, then it returns "Automation failed"

[ ] Given the event type `AUTOMATION_FAILURE`, when `eventTypeDescription` is called, then it returns "An automation run failed."

[ ] Given an `AUTOMATION_FAILURE` payload with its own title and body, when `notificationTitle`/`notificationBody` are called, then the payload's values are used rather than the event-type label

[ ] Given the event type `AUTOMATION_FAILURE`, when `getDelivery` is called, then it returns `{mode: 'toast+list'}`

[ ] Given the event type `AUTOMATION_FAILURE`, when `notificationHasAction` is called, then it returns `false`

[ ] Given an `AUTOMATION_FAILURE` notification, when `useNotificationAction` is called, then it returns `null`

[ ] Given an `AUTOMATION_FAILURE` notification in the feed, when the row renders, then it shows the error-family icon rather than the default bell

[ ] Given the flag is on and a user is in the app, when an `AUTOMATION_FAILURE` notification arrives on the subscription, then a toast appears naming the failed automation

[ ] Given that toast, when it renders, then it shows no action button

[ ] Given an unread `AUTOMATION_FAILURE` notification, when the Notifications page loads, then the row renders as unread with the message naming the automation

[ ] Given an unread `AUTOMATION_FAILURE` row, when the user clicks it, then it is marked viewed and no navigation occurs

[ ] Given the `DEV_in_app_notifications` flag is off, when the app renders, then the notification bell and Notifications route are unavailable
