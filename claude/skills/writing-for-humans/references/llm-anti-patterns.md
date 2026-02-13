# LLM Anti-Patterns

Catalog of writing patterns that make text read like AI output. Each entry includes how to detect it, an example, and the fix.

## Vocabulary Tics

### Transition Overuse

**Detect:** Count transitions per paragraph. More than one per paragraph signals overuse.

**Flagged words:** Moreover, furthermore, additionally, consequently, nevertheless, nonetheless, in addition, as such, thereby, hence, thus (when used as sentence starters).

**Example:**
> The API supports pagination. Moreover, it includes filtering capabilities. Furthermore, sorting is available on all endpoints. Additionally, you can specify field selection.

**Fix:**
> The API supports pagination, filtering, sorting, and field selection on all endpoints.

Combine related facts into a single sentence. Transitions between closely related points add noise without aiding comprehension.

### Corporate Buzzwords

**Detect:** Scan for words that sound impressive but carry no specific meaning.

**Flagged words:** synergy, paradigm, best-in-class, world-class, cutting-edge, next-generation, state-of-the-art, game-changer, disruptive, scalable (when not discussing actual scaling), ecosystem (when not discussing actual systems), alignment (when not discussing data/UI).

**Example:**
> This next-generation, best-in-class solution leverages cutting-edge paradigms to deliver scalable, world-class results.

**Fix:**
> This tool processes 10K requests/second on a single node and scales horizontally via Redis pub/sub.

Replace buzzwords with measurable claims. If the claim can't be measured, it probably isn't worth making.

### Unnecessary Complexity

**Detect:** Words with simpler synonyms that carry the same meaning in context.

| Complex | Simple |
|---------|--------|
| utilize | use |
| facilitate | help |
| implement | build, add |
| functionality | feature |
| methodology | method |
| componentization | splitting into components |
| performant | fast |
| problematic | broken, slow, wrong |
| architected | designed, built |
| instantiate | create |
| decommission | remove, shut down |
| operationalize | run, deploy |

**Fix:** Replace with the simpler word. If the sentence still makes sense (it will), the complex word was unnecessary.

### Hedging Language

**Detect:** Qualifiers that weaken statements without adding useful nuance.

**Flagged patterns:**
- "might", "could potentially", "may possibly"
- "it seems that", "it appears that"
- "arguably", "presumably"
- "to some extent", "in some cases" (without specifying which cases)
- "relatively", "somewhat", "fairly"

**Example:**
> It might be worth considering that this approach could potentially lead to somewhat improved performance in certain scenarios.

**Fix:**
> This approach improves query performance by 15% for reads over 1MB.

State the fact. If you don't know the fact, say what you don't know — hedging helps no one.

## Structural Anti-Patterns

### Context Before Answer

**Detect:** The first paragraph provides background, history, or definitions before stating what the reader needs to know or do.

**Example:**
> Authentication is a critical component of modern web applications. Over the years, various approaches have evolved, from session-based cookies to token-based systems. JSON Web Tokens (JWTs) emerged as a popular standard due to their stateless nature. In our application, we use JWTs for authentication.

**Fix:**
> We use JWTs for authentication. Tokens are issued at login, stored client-side, and validated on each API request.

Lead with the answer. Readers seeking context will keep reading. Readers seeking the answer will leave if they can't find it.

### Wind-Up Phrases

**Detect:** Sentences that start with a clause before reaching the point.

**Flagged patterns:**
- "It's important to note that..."
- "It's worth mentioning that..."
- "As previously discussed..."
- "Before we begin, let's..."
- "First and foremost..."
- "In this section, we will..."
- "Let's take a moment to..."
- "It should be noted that..."

**Fix:** Delete the wind-up. Start with the fact.

> ~~It's important to note that~~ The cache expires after 30 minutes.

### Over-Nesting

**Detect:** Content nested 3+ levels deep (e.g., a sub-sub-list inside a numbered list inside a section).

**Example:**
```
1. Authentication
   a. Token types
      i. Access tokens
         - Short-lived
         - Used for API calls
      ii. Refresh tokens
         - Long-lived
         - Used to get new access tokens
   b. Storage
      i. Client-side
         - localStorage
         - httpOnly cookies
```

**Fix:** Flatten to 2 levels maximum. Use a table or separate sections for the third level.

| Token Type | Lifetime | Purpose |
|-----------|----------|---------|
| Access | 15 min | API calls |
| Refresh | 7 days | Renew access tokens |

**Storage options:** `httpOnly` cookies (recommended) or `localStorage`.

### Long Paragraphs

**Detect:** Any paragraph exceeding 4 sentences or 75 words.

**Fix:** Break at topic shifts. Each paragraph makes one point. If a paragraph covers two ideas, it's two paragraphs.

### List Overload

**Detect:** Bulleted or numbered lists with more than 9 items, presented flat without grouping.

**Fix:** Categorize into sub-lists of 5-7 items with descriptive group headings. If items have attributes, use a table instead.

## Sentence-Level Patterns

For editing mechanics (passive voice conversion, sentence splitting, nominalization reversal), see [conciseness-techniques.md](conciseness-techniques.md). This section covers detection only.

**Signals of LLM sentence-level output:**
- High passive voice density (over 30% of sentences)
- Average sentence length over 22 words
- Nominalizations where verbs would work ("make a determination" instead of "decide")
- Compound sentences joined by 3+ conjunctions

When these patterns cluster in the same paragraph, the text reads as AI-generated regardless of vocabulary.

## Formatting Anti-Patterns

### Generic Headings

**Detect:** Headings that could appear in any document: "Overview", "Introduction", "Background", "Details", "Summary", "Conclusion", "Additional Information".

**Fix:** Replace with specific claims or questions the section answers.

| Generic | Specific |
|---------|----------|
| Overview | What this module does |
| Background | Why we chose JWTs |
| Details | Configuration options |
| Summary | Key tradeoffs |
| Additional Information | Troubleshooting connection failures |

### Missing Hierarchy

**Detect:** Long documents with no headings, or headings that don't reflect the logical structure.

**Fix:** Add one heading per ~300 words. Use heading levels to reflect containment (H2 for sections, H3 for subsections). Never skip levels.

### Example Drought

**Detect:** Instructions or explanations with no concrete examples.

**Fix:** Add a before/after pair, a code snippet, or a concrete scenario for every non-trivial instruction. Readers learn from examples faster than from prose.

## Quick Detection Summary

Use these questions to determine if text has LLM anti-patterns:

1. **Vocabulary:** Do banned words from SKILL.md appear? Count matches — target zero.
2. **Structure:** Does any section start with context instead of the answer?
3. **Transitions:** More than one transition word per paragraph?
4. **Formatting:** Are headings generic ("Overview", "Details")?

For full validation metrics (reading level, passive voice %, sentence length), see the Phase 5 checklist in SKILL.md and the readability metrics in [conciseness-techniques.md](conciseness-techniques.md).
