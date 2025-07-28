# Claude Code Events TUI Dashboard

A real-time terminal user interface (TUI) for monitoring Claude Code events stored in a SQLite database.

## Features

- **Real-time Monitoring**: Adaptive polling with auto-refresh (1s active, 5s idle)
- **Multi-Pane Layout**: Overview stats, event stream, filters, and detailed event view
- **Advanced Filtering**: Filter by projects and event types
- **Search**: Vim-style search with highlighting
- **Export**: Export events to JSON, CSV, or TXT (file or clipboard)
- **Keyboard Navigation**: Full keyboard support with vim-style bindings

## Installation

The script uses `uv` for dependency management. Make sure you have `uv` installed:

```bash
# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then make the script executable:

```bash
chmod +x claude-dashboard.py
```

## Usage

```bash
# Run with default database (~/.claude/events.db)
./claude-dashboard.py

# Run with custom database path
./claude-dashboard.py --db /path/to/events.db
```

## Key Bindings

### Navigation
- `↑/↓` - Navigate events
- `Tab` - Switch between panels
- `Enter` - Select event/option
- `Esc` - Cancel/return
- `g/G` - Go to first/last event
- `Page Up/Down` - Fast scroll

### Commands
- `/` - Search mode
- `n/N` - Next/previous search result
- `f` - Focus filters panel
- `e` - Export events
- `r` - Refresh data
- `a` - Toggle auto-follow
- `?` - Show help
- `q` - Quit application

### Filters
- `Space` - Toggle filter selection
- `c` - Clear all filters

## Database Schema

The dashboard expects a SQLite database with the following table structure:

```sql
CREATE TABLE claude_events (
    id TEXT PRIMARY KEY,
    timestamp INTEGER NOT NULL,
    type TEXT NOT NULL,
    project TEXT,
    status TEXT CHECK(status IN ('success', 'error', 'warning')),
    session_id TEXT,
    tool TEXT,
    prompt TEXT,
    input JSON,
    output JSON,
    duration_ms INTEGER,
    error_details TEXT
);
```

## Layout

```
┌─ Overview ──────────┬─ Event Stream ─────────────────┬─ Filters ──────────┐
│ Total: 1,247       │ 14:32:01 evt_123 webhook       │ ☑ All Projects     │
│ Success: 1,180     │   Input: {"user": "john"}      │ ☐ project-alpha    │
│ Errors: 42         │   Output: {"status": "ok"}     │ ☐ project-beta     │
│ Warnings: 25       │ ─────────────────────────────── │ ─────────────────  │
│                    │ 14:31:45 evt_122 timer         │ ☑ All Types        │
│ ▓▓▓▓▓▓▓▓░░ 95%    │   Project: beta                │ ☐ webhook          │
├─ Details ──────────┴────────────────────────────────┤ ☐ timer            │
│ Session: sess_abc123                                 │                    │
│ Tool: curl                                          │                    │
│ Prompt: "Deploy the app"                            │                    │
│                                                     │                    │
│ Details: Full trace available                       │                    │
│ Duration: 1.2s                                      │                    │
└─────────────────────────────────────────────────────┴────────────────────┘
```

## Export Formats

- **JSON**: Full event data with proper formatting
- **CSV**: Tabular format with key fields
- **TXT**: Human-readable text format

## Requirements

- Python 3.11+
- Terminal with 256 color support (recommended)
- Minimum terminal size: 80x24

## Tips

- Use auto-follow mode (`a`) to monitor live events
- Combine filters to focus on specific projects and event types
- Export filtered results for further analysis
- Use search (`/`) to find specific events by ID or content