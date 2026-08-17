# Top-level Behavior

## Diagram

```mermaid
flowchart TD
    Start(["Automation run finishes"]) --> Status{Terminal status?}

    Status -->|":skipped<br/>(condition or action)"| Audit["Run recorded in Audit Log<br/>+ telemetry — unchanged"]
    Status -->|":completed"| Audit
    Status -->|":in_progress<br/>(uncaught exception)"| Audit
    Status -->|":failed"| MarkFailed["handle_workflow_failure/4<br/>→ mark_as_failed/2"]

    MarkFailed --> Audit
    MarkFailed --> Notifier["AutomationFailureNotifier.notify/2<br/>fire-and-forget, spec'd :: :ok"]

    subgraph Notify ["Notifier (rescues; never alters run outcome)"]
        direction TB
        Notifier --> Flag{"Market has<br/>DEV_in_app_notifications?"}
        Flag -->|no| Quiet(["Return :ok — no notification"])
        Flag -->|yes| Recip["Recipient = workflow.updated_by_id"]

        Recip --> Active{"filter_active_user_ids<br/>exclude_protected: true<br/>→ any recipient?"}
        Active -->|"no — deactivated<br/>or AUTO account"| Quiet
        Active -->|yes| Dedup{"Already notified this<br/>recipient about this<br/>automation today?<br/>(market-local day)"}

        Dedup -->|"yes — repeat<br/>failure same day"| Quiet
        Dedup -->|"no — first failure<br/>of the day"| Create["Notifications.create_notification/3<br/>:automation_failure<br/>title / body naming the automation<br/>context: workflowId, workflowRunId"]

        Create --> Rows[("notifications row<br/>+ notification_recipients row<br/>viewed_at: nil")]
        Rows --> Broadcast["Post-commit dual broadcast<br/>per recipient"]
    end

    Broadcast --> PubSub["Phoenix PubSub<br/>Instinct.Notifications:user:ID"]
    Broadcast --> Absinthe["Absinthe subscription<br/>notificationAdded:user:ID"]

    Absinthe --> Toast{"Recipient online<br/>in Instinct?"}
    Toast -->|yes| ToastUI["Toast naming the failed<br/>automation (toast+list default)"]
    Toast -->|no| NoToast["No toast — entry still waits"]

    Rows --> Page["Unread entry on<br/>Notifications page / bell<br/>no click-through action"]

    ToastUI --> Investigate(["Creator investigates<br/>in the Audit Log"])
    NoToast --> Page
    Page --> Investigate
```

## Summary

Every automation run still lands in the Audit Log and telemetry unchanged; only a `:failed` terminal transition branches into the new `AutomationFailureNotifier`. The notifier is a fire-and-forget side path with three sequential gates — the market's `DEV_in_app_notifications` flag, an active/non-protected recipient (`workflow.updated_by_id`), and a market-local-day dedup query keyed on `(automation, recipient, day)`. Passing all three creates one `:automation_failure` notification, which fans out post-commit to a toast (if the recipient is online) and a persistent unread entry naming the automation. Any gate failing returns `:ok` silently, and the notifier can never alter the run's outcome.
