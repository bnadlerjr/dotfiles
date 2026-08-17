## Story
### Description
When an automation breaks, its failures currently sit unseen in the Audit Log until someone happens to look — the person who built it finds out weeks later, after the automation has silently stopped delivering value. The creator needs to hear about the first failure within a day: an alert while they're working (a toast) and a persistent entry on their Notifications page naming the failed automation, so they can investigate in the Audit Log. Repeat failures the same day stay quiet — one heads-up per automation per day is enough to prompt investigation without flooding anyone during a failure storm.

### Context
Applies when an automation run finishes as Failed — never Skipped — at a practice with in-app notifications enabled, and the automation was created by a person whose account is still active. Notification content names the failed automation; diagnosing the failure remains an Audit Log activity.

### Acceptance Criteria

Scenario: First failure of the day notifies the creator
Given Dr. Reyes created the automation "Overdue Lab Follow-up"
And that automation has not failed yet today
When a run of "Overdue Lab Follow-up" fails
Then Dr. Reyes sees a toast naming "Overdue Lab Follow-up" as failed if she is using Instinct at that moment
And an unread entry naming "Overdue Lab Follow-up" as failed appears on her Notifications page

Scenario: Repeat failures the same day are suppressed
Given Dr. Reyes was already notified today that "Overdue Lab Follow-up" failed
When another run of "Overdue Lab Follow-up" fails later the same day
Then Dr. Reyes receives no additional notification
And her Notifications page still shows only the one entry for today's failures of that automation

Scenario: A failure on a later day notifies again
Given Dr. Reyes was notified yesterday that "Overdue Lab Follow-up" failed
When a run of "Overdue Lab Follow-up" fails today
Then Dr. Reyes is notified of today's failure

Scenario: Each failing automation notifies independently
Given Dr. Reyes created both "Overdue Lab Follow-up" and "Discharge Instructions"
And she was already notified today that "Overdue Lab Follow-up" failed
When a run of "Discharge Instructions" fails the same day
Then Dr. Reyes is notified that "Discharge Instructions" failed

Scenario: Skipped runs never notify
Given Dr. Reyes created the automation "Overdue Lab Follow-up"
When a run of "Overdue Lab Follow-up" is skipped rather than failed
Then Dr. Reyes receives no notification

Scenario: Deactivated creator is skipped silently
Given the automation "Overdue Lab Follow-up" was created by a staff member whose account has since been deactivated
When a run of "Overdue Lab Follow-up" fails
Then no one is notified of the failure
And the failure is still recorded in the Audit Log as usual

Scenario: System-created automations notify no one
Given the automation "New Patient Intake" was created by the system rather than a person
When a run of "New Patient Intake" fails
Then no one is notified of the failure
And the failure is still recorded in the Audit Log as usual

Scenario: Practices without in-app notifications receive nothing
Given a practice does not have in-app notifications enabled
When any automation fails at that practice
Then no failure notification is delivered to anyone at that practice

## Prior Research
@/Users/bobnadler/Dropbox/vimwiki/claude-artifacts/POPS-1861-automation-creator-told-automation-fails/POPS-1861-research.md

## High-level Design Decisions
@/Users/bobnadler/Dropbox/vimwiki/claude-artifacts/POPS-1861-automation-creator-told-automation-fails/POPS-1861-design.md
