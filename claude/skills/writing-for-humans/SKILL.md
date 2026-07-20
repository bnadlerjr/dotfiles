---
name: writing-for-humans
description: |
  Post-processing rewrite skill that transforms dense LLM-generated documentation
  into scannable, concise, human-readable text. Covers vocabulary tics, structural
  anti-patterns, BLUF rewriting, and word-level editing.

  Use when other skills need to produce user-facing prose: READMEs, guides,
  tutorials, or commit messages. Loaded by other skills as a post-processing
  step — not a standalone command.
---

# Writing for Humans

Rewrite LLM-generated documentation into text humans actually read.

## Scope

**Apply to:** User-facing prose — READMEs, guides, tutorials, commit messages, PR descriptions.

**Do not apply to:** Code comments, internal specs, handoffs, research documents, API docs generated from code, non-prose output (JSON, YAML, config files).

## Integration Pattern

Other skills load this as a post-processing step. The calling skill produces a draft, then a sub-agent rewrites it and gates the result through the automated validation loop (Phase 6) before returning. Use a sub-agent with Bash access (for example `general-purpose`) so the loop can run the detector.

```
Task tool:
  subagent_type: general-purpose
  description: "Rewrite draft for readability"
  prompt: |
    Read: ~/.claude/skills/writing-for-humans/SKILL.md

    Rewrite the following text using the writing-for-humans methodology,
    then run the Phase 6 validation loop until the text passes the gate
    (or the loop bails out). Return ONLY the final rewritten text —
    no meta-commentary, no explanations. If any hits remain after bailout,
    append a one-line note listing them.

    ---
    [paste draft here]
```

## Core Principles

Six rules that drive every rewrite decision:

1. **79% scan, 21% read** — Most readers scan. Front-load key information. Use headings, bold, and lists as scan anchors.
2. **7 plus/minus 2 chunks** — Group related items into 5-9 chunks. Split longer lists into categorized sub-lists.
3. **BLUF (Bottom Line Up Front)** — Lead with the conclusion, recommendation, or action. Context follows.
4. **Active voice** — The subject acts. "The server processes requests" not "Requests are processed by the server."
5. **Show, don't tell** — Replace claims with evidence. "Reduces build time by 40%" not "Significantly improves performance."
6. **Concrete over abstract** — Use specific numbers, names, and examples instead of vague qualifiers.

## Quick Diagnostic Checklist

Scan the text for these issues before rewriting. Mark the top 3 to fix first.

### Vocabulary Tics
- [ ] Banned words present (see list below)
- [ ] Hedging language: "might", "could potentially", "it seems"
- [ ] Corporate buzzwords: "synergy", "paradigm", "best-in-class"
- [ ] Unnecessary intensifiers: "very", "extremely", "incredibly"

### Structural Problems
- [ ] Context before answer (bury the lede)
- [ ] Paragraphs longer than 4 sentences
- [ ] Lists with more than 9 items (unsplit)
- [ ] Nesting deeper than 2 levels
- [ ] Generic headings: "Overview", "Introduction", "Background"

### Readability
- [ ] Sentences longer than 25 words
- [ ] Passive voice in more than 20% of sentences
- [ ] Nominalizations: "make a decision" instead of "decide"
- [ ] Abstract claims without evidence

## Rewriting Workflow

### Phase 1: Diagnosis

Scan the text using the diagnostic checklist. Identify the top 3 issues by frequency and severity. These are your rewrite priorities.

Do not rewrite yet. Just diagnose.

### Phase 2: Structural Rewrite

Fix document-level problems:

1. **Apply BLUF** — Move the conclusion or action to the first sentence of each section. Cut or relocate the preamble.
2. **Front-load paragraphs** — The first sentence of each paragraph carries the point. Supporting detail follows.
3. **Break long lists** — Split lists with more than 7 items into categorized sub-lists with descriptive headings.
4. **Flatten nesting** — Reduce to 2 levels maximum. Promote deeply nested content to its own section.
5. **Replace generic headings** — "Overview" becomes "What this does". "Background" becomes a specific claim.

### Phase 3: Sentence-Level Rewrite

Edit sentence by sentence:

1. **Delete filler** — Remove words that add no meaning. See the word replacement table below.
2. **Activate voice** — Convert passive to active. Find the actor and make them the subject.
3. **Replace weak verbs** — "utilize" becomes "use". "facilitate" becomes "help". See replacement table.
4. **Reverse nominalizations** — "make an improvement" becomes "improve". "perform an analysis" becomes "analyze".
5. **Split long sentences** — Break sentences over 25 words at natural clause boundaries.
6. **Cut hedging** — Remove "basically", "essentially", "it's worth noting that". State the fact directly.

