# Dev Task Templates

See [examples.md](examples.md) for these templates filled in as worked examples, and [anti-patterns.md](anti-patterns.md) for failure modes to avoid.

## Complete Task Template

```markdown
## Task: [Descriptive Title — the change, not a feature]

[Narrative: 2-4 sentences in concrete technical terms describing the
debt/risk/friction that drives the work, the structural change being made,
and what stays the same (the behavior-preservation stance). Name the real
modules and paths.]

### Scope
In: [files/modules/paths this task touches]
Out: [explicitly excluded — what this task will NOT change]

### Invariants
- [What must NOT change: behavior, public API, contracts, on-disk formats]

### Definition of Done
- [ ] [Safety: behavior-preservation gate — suite passes, no new failures;
      characterization tests first where coverage was thin]
- [ ] [Outcome: the structural end state achieved, with concrete paths/identifiers]
- [ ] [Invariant: what must NOT have changed, asserted]
- [ ] [Gates: typecheck / lint / build / CI / coverage threshold]

---

### Notes
[Optional: dependencies on other tasks, ordering, open questions, related story]
```

## Discovery Output Template

```markdown
**Understanding**: [1-2 sentence summary of the change]

**Motivation**: [Why now — debt/risk/friction]
**Scope**: In: [paths/modules] | Out: [explicitly excluded]
**Invariants**: [What must NOT change]
**Verification**: [How we know it's done AND safe]
**Risks & Rollback**: [What could break | how detected | how to back out]
**Coverage baseline**: [Tested? Characterization tests needed first?]
```

## Quality Check Template

See the Quality Checklist in `../SKILL.md` (Phase 4: Review) for the canonical list of checks to present with the final task.

## Canonical Example

```markdown
## Task: Break the auth → legacy import

The `auth/` package reaches into `legacy/` for session validation, which blocks
us from deleting `legacy/` and forces a circular build dependency. Move the
session-validation logic into `auth/session.ts` and have `legacy/` call into
`auth/` instead, with no change to who is allowed in.

### Scope
In: `auth/session.ts`, `auth/index.ts`, the `legacy/gatekeeper.ts` call sites.
Out: token format, password hashing, the public `authenticate()` signature.

### Invariants
- Observable auth behavior is unchanged: the same requests are allowed/denied.
- `authenticate()` keeps its current signature and return type.

### Definition of Done
- [ ] Characterization tests added for the deny and expired-session paths BEFORE the move
- [ ] Full test suite passes, no new failures
- [ ] `auth/` no longer imports from `legacy/`
- [ ] No public API signatures changed
- [ ] Typecheck + lint clean
```
