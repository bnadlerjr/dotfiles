# Discovery Dimensions

Before drafting, gather these six dimensions. If the caller has supplied context (Jira/Linear ticket, codebase research, prior conversation), extract from that. If context is thin, ask the user in plain prose for what's missing — do NOT use `AskUserQuestion`. Discovery is open-ended; option chips force contrived choices.

## The Six Dimensions

| Dimension | What it answers | Example |
|---|---|---|
| **Actor** | Who experiences this need? Their role/situation in the domain. | "Pet owner whose pet has an overdue annual exam" |
| **Trigger** | What situation or event creates this need? | "Receives a reminder email" |
| **Outcome** | What result do they want? How will they know they succeeded? | "Books the appointment and receives confirmation" |
| **Constraints** | What business rules apply? | "Booking requires the pet's vaccination record to be current" |
| **Failure Modes** | What could go wrong? How should failures be handled? | "No appointments available within 30 days → offered the waitlist" |
| **Domain Terms** | Vocabulary the business uses. Terms that might be ambiguous. | "Appointment vs. Visit vs. Encounter — pick one and stay consistent" |

## Discovery Output Scratchpad

Once gathered:

```
**Understanding**: [1-2 sentence summary]
**Actor**: [Who] | **Trigger**: [What prompts this]
**Outcome**: [What they achieve] | **Constraints**: [Rules]
**Failure Modes**: [What could go wrong]
**Domain Terms**: [Key vocabulary]
```

## Asking About Missing Dimensions

When a dimension is unresolved, ask in prose:

- "Who is the actor here — a pet owner self-booking, or a clinic staff member booking on their behalf?"
- "What should happen if the requested time slot is unavailable?"
- "Is 'appointment' the canonical term, or is it called something else in this product?"

Avoid `AskUserQuestion` option chips for these — discovery is open-ended; option chips would force contrived choices and constrain the user's answer.

## What Goes Wrong When a Dimension is Missing

| Missing | Symptom in the resulting story |
|---|---|
| Actor | Vague Given clauses ("a user") with no situated role |
| Trigger | When clauses with no real cause; story floats free of context |
| Outcome | Vague Then clauses ("system handles appropriately") |
| Constraints | All scenarios look like the happy path; no boundaries |
| Failure Modes | Only happy path covered; QA gaps |
| Domain Terms | Technical jargon leaks in; stakeholders can't read it |

If a draft is ready and the quality checklist fails, the missing dimension is usually the diagnosis.