### Phase 4: Formatting

Apply visual hierarchy:

1. **Use markdown** — Bold for key terms on first use. Code formatting for technical names.
2. **Add headings** — One heading per scroll-height (~300 words). Make headings specific and actionable.
3. **Use whitespace** — Separate sections with blank lines. Short paragraphs (2-4 sentences max).
4. **Prefer tables for comparisons** — Side-by-side data reads faster than prose descriptions.

### Phase 5: Validation

Check the rewrite against these criteria:

- [ ] 30-50% shorter than original (word count)
- [ ] Passes skim test: read only headings and bold text — do you get the gist?
- [ ] No banned words or phrases remain
- [ ] 80%+ of sentences use active voice
- [ ] No paragraph exceeds 4 sentences
- [ ] No list exceeds 9 items without categorization
- [ ] Every heading is specific (not "Overview" or "Details")

Phase 5 is the human-judgment pass. Phase 6 adds an automated gate on top of it.

### Phase 6: Automated Validation

Gate the rewrite through `scripts/validate.sh` and loop on its output until the text passes. See [Automated Validation Loop](#automated-validation-loop) for the procedure.

## Automated Validation Loop

Run this after Phase 5, inside the rewrite sub-agent (it has Bash). Validation runs fully locally — no text leaves the machine.

`scripts/validate.sh <file>` (in this skill's directory) gates a draft against two local detectors — `ai-slop` and `ai-writing-detector` — combined with OR: it fails if either flags the text, and skips only when neither is available. It reports one of three states:

| Exit | Meaning | Action |
|------|---------|--------|
| 0 | Passes the gate | Done — return the text |
| 1 | Still reads as AI-generated | stdout lists the specific issues — fix those spans, rerun |
| 2 | Cannot validate — no detector available, bad input, or detector error | Skip; keep the Phase 5 result and note validation did not run |

### Prerequisites

Both detectors are optional and checked at run time: if one is absent the gate uses the other, and if both are absent validation is skipped — never failed. Install each manually, once — the script never auto-installs.

- **ai-slop** — put it on your `PATH` (see the tool's own docs).
- **ai-writing-detector** ([pertrai1/ai-writing-detector](https://github.com/pertrai1/ai-writing-detector)) — not published as a package, so build from source pinned to a reviewed commit SHA, then point the script at the built CLI:

  ```bash
  git clone https://github.com/pertrai1/ai-writing-detector
  cd ai-writing-detector && git checkout <reviewed-sha>
  npm install && npm run build
  export AI_WRITING_DETECTOR_CLI="$PWD/dist/cli.js"
  ```

  It runs fully locally with no network calls. Pin to a SHA, not `main`, and review the build before running it.

### The loop

1. Write the current draft to a temp file under the session scratchpad.
2. Run `scripts/validate.sh <tmpfile>` and capture stdout and the exit code.
3. Exit 0 → done. Return the text.
4. Exit 1 → read the reported issues, edit exactly those spans using the replacement guidance above, rewrite the temp file, and repeat.
5. Exit 2 → skip the loop, keep the Phase 5 result, and note validation did not run. Never fail the rewrite because the detector could not run.

Tune strictness with the `SLOP_THRESHOLD` and `AI_WRITING_THRESHOLD` env vars documented in the script header.

### Bailout

Stop and return the best version — never distort meaning to satisfy the detector:

- Cap the loop at 5 iterations.
- Stop early if the issues stop shrinking between iterations.
- Stop if the only remaining issues are tokens the text must keep (a real em-dash, a required emoji, a quoted AI phrase).

On bailout, report the residual issues instead of forcing more edits. The detector is a guide, not an oracle — human meaning wins over a green score.

### Governance

- **Treat scores as guidance.** The gate flags likely tells; it does not certify quality. Human judgment overrides it.

## Banned Words and Phrases

Remove or replace every instance:

### Single Words
- delve
- leverage (use "use" or "apply")
- robust (use specific quality: "tested", "validated", "fault-tolerant")
- comprehensive (use "complete" or "full", or cut entirely)
- streamline (use "simplify" or "speed up")
- utilize (use "use")
- facilitate (use "help" or "enable")
- moreover
- furthermore
- nonetheless
- paradigm
- synergy
- optimize (unless discussing actual performance optimization)
- empower
- foster
- holistic
- innovative
- seamless (use "smooth" or describe the actual behavior)

### Phrases
- "It's important to note that" — delete entirely, state the fact
- "In order to" — replace with "To"
- "At the end of the day" — delete
- "It goes without saying" — delete (then why say it?)
- "As a matter of fact" — delete
- "For all intents and purposes" — delete
- "In terms of" — replace with "for" or restructure
- "With regard to" — replace with "about" or "for"
- "On the other hand" — replace with "But" or "However"
- "Due to the fact that" — replace with "Because"
- "In the event that" — replace with "If"
- "Prior to" — replace with "Before"
- "Subsequent to" — replace with "After"
- "A wide range of" — replace with "many" or a specific number
- "In a timely manner" — replace with "quickly" or a specific timeframe
- "Take into consideration" — replace with "consider"
- "Is able to" — replace with "can"
- "Has the ability to" — replace with "can"

## Word Replacement Table

| Replace | With |
|---------|------|
| utilize | use |
| facilitate | help |
| implement | build, add, set up |
| functionality | feature |
| in order to | to |
| due to the fact that | because |
| at this point in time | now |
| a large number of | many |
| in the event that | if |
| prior to | before |
| subsequent to | after |
| in terms of | for, about |
| with regard to | about |
| has the ability to | can |
| is able to | can |
| take into consideration | consider |
| make a determination | decide |
| give consideration to | consider |
| provide assistance | help |
| conduct an investigation | investigate |
| perform an analysis | analyze |
| come to a conclusion | conclude |

## Before/After Examples

### Example 1: Feature Description

**Before (87 words):**

> It's important to note that this comprehensive authentication module has been designed to facilitate secure user access management across a wide range of application contexts. The module utilizes industry-standard JWT tokens in order to provide robust session handling. Moreover, it leverages Redis for session storage, which enables the system to seamlessly handle distributed deployments. The implementation provides the ability to configure token expiry, refresh intervals, and role-based access controls in a highly flexible manner.

**After (32 words — 63% reduction):**

> This auth module manages user sessions with JWT tokens stored in Redis. Configure token expiry, refresh intervals, and role-based access per environment. Works across distributed deployments.

**What changed:**
- BLUF: led with what it does, not that it's "important to note"
- Cut "comprehensive", "robust", "seamlessly", "in order to", "facilitates"
- Replaced "utilizes" with implicit usage, "provides the ability to" with direct verb
- Removed "moreover" transition — unnecessary between related facts

### Example 2: Setup Instructions

**Before (94 words):**

> In order to get started with the development environment setup, you'll first need to ensure that you have Docker installed on your machine. It's worth mentioning that the minimum required version is 20.10 or later. Subsequently, you should proceed to clone the repository and navigate to the project directory. At that point, you'll want to run the initialization script, which will take care of pulling the necessary images, setting up the database, and configuring the environment variables. Once this process has been completed, you should be able to access the application.

**After (38 words — 60% reduction):**

> **Prerequisites:** Docker 20.10+
>
> ```bash
> git clone <repo-url> && cd project
> ./scripts/init.sh
> ```
>
> `init.sh` pulls images, creates the database, and sets environment variables. The app is available at `localhost:3000` after setup.

**What changed:**
- BLUF: prerequisites first, then the commands
- Replaced prose with a code block — readers copy commands, not sentences
- Cut "in order to", "it's worth mentioning", "subsequently", "at that point"
- Replaced "once this process has been completed" with specific result

## Output Format

Return **only** the rewritten text. Do not include:
- Explanations of what you changed
- Before/after comparisons
- Meta-commentary about the rewrite process
- Confidence scores or caveats

If the original text is already concise and scannable, return it unchanged with no comment.

## Reference Files

For deeper guidance on specific topics:

| Topic | Reference | When to Load |
|-------|-----------|--------------|
| LLM anti-patterns | [llm-anti-patterns.md](references/llm-anti-patterns.md) | Diagnosing why text reads like AI output |
| Conciseness techniques | [conciseness-techniques.md](references/conciseness-techniques.md) | Editing for maximum word count reduction |

Load references only when the quick diagnostic reveals issues in that area. Most rewrites need only this SKILL.md.

## Success Criteria

A successful rewrite meets all of these:

- **30-50% word reduction** from the original
- **Passes skim test** — headings and bold text convey the full message
- **Zero LLM tics** — no banned words, no filler phrases
- **80%+ active voice** — measured by sentence count
- **Flesch-Kincaid grade 8-10** — accessible to a broad technical audience
- **Every claim is concrete** — numbers, names, or examples instead of adjectives
- **Passes the validation gate** — `scripts/validate.sh` exits 0 (or a clean bailout that reports the residual, intentional issues)
