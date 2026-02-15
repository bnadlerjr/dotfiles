# Discovery Patterns

Known agent instruction file names and locations to scan when auto-discovering in a project.

## Scan Locations

All paths are relative to the project root.

### Claude Code

| Path | Notes |
|------|-------|
| `CLAUDE.md` | Primary Claude Code instruction file |
| `.claude/CLAUDE.md` | Alternative location |
| `.claude/settings.json` | May contain instruction overrides |

### GitHub Copilot

| Path | Notes |
|------|-------|
| `COPILOT.md` | Copilot instruction file (root) |
| `.github/copilot-instructions.md` | Official Copilot location |

### Cursor

| Path | Notes |
|------|-------|
| `.cursorrules` | Legacy Cursor rules file |
| `cursor.md` | Cursor instruction file |
| `.cursor/rules/*.md` | Cursor rules directory (glob for all .md files) |
| `.cursor/rules/*.mdc` | Cursor rules in .mdc format |

### Windsurf / Codeium

| Path | Notes |
|------|-------|
| `.windsurfrules` | Windsurf rules file |

### Cline

| Path | Notes |
|------|-------|
| `cline_docs/` | Cline documentation directory (scan all files inside) |
| `.clinerules` | Cline rules file |

### Generic / Multi-Agent

| Path | Notes |
|------|-------|
| `AGENTS.md` | Generic agent instructions |
| `CODING_GUIDELINES.md` | Coding guidelines (often agent-targeted) |
| `CONTRIBUTING.md` | May contain agent-specific instructions (check content) |
| `.editorconfig` | Editor configuration (relevant but usually keep separate) |

## Discovery Procedure

### Step 1: Scan for Known Files

```
For each known path above:
  - Check if file/directory exists
  - If exists, record: path, size (lines), and agent tool it targets
```

### Step 2: Check for CONTRIBUTING.md

`CONTRIBUTING.md` is special — it often serves both humans and agents. Only include it if:
- It contains directives clearly aimed at AI agents (look for "AI", "agent", "Claude", "Copilot", "LLM")
- It contains style rules that overlap with other agent instruction files

If it is purely human-oriented contributor docs, exclude it from refactoring.

### Step 3: Report Findings

Present to user:

```
## Discovered Agent Instruction Files

| File | Lines | Agent |
|------|-------|-------|
| CLAUDE.md | 342 | Claude Code |
| .cursorrules | 89 | Cursor |
| .github/copilot-instructions.md | 156 | GitHub Copilot |

Total: 587 lines across 3 files

Which files should I include in the refactoring?
```

### Step 4: Handle Multi-Agent Projects

If files target different agents:
- Ask user if they want to consolidate into a single agent's format
- Or refactor each independently
- Note: `guidelines/` directory can be shared across agent root files

## Edge Cases

- **No files found**: Report "No agent instruction files found" and stop
- **Only one small file** (<50 lines): Report "File is already compact. Want me to audit it instead?"
- **Monorepo with nested files**: Scan only the current project root, not sub-packages
- **Symlinks**: Follow symlinks but note them in the report
