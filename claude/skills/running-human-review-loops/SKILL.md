---
name: running-human-review-loops
description: Chooses and runs a human review channel for workflows that need decisions, draft feedback, revision, or approval.
---

# Running human review loops

Choose one review transport before the first user interaction, then keep the whole workflow on it. The calling workflow owns the subject matter, draft format, decision choices, and meaning of approval. This skill owns transport selection, continuity, waiting, and feedback classification.

## Select the transport

1. If a `plannotator_inbox` tool is available, use the Inbox transport.
2. Otherwise, use the native transport.

Choose once per workflow run. Never fail, install software, or ask the user to configure Plannotator because the Inbox tool is absent. Do not switch transports halfway through a run unless the selected transport stops working and the user agrees to continue in chat.

## Shared rules

- Ask only for decisions the workflow cannot make itself.
- Every decision includes 1-3 sentences of context, naturally ordered choices, and a committed recommendation with its reason.
- Keep one review stream per workflow run.
- After asking a blocking question or presenting a draft for review, end the turn. Do not poll or duplicate the request on another transport.
- Treat explicit approval as approval, explicit stopping as stopping, and all actionable comments or annotations as revision feedback.
- If approval includes feedback that changes the approved artifact, revise and request approval again.

## Inbox transport

### Start and continue the thread

- The first `plannotator_inbox` call uses `action: "send_message"`, a short `subject`, and neither `thread` nor `reply_to`. Capture its returned `thread_id` and `message_id`.
- Keep every question, draft, review control, revision, closure, and final artifact in that thread.
- Before the user replies, set `reply_to` to the previous send's `message_id`. When an Inbox wake arrives, set `reply_to` to the reply id in its first line.
- If context was compacted or resumed without the thread state, call `plannotator_inbox` with `action: "read_thread"` before sending.

### Ask decisions

Use one block per decision:

```markdown
:::question
<decision>

<1-3 sentences of context and reasoning>

- [ ] <choice in natural order>
- [ ] <choice in natural order>

Recommended: <choice>
:::
```

Use `:::question-text` for free text. Keep the recommendation on its own line, never in a choice label. Add `Stopped:` and `Stakes:` only when the workflow truly cannot continue without the answer.

### Review drafts

1. Send the draft as the entire message body when the caller requires an artifact-only draft.
2. Send the caller's review choices as a separate question message replying to the draft.
3. End the turn.
4. On reply, read the answer together with message text, selected-text feedback, and attachment annotations.

Leave skipped or unanswered questions open. Do not ask them again in chat or another Inbox message.

## Native transport

- Use the host's native question tool when available. Otherwise ask directly in chat.
- Keep decisions in the current conversation. Preserve the same context, choice order, recommendation, and blocking behavior as the Inbox form.
- Present artifact-only drafts as the entire assistant message and end the turn. Interpret the user's next response: explicit approval approves, explicit stopping stops, and any other actionable response requests revision.
- When artifact-only output is not required, the host's native question tool may carry the caller's approve, revise, or stop choices after the draft.
- Native chat has no selected-text annotations. Apply all written feedback, then present the full revised draft again.

## Return control to the caller

The caller decides what each result means:

- **Decision answered:** continue with the selected choice.
- **Revision requested:** apply feedback and present the complete revised artifact.
- **Approved:** run the caller's approval cleanup and deliver the final artifact.
- **Stopped:** close the workflow briefly and do no further work.
- **No answer:** wait. Do not infer consent.
