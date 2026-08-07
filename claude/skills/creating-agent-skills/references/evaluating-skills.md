# Evaluating Skills

Two different questions, tested two different ways:

1. **Does it trigger?** Does the agent reach for the skill on the right prompts, and
   leave it alone on the wrong ones? → [Trigger evals](#trigger-evals)
2. **Is the output good?** When it does load, does it produce better results than not
   loading it? → [Output evals](#output-evals)

A skill can fail either independently. Perfect instructions never reached are worth
nothing; reliable triggering into mediocre guidance is worse than nothing.

Sources: [optimizing-descriptions](https://agentskills.io/skill-creation/optimizing-descriptions),
[evaluating-skills](https://agentskills.io/skill-creation/evaluating-skills).

## Contents

- [Trigger evals](#trigger-evals) — build the query set, measure, avoid overfitting
- [Output evals](#output-evals) — test cases, run with and without, assertions, grading
- [The cheap version](#the-cheap-version) — the minimum worth doing for any skill

## Trigger evals

The `description` carries the entire burden. Under-specified, it never fires;
over-broad, it fires on everything.

### Build the query set

Around 20 realistic prompts, labelled:

```json
[
  { "query": "I've got a spreadsheet in ~/data/q4_results.xlsx with revenue in col C and expenses in col D — can you add a profit margin column and highlight anything under 10%?", "should_trigger": true },
  { "query": "whats the quickest way to convert this json file to yaml", "should_trigger": false }
]
```

8-10 that should trigger, 8-10 that should not.

**Should-trigger queries** vary along four axes: phrasing (formal, casual, typos),
explicitness (naming the domain vs. describing the need — "my boss wants a chart from
this data file"), detail (terse vs. context-heavy), and complexity (single-step vs. the
skill's task buried in a longer chain).

The most useful ones are those where the skill *would* help but the connection isn't
obvious. If the query already asks for exactly what the skill does, any description
triggers.

**Should-not-trigger queries** must be **near-misses**. Weak negatives teach nothing:

| Weak | Strong |
|---|---|
| "Write a fibonacci function" — no overlap, tests nothing | "I need to update the formulas in my Excel budget spreadsheet" — shares "spreadsheet", but needs Excel editing, not CSV analysis |
| "What's the weather today?" | "write a python script that reads a csv and uploads each row to postgres" — involves CSV, but the task is ETL, not analysis |

Include what real prompts contain: file paths, personal context ("my manager asked
me to…"), specific column and company names, casual language, occasional typos.

### Measure the trigger rate

Model behaviour is nondeterministic. Run each query ~3 times and compute the fraction of
runs where the skill loaded. A should-trigger query passes above a threshold (0.5 is a
reasonable default); a should-not-trigger query passes below it.

Detection depends on the client — look for whatever it exposes as execution logs or
tool-call history showing the skill was consulted.

### Avoid overfitting

Split the queries: **~60% train**, **~40% validation**, each with a proportional mix of
positives and negatives. Shuffle once and keep the split fixed.

Only train-set failures guide changes. The validation set exists to tell you whether the
change generalized.

### The loop

1. **Evaluate** on both sets. Train guides; validation judges.
2. **Identify train-set failures.** Which positives missed? Which negatives fired?
3. **Revise the description:**
   - Positives missing → too narrow. Broaden the scope, add context about when it helps.
   - Negatives firing → too broad. Add specificity about what the skill does *not* do,
     or clarify the boundary against adjacent capabilities.
   - **Do not add keywords lifted from failed queries** — that is overfitting. Find the
     general category those queries represent and address that.
   - Stuck after several iterations? Try a structurally different framing rather than
     more incremental tweaks.
   - Re-check the 1024-character limit. Descriptions grow during optimization.
4. **Repeat** until the train set passes or improvement stalls. Five iterations is
   usually enough.
5. **Select by validation pass rate** — not by recency. An earlier iteration often
   generalizes better than a later one that overfit.

Before and after:

```yaml
# Before
description: Process CSV files.

# After
description: >
  Analyze CSV and tabular data files — compute summary statistics,
  add derived columns, generate charts, and clean messy data. Use this
  skill when the user has a CSV, TSV, or Excel file and wants to
  explore, transform, or visualize the data, even if they don't
  explicitly mention "CSV" or "analysis."
```

More specific about *what*, broader about *when*.

If results won't improve, the problem may be the queries — too easy, too hard, or
mislabelled — rather than the description.

## Output evals

### Test cases

Three parts: a realistic prompt, a human-readable description of success, and any input
files. Store them in `evals/evals.json` inside the skill:

```json
{
  "skill_name": "csv-analyzer",
  "evals": [
    {
      "id": 1,
      "prompt": "I have a CSV of monthly sales data in data/sales_2025.csv. Can you find the top 3 months by revenue and make a bar chart?",
      "expected_output": "A bar chart image showing the top 3 months by revenue, with labeled axes and values.",
      "files": ["evals/files/sales_2025.csv"]
    }
  ]
}
```

**Start with 2-3 cases.** Don't over-invest before seeing the first results. Vary
phrasing and formality, cover at least one boundary condition, and use realistic
context — "process this data" tests nothing.

Don't write pass/fail checks yet. You usually don't know what "good" looks like until
the skill has run once.

### Run with and without

The core move: run each case **with the skill** and **without it** — or against the
previous version when improving an existing skill. Without a baseline you cannot tell
whether the skill helped or the model was going to do it anyway.

Each run needs a clean context so the agent follows only what `SKILL.md` says. Subagents
give this naturally; otherwise use a separate session per run.

```
csv-analyzer-workspace/
└── iteration-1/
    ├── eval-top-months-chart/
    │   ├── with_skill/{outputs/,timing.json,grading.json}
    │   └── without_skill/{outputs/,timing.json,grading.json}
    └── benchmark.json
```

Record tokens and duration per run — a skill that triples token usage for a small
quality gain is a different trade-off from one that is both better and cheaper.

### Assertions

Add them **after** seeing the first outputs.

| Good | Weak |
|---|---|
| "The output file is valid JSON" — programmatically verifiable | "The output is good" — ungradable |
| "The bar chart has labeled axes" — specific, observable | "The output uses exactly 'Total Revenue: $X'" — brittle; correct output with different wording fails |
| "The report includes at least 3 recommendations" — countable | |

Not everything needs an assertion. Writing style, visual design, whether the output
"feels right" — catch those in human review. Reserve assertions for objective checks.

### Grading

Record PASS/FAIL with **specific evidence** quoting the output, not an opinion:

```json
{
  "text": "Both axes are labeled",
  "passed": false,
  "evidence": "Y-axis is labeled 'Revenue ($)' but X-axis has no label"
}
```

**Require concrete evidence for a pass.** A section titled "Summary" containing one
vague sentence fails an assertion asking for a summary — the label is there, the
substance isn't.

**Review the assertions while grading.** Notice which are too easy, too hard, or
unverifiable, and fix them for the next iteration.

For comparing two versions, try **blind comparison**: show both outputs to a judge
without revealing which is which, and let it score holistic qualities on its own rubric.

### Read the patterns, not just the average

- **Assertions that pass in both configurations** — remove them. They inflate the
  with-skill rate without reflecting any skill value.
- **Assertions that fail in both** — the assertion is broken, the case is too hard, or
  it checks the wrong thing. Fix before the next iteration.
- **Assertions that pass with and fail without** — this is where the skill earns its
  keep. Work out *which* instruction made the difference.
- **Inconsistent results across runs** — either the eval is flaky or the instructions
  are ambiguous enough to be read differently each time. Add examples or tighten.
- **Time and token outliers** — read the transcript for the bottleneck.

### Human review

Assertions only check what you thought to check. A reviewer catches output that is
technically correct but misses the point. Record specific feedback per case — "the chart
is missing axis labels and the months are alphabetical instead of chronological", not
"looks bad". Empty feedback means it passed review.

### Iterating

Three signals: **failed assertions** (specific gaps), **human feedback** (broader
quality problems), **execution transcripts** (*why* it went wrong — an ignored
instruction is probably ambiguous; wasted steps mean instructions to simplify or
remove).

Hand all three plus the current `SKILL.md` to a model and ask for changes, with these
constraints:

- **Generalize.** Fix the underlying issue, don't patch the specific example.
- **Keep it lean.** If transcripts show wasted work, remove those instructions. If pass
  rates plateau while rules accumulate, the skill is over-constrained — try removing
  instructions and see whether results hold.
- **Explain the why.** "Do X because Y tends to cause Z" outperforms "ALWAYS do X".
- **Bundle repeated work.** If every run rewrote a similar helper, bundle it in
  `scripts/`. See [using-scripts.md](using-scripts.md).

Then rerun everything in a new `iteration-<N+1>/`, regrade, and review. Stop when
feedback is consistently empty or improvement stalls.

## The cheap version

Full evals are not always warranted. The minimum worth doing for any skill:

1. Run it on **one real task**, not a hypothetical one.
2. Run the same task **without** the skill and compare.
3. Read the transcript for wasted steps and ignored instructions.
4. Add any correction you had to make to a gotchas section — see
   [instruction-patterns.md](instruction-patterns.md).

If the agent handled the task equally well without the skill, the skill isn't earning
its context.
