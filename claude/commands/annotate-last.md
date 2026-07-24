---
name: annotate-last
description: Open Plannotator's annotation UI for the last assistant message in this session and then respond to the returned annotations.
argument-hint: "[--gate]"
allowed-tools: Bash(plannotator:*), Read, Edit, Write
---

# Plannotator Annotate Last

## Message annotations

!`plannotator annotate-last $ARGUMENTS`

## Your task

The output above will be one of:

1. The exact text `The user approved.`, OR a JSON object with `"decision": "approved"`. The user approved the message. Acknowledge with a single sentence ("Approved.") and stop. Do not begin any work.
2. Empty, OR a JSON object with `"decision": "dismissed"`. The user closed the session without requesting changes. Acknowledge with a single sentence ("Annotation session closed.") and stop. Do not begin any work.
3. Plaintext annotation feedback, OR a JSON object with `"decision": "annotated"` and a `"feedback"` field. Address the feedback. The user has reviewed the last message and provided specific annotations and comments.
