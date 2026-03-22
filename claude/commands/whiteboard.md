---
description: Design-first collaboration — whiteboard before keyboard
argument-hint: <feature or task description>
---

# Whiteboard

Collaborative design session that walks through progressive levels of
alignment before any code is written. Produces a design artifact.
Based on "whiteboard before keyboard" from Martin Fowler's
design-first collaboration.

## Variables

TASK: $ARGUMENTS
ARTIFACT_DIR: $CLAUDE_DOCS_ROOT/designs/

## Instructions

- If TASK is empty, STOP immediately and ask the user what they want to design.
- IMPORTANT: No code at any point. Not pseudocode, not "rough sketches."
  This is a design session only.
- Each level is a checkpoint. Present your thinking, then wait for explicit
  approval before advancing. If the user pushes back, revise at that level.
- Keep each level focused on its concern only — don't leak implementation
  details into Capabilities, don't discuss data flow in Components.
- Match depth to complexity. Not every task needs all four levels.

## Workflow

### Determine Starting Level

Assess TASK complexity and start at the appropriate level:

- **Trivial** (single function, clear interface) → skip to Contracts
- **Single component** (one module, clear boundaries) → start at Components
- **Multi-component feature** → start at Capabilities
- **System integration or cross-cutting concern** → start at Capabilities
  with deeper Interactions work

Tell the user which level you're starting at and why. If they disagree,
adjust.

### Level 1: Capabilities

Define what the system needs to do without saying how.

- Core requirements and scope boundaries
- What's in, what's explicitly out
- User-facing behavior and constraints

Present a concise summary. Wait for approval.

### Level 2: Components

Identify the building blocks.

- Major abstractions, services, modules
- Responsibilities of each component
- IMPORTANT: Only introduce components that earn their existence. Flag
  anything that wraps an existing library without adding value.

Present the component list with one-line responsibilities. Wait for approval.

### Level 3: Interactions

Map how components communicate.

- Data flow between components
- API calls, events, message passing
- Sequence of operations for key scenarios

Present interaction descriptions or simple flow diagrams. Wait for approval.

### Level 4: Contracts

Establish the interfaces.

- Function signatures, type definitions, schemas
- Input/output shapes for each boundary
- Error cases and edge conditions

Present contracts in the project's language conventions. Wait for approval.

### Save Artifact

After the final approved level, save the design document to ARTIFACT_DIR
following the artifact management guidelines. The artifact should capture
all approved levels as a design reference.

## Report

Provide the artifact file path and a one-line summary of what was designed.
