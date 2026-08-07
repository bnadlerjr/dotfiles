# Workflow: Verify Skill Content Accuracy

**Read first:** `references/authoring-guidance.md` (the "avoid time-sensitive
information" section explains most of what goes stale).

`workflows/audit-skill.md` checks **structure**. This workflow checks **truth**.

Skills make claims about external things — APIs, CLI tools, frameworks, services. Those
change. This finds the claims that are no longer accurate.

## Step 1: Select the skill

```bash
ls ~/.claude/skills/
```

Present a numbered list and ask which to verify. If the caller named one, skip ahead.

## Step 2: Read and categorize

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
cat ~/.claude/skills/{skill-name}/references/*.md 2>/dev/null
cat ~/.claude/skills/{skill-name}/workflows/*.md 2>/dev/null
```

Categorize by the dependency that dominates:

| Type | Verification method |
|---|---|
| **API / service** | Fetch current docs; check the changelog |
| **CLI tool** | Run the commands |
| **Framework / library** | Fetch current docs for the specific APIs used |
| **Internal / project** | Check the repository — do the paths and conventions still hold? |
| **Pure process** | No external dependencies; verify internal consistency only |

Report: "This skill is primarily {type}-based. I'll verify using {method}."

## Step 3: Extract verifiable claims

Scan for anything that could have changed:

- **CLI tools** — tool names, documented flags, expected output patterns
- **API endpoints** — paths, authentication methods, SDK versions, request shapes
- **Framework patterns** — APIs used, version-specific features
- **Paths and structures** — expected project layouts, config file locations
- **Bundled scripts** — do they still run? Do their dependencies still resolve?

Report: "Found N verifiable claims to check."

## Step 4: Verify

**CLI tools** — check directly:

```bash
command -v {tool} && {tool} --version
{tool} --help | grep -- "{documented-flag}"
```

**APIs, frameworks, services** — fetch current documentation and compare against what
the skill documents. Are the endpoints still valid? Has authentication changed? Are
deprecated methods being used? Prefer official docs and changelogs over search results.

When searching, describe the change rather than pinning a year: "{service} breaking
changes", "{service} deprecated endpoints", "{framework} migration guide". A hardcoded
year in a search string is itself the kind of staleness this workflow exists to find —
if you see one in the skill, flag it.

**Bundled scripts** — run them against a known input and confirm the output still
matches what the skill claims.

## Step 5: Report

```
## Verification Report: {skill-name}

### Verified current
- {claim}: {evidence}

### May be outdated
- {claim}: {what changed}
  → Current: {what the docs now say}

### Broken or invalid
- {claim}: {why it's wrong}
  → Fix: {what it should be}

### Could not verify
- {claim}: {why not}

**Overall:** Fresh | Needs updates | Significantly stale
**Verified on:** {today's date}
```

## Step 6: Offer updates

1. **Update all** — apply every correction
2. **Review each** — show each change first
3. **Just the report**

When updating, record the verification date in the file so the next reader knows how
much to trust it:

```markdown
<!-- Verified against spec: YYYY-MM-DD. If today is more than ~60 days past this
     date, re-fetch the source URL and diff before trusting this file. -->
```

A stamp like that is only useful if someone acts on it. When you find one that has
expired, say so in the report — an expired freshness contract is a finding.

## Step 7: Recommend a cadence

| Skill type | Re-verify |
|---|---|
| API / service | Every 1-2 months |
| Framework / library | Every 3-6 months |
| CLI tools | Every 6 months |
| Pure process | Annually |

## Success criteria

- [ ] Skill categorized by dependency type
- [ ] Verifiable claims extracted and counted
- [ ] Each claim checked with the appropriate method
- [ ] Expired freshness stamps reported
- [ ] Report generated with a dated overall status
- [ ] Updates applied if requested
