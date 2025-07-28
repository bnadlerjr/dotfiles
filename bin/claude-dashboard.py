#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "textual>=0.41.0",
#     "aiosqlite>=0.19.0",
#     "rich>=13.5.0",
#     "pyperclip>=1.8.2",
# ]
# ///

"""
Claude Code Events TUI Dashboard

A real-time terminal user interface for monitoring Claude Code events
stored in a SQLite database. Features multi-pane layout with overview
statistics, event stream, filters, and detailed event information.

Usage:
    ./claude-dashboard.py [--db PATH] [--config PATH]
"""

import asyncio
import json
import logging
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional, Set

import aiosqlite
from rich.console import RenderableType
from rich.panel import Panel
from rich.text import Text
from textual import on, work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Container, Vertical
from textual.reactive import reactive
from textual.screen import ModalScreen
from textual.widget import Widget
from textual.widgets import (
    DataTable,
    Footer,
    Header,
    Input,
    Label,
    Static,
    Checkbox,
)


class EventStatus(Enum):
    """Event status types"""

    SUCCESS = "success"
    ERROR = "error"
    WARNING = "warning"


@dataclass
class Event:
    """Event data model"""

    id: str
    timestamp: int
    type: str
    project: Optional[str]
    status: EventStatus
    session_id: Optional[str]
    tool: Optional[str]
    prompt: Optional[str]
    input: Optional[Dict[str, Any]]
    output: Optional[Dict[str, Any]]
    duration_ms: Optional[int]
    error_details: Optional[str]

    @property
    def timestamp_str(self) -> str:
        """Format timestamp as HH:MM:SS"""
        return datetime.fromtimestamp(self.timestamp / 1000).strftime("%H:%M:%S")

    @property
    def status_icon(self) -> str:
        """Get status icon"""
        return {
            EventStatus.SUCCESS: "✓",
            EventStatus.ERROR: "✗",
            EventStatus.WARNING: "⚠",
        }[self.status]

    @property
    def status_color(self) -> str:
        """Get status color"""
        return {
            EventStatus.SUCCESS: "green",
            EventStatus.ERROR: "red",
            EventStatus.WARNING: "yellow",
        }[self.status]


class DatabaseManager:
    """SQLite database connection manager"""

    logger = logging.getLogger(__name__)

    def __init__(self, db_path: str):
        self.db_path = Path(db_path).expanduser()
        self.connection: Optional[aiosqlite.Connection] = None

    async def connect(self):
        """Establish database connection"""
        self.logger.info(f"Connecting to database at {self.db_path}")
        self.connection = await aiosqlite.connect(self.db_path, timeout=30.0)
        self.connection.row_factory = aiosqlite.Row
        self.logger.info("Database connection established")

    async def close(self):
        """Close database connection"""
        if self.connection:
            await self.connection.close()

    async def get_events(
        self,
        limit: int = 1000,
        offset: int = 0,
        projects: Optional[Set[str]] = None,
        types: Optional[Set[str]] = None,
        sessions: Optional[Set[str]] = None,
        search: Optional[str] = None,
    ) -> List[Event]:
        """Fetch events with optional filters"""
        query = "SELECT * FROM claude_events WHERE 1=1"
        params = []

        if projects:
            placeholders = ",".join("?" * len(projects))
            query += f" AND project_name IN ({placeholders})"
            params.extend(projects)

        if types:
            placeholders = ",".join("?" * len(types))
            query += f" AND hook_type IN ({placeholders})"
            params.extend(types)

        if sessions:
            placeholders = ",".join("?" * len(sessions))
            query += f" AND session_id IN ({placeholders})"
            params.extend(sessions)

        if search:
            query += " AND (event_id LIKE ? OR hook_type LIKE ? OR user_prompt LIKE ? OR tool_name LIKE ?)"
            search_param = f"%{search}%"
            params.extend([search_param] * 4)

        query += " ORDER BY created_at DESC LIMIT ? OFFSET ?"
        params.extend([limit, offset])

        async with self.connection.execute(query, params) as cursor:
            rows = await cursor.fetchall()
            return [self._row_to_event(row) for row in rows]

    async def get_latest_timestamp(self) -> Optional[str]:
        """Get the timestamp of the most recent event"""
        query = "SELECT MAX(created_at) as max_ts FROM claude_events"
        async with self.connection.execute(query) as cursor:
            row = await cursor.fetchone()
            return row["max_ts"] if row else None

    async def get_stats(
        self,
        projects: Optional[Set[str]] = None,
        types: Optional[Set[str]] = None,
        sessions: Optional[Set[str]] = None,
    ) -> Dict[str, int]:
        """Get event statistics"""
        base_where = "WHERE 1=1"
        params = []

        if projects:
            placeholders = ",".join("?" * len(projects))
            base_where += f" AND project_name IN ({placeholders})"
            params.extend(projects)

        if types:
            placeholders = ",".join("?" * len(types))
            base_where += f" AND hook_type IN ({placeholders})"
            params.extend(types)

        if sessions:
            placeholders = ",".join("?" * len(sessions))
            base_where += f" AND session_id IN ({placeholders})"
            params.extend(sessions)

        # Get total count
        total_query = f"SELECT COUNT(*) as count FROM claude_events {base_where}"
        async with self.connection.execute(total_query, params) as cursor:
            total_row = await cursor.fetchone()
            total = total_row["count"]

        # Since we don't have status in the schema, we'll derive it from the data
        # For now, we'll get all events and derive status from tool_output
        events_query = f"SELECT tool_output FROM claude_events {base_where}"
        async with self.connection.execute(events_query, params) as cursor:
            rows = await cursor.fetchall()

        stats = {"total": total, "success": 0, "error": 0, "warning": 0}

        for row in rows:
            status = "success"  # Default
            if row["tool_output"]:
                try:
                    output = json.loads(row["tool_output"])
                    if isinstance(output, dict):
                        if output.get("error") or output.get("exit_code", 0) != 0:
                            status = "error"
                        elif output.get("warning"):
                            status = "warning"
                except (json.JSONDecodeError, TypeError):
                    pass

            stats[status] += 1

        return stats

    async def get_unique_projects(self) -> List[str]:
        """Get list of unique project names"""
        query = "SELECT DISTINCT project_name FROM claude_events WHERE project_name IS NOT NULL ORDER BY project_name"
        async with self.connection.execute(query) as cursor:
            rows = await cursor.fetchall()
            return [row["project_name"] for row in rows]

    async def get_unique_types(self) -> List[str]:
        """Get list of unique event types"""
        query = "SELECT DISTINCT hook_type FROM claude_events ORDER BY hook_type"
        async with self.connection.execute(query) as cursor:
            rows = await cursor.fetchall()
            return [row["hook_type"] for row in rows]

    async def get_unique_sessions(self) -> List[str]:
        """Get list of unique session IDs"""
        query = "SELECT DISTINCT session_id FROM claude_events WHERE session_id IS NOT NULL ORDER BY created_at DESC"
        async with self.connection.execute(query) as cursor:
            rows = await cursor.fetchall()
            return [row["session_id"] for row in rows]

    def _row_to_event(self, row: aiosqlite.Row) -> Event:
        """Convert database row to Event object"""
        # Parse created_at from SQLite datetime format (YYYY-MM-DD HH:MM:SS) to milliseconds
        created_at_str = row["created_at"]
        if created_at_str:
            try:
                # SQLite datetime format: "2025-07-27 23:51:43"
                dt = datetime.strptime(created_at_str, "%Y-%m-%d %H:%M:%S")
                # Assume UTC timezone
                dt = dt.replace(tzinfo=timezone.utc)
                timestamp_ms = int(dt.timestamp() * 1000)
            except (ValueError, AttributeError):
                timestamp_ms = int(datetime.now().timestamp() * 1000)
        else:
            timestamp_ms = int(datetime.now().timestamp() * 1000)

        # Parse tool input/output
        tool_input = None
        tool_output = None
        if row["tool_input"]:
            try:
                tool_input = json.loads(row["tool_input"])
            except (json.JSONDecodeError, TypeError):
                tool_input = {"raw": row["tool_input"]}

        if row["tool_output"]:
            try:
                tool_output = json.loads(row["tool_output"])
            except (json.JSONDecodeError, TypeError):
                tool_output = {"raw": row["tool_output"]}

        # Derive status from tool output or event type
        status = EventStatus.SUCCESS  # Default
        error_details = None

        if tool_output:
            # Check for error indicators in output
            if isinstance(tool_output, dict):
                if tool_output.get("error") or tool_output.get("exit_code", 0) != 0:
                    status = EventStatus.ERROR
                    error_details = str(tool_output.get("error", ""))
                elif tool_output.get("warning"):
                    status = EventStatus.WARNING

        # Map fields from actual schema to expected schema
        return Event(
            id=row["event_id"],
            timestamp=timestamp_ms,
            type=row["hook_type"],
            project=row["project_name"],
            status=status,
            session_id=row["session_id"],
            tool=row["tool_name"],
            prompt=row["user_prompt"],
            input=tool_input,
            output=tool_output,
            duration_ms=None,  # Not available in current schema
            error_details=error_details,
        )


class OverviewPanel(Widget):
    """Overview statistics panel"""

    stats = reactive({"total": 0, "success": 0, "error": 0, "warning": 0})

    def render(self) -> RenderableType:
        """Render the overview panel"""
        stats = self.stats

        # Calculate success percentage
        success_pct = 0
        if stats["total"] > 0:
            success_pct = int((stats["success"] / stats["total"]) * 100)

        # Create progress bar
        bar_width = 20
        filled = int(bar_width * success_pct / 100)
        empty = bar_width - filled
        progress_bar = "▓" * filled + "░" * empty

        content = f"""Total: {stats["total"]:,}
Success: {stats["success"]:,}
Errors: {stats["error"]:,}
Warnings: {stats["warning"]:,}

{progress_bar} {success_pct}%"""

        return Panel(content, title="Overview", border_style="blue")


class FilterPanel(Widget):
    """Inner content for the filter panel"""

    def __init__(self):
        super().__init__()
        self.project_checks: List[Checkbox] = []
        self.type_checks: List[Checkbox] = []
        self.session_checks: List[Checkbox] = []
        self.all_projects_check: Optional[Checkbox] = None
        self.all_types_check: Optional[Checkbox] = None
        self.all_sessions_check: Optional[Checkbox] = None

    def compose(self) -> ComposeResult:
        """Create the filter panel UI"""
        with Vertical():
            yield Label("Projects", classes="filter-header")
            self.all_projects_check = Checkbox(
                "All Projects", value=True, id="all-projects"
            )
            yield self.all_projects_check
            yield Container(id="project-filters")

            yield Label("─" * 20, classes="filter-divider")

            yield Label("Types", classes="filter-header")
            self.all_types_check = Checkbox("All Types", value=True, id="all-types")
            yield self.all_types_check
            yield Container(id="type-filters")

            yield Label("─" * 20, classes="filter-divider")

            yield Label("Session IDs", classes="filter-header")
            self.all_sessions_check = Checkbox(
                "All Sessions", value=True, id="all-sessions"
            )
            yield self.all_sessions_check
            yield Container(id="session-filters")

    async def update_filters(
        self, projects: List[str], types: List[str], sessions: List[str]
    ):
        """Update available filters"""
        # Update project filters
        project_container = self.query_one("#project-filters", Container)
        await project_container.remove_children()
        self.project_checks.clear()

        for project in projects:
            checkbox = Checkbox(project, value=False, classes="filter-item")
            self.project_checks.append(checkbox)
            await project_container.mount(checkbox)

        # Update type filters
        type_container = self.query_one("#type-filters", Container)
        await type_container.remove_children()
        self.type_checks.clear()

        for event_type in types:
            checkbox = Checkbox(event_type, value=False, classes="filter-item")
            self.type_checks.append(checkbox)
            await type_container.mount(checkbox)

        # Update session filters
        session_container = self.query_one("#session-filters", Container)
        await session_container.remove_children()
        self.session_checks.clear()

        for session in sessions:
            # Truncate long session IDs for display
            display_text = session[:12] + "..." if len(session) > 12 else session
            checkbox = Checkbox(display_text, value=False, classes="filter-item")
            checkbox.session_id = session  # Store full ID
            self.session_checks.append(checkbox)
            await session_container.mount(checkbox)

    def get_selected_projects(self) -> Optional[Set[str]]:
        """Get selected projects or None for all"""
        if self.all_projects_check and self.all_projects_check.value:
            return None

        selected = {
            check.label.plain.strip() for check in self.project_checks if check.value
        }
        return selected if selected else None

    def get_selected_types(self) -> Optional[Set[str]]:
        """Get selected types or None for all"""
        if self.all_types_check and self.all_types_check.value:
            return None

        selected = {
            check.label.plain.strip() for check in self.type_checks if check.value
        }
        return selected if selected else None

    def get_selected_sessions(self) -> Optional[Set[str]]:
        """Get selected sessions or None for all"""
        if self.all_sessions_check and self.all_sessions_check.value:
            return None

        selected = {
            getattr(check, "session_id", check.label.plain.strip())
            for check in self.session_checks
            if check.value
        }
        return selected if selected else None

    @on(Checkbox.Changed, "#all-projects")
    def handle_all_projects_change(self, event: Checkbox.Changed):
        """Handle all projects checkbox change"""
        if event.value:
            for check in self.project_checks:
                check.value = False

    @on(Checkbox.Changed, "#all-types")
    def handle_all_types_change(self, event: Checkbox.Changed):
        """Handle all types checkbox change"""
        if event.value:
            for check in self.type_checks:
                check.value = False

    @on(Checkbox.Changed, "#all-sessions")
    def handle_all_sessions_change(self, event: Checkbox.Changed):
        """Handle all sessions checkbox change"""
        if event.value:
            for check in self.session_checks:
                check.value = False

    @on(Checkbox.Changed, ".filter-item")
    def handle_filter_item_change(self, event: Checkbox.Changed):
        """Handle individual filter item change"""
        if event.value:
            # Uncheck "All" when individual item is selected
            if event.checkbox in self.project_checks and self.all_projects_check:
                self.all_projects_check.value = False
            elif event.checkbox in self.type_checks and self.all_types_check:
                self.all_types_check.value = False
            elif event.checkbox in self.session_checks and self.all_sessions_check:
                self.all_sessions_check.value = False


# Remove the duplicate FilterPanel class that was causing issues


class EventTable(DataTable):
    """Event stream table with virtual scrolling"""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.events: List[Event] = []

    def on_mount(self):
        """Initialize table columns"""
        self.add_columns("Time", "Project", "Type", "Status")
        self.cursor_type = "row"
        self.zebra_stripes = True

    def update_events(self, events: List[Event]):
        """Update displayed events"""
        self.clear()
        self.events = events

        for event in events:
            # Format status with color
            status_text = Text(event.status_icon)
            status_text.stylize(event.status_color)

            self.add_row(
                event.timestamp_str,
                event.project or "—",
                event.type,
                status_text,
                key=event.id,
            )


class DetailsPanel(Widget):
    """Event details panel"""

    current_event = reactive(None)

    def render(self) -> RenderableType:
        """Render the details panel"""
        if not self.current_event:
            return Panel(
                "Select an event to view details", title="Details", border_style="blue"
            )

        event = self.current_event

        # Build details content
        lines = []
        lines.append(f"[bold]Event ID:[/bold] {event.id}")
        lines.append(
            f"[bold]Timestamp:[/bold] {datetime.fromtimestamp(event.timestamp / 1000)}"
        )
        lines.append(f"[bold]Type:[/bold] {event.type}")
        lines.append(f"[bold]Project:[/bold] {event.project or 'N/A'}")
        lines.append(
            f"[bold]Status:[/bold] [{event.status_color}]{event.status_icon} {event.status.value}[/]"
        )

        if event.session_id:
            lines.append(f"\n[bold]Session:[/bold] {event.session_id}")
        if event.tool:
            lines.append(f"[bold]Tool:[/bold] {event.tool}")
        if event.prompt:
            # Truncate long prompts
            prompt = (
                event.prompt[:200] + "..." if len(event.prompt) > 200 else event.prompt
            )
            lines.append(f"[bold]Prompt:[/bold] {prompt}")
        if event.duration_ms is not None:
            lines.append(f"[bold]Duration:[/bold] {event.duration_ms}ms")

        if event.input:
            lines.append("\n[bold]Input:[/bold]")
            lines.append(json.dumps(event.input, indent=2)[:300] + "...")

        if event.output:
            lines.append("\n[bold]Output:[/bold]")
            lines.append(json.dumps(event.output, indent=2)[:300] + "...")

        if event.error_details:
            lines.append("\n[bold red]Error Details:[/bold red]")
            lines.append(event.error_details[:500])

        content = "\n".join(lines)
        return Panel(content, title="Details", border_style="blue")


class HelpScreen(ModalScreen):
    """Help screen showing key bindings"""

    BINDINGS = [
        ("escape", "dismiss", "Close"),
    ]

    def compose(self) -> ComposeResult:
        help_text = """[bold]Claude Dashboard - Key Bindings[/bold]

[bold]Navigation:[/bold]
↑/↓         Navigate events
Tab         Switch between panels
Enter       Select event/option
Esc         Cancel/return

[bold]Commands:[/bold]
/           Search mode
n/N         Next/previous search result
f           Focus filters panel
r           Refresh data
a           Toggle auto-follow
g/G         Go to first/last event
?           Show this help
q           Quit application

[bold]Filters:[/bold]
Space       Toggle filter selection
c           Clear all filters

Press ESC to close this help screen."""

        with Container(id="help-dialog"):
            yield Static(help_text, id="help-content")


class ClaudeDashboard(App):
    """Main application class"""

    logger = logging.getLogger(__name__)

    CSS = """
    #app-grid {
        layout: grid;
        grid-size: 3 3;
        grid-columns: 1fr 2fr 2fr;
        grid-rows: 1fr 2fr 2fr;
    }
    
    #overview {
        column-span: 1;
        row-span: 1;
        height: 100%;
    }
    
    #event-stream {
        column-span: 1;
        row-span: 3;
        height: 100%;
    }
    
    #filters {
        column-span: 1;
        row-span: 2;
        height: 100%;
        overflow-y: auto;
        border: solid $primary;
        padding: 1;
    }
    
    #filters-title {
        text-style: bold;
        text-align: center;
        color: $primary;
        margin-bottom: 1;
    }
    
    #details {
        column-span: 1;
        row-span: 3;
        height: 100%;
        overflow-y: auto;
    }
    
    .filter-header {
        text-style: bold;
        margin: 1 0;
    }
    
    .filter-divider {
        margin: 1 0;
        color: $text 30%;
    }
    
    .filter-item {
        margin-left: 2;
    }
    
    #help-dialog {
        align: center middle;
        background: $surface;
        border: solid $primary;
        padding: 2 4;
        width: 70;
        height: auto;
        max-height: 80%;
    }
    
    #help-content {
        padding: 1;
    }
    
    #search-input {
        dock: bottom;
        height: 3;
        display: none;
    }
    
    #search-input.visible {
        display: block;
    }
    
    DataTable > .datatable--cursor {
        background: $primary 20%;
    }
    
    DataTable:focus > .datatable--cursor {
        background: $primary 40%;
    }
    """

    BINDINGS = [
        Binding("q", "quit", "Quit"),
        Binding("?", "help", "Help"),
        Binding("/", "search", "Search"),
        Binding("n", "next_match", "Next", show=False),
        Binding("N", "prev_match", "Previous", show=False),
        Binding("r", "refresh", "Refresh"),
        Binding("a", "toggle_follow", "Auto-follow"),
        Binding("g", "go_first", "First", show=False),
        Binding("G", "go_last", "Last", show=False),
        Binding("f", "focus_filters", "Filters"),
        Binding("c", "clear_filters", "Clear filters"),
        Binding("escape", "cancel_search", "Cancel", show=False),
    ]

    def __init__(self, db_path: str = "~/.claude/events.db"):
        super().__init__()
        self.db_path = db_path
        self.db: Optional[DatabaseManager] = None
        self.auto_follow = True
        self.search_mode = False
        self.search_query = ""
        self.poll_interval = 1.0  # Active polling interval
        self.idle_interval = 5.0  # Idle polling interval
        self.last_activity = datetime.now()
        self.last_timestamp: Optional[str] = None
        self.is_exiting = False

    def compose(self) -> ComposeResult:
        """Create the application UI"""
        yield Header(show_clock=True)

        with Container(id="app-grid"):
            # Overview panel (top-left)
            yield OverviewPanel(id="overview")

            # Event stream (middle column, full height)
            yield EventTable(id="event-stream")

            # Details panel (right column, full height)
            yield DetailsPanel(id="details")

            # Filters panel (bottom-left)
            with Container(id="filters"):
                yield Label("Filters", id="filters-title")
                yield FilterPanel()

        # Search input (hidden by default)
        yield Input(
            placeholder="Search events... (Enter: next, N: previous, ESC: cancel)",
            id="search-input",
        )

        yield Footer()

    async def on_mount(self):
        """Initialize the application"""
        self.db = DatabaseManager(self.db_path)

        try:
            await self.db.connect()
            self.notify("Connected to database", severity="information")

            # Load initial data
            await self.refresh_data()

            # Start monitoring
            self.monitor_events()

        except Exception as e:
            self.logger.error(f"Failed to connect to database: {e}", exc_info=True)
            self.notify(f"Failed to connect to database: {e}", severity="error")
            self.exit(1)

    async def on_unmount(self):
        """Clean up on exit"""
        if self.db:
            await self.db.close()

    @work(exclusive=True, thread=True)
    async def monitor_events(self):
        """Monitor for new events with adaptive polling"""
        while not self.is_exiting:
            try:
                # Determine polling interval based on activity
                now = datetime.now()
                time_since_activity = (now - self.last_activity).total_seconds()
                interval = (
                    self.idle_interval
                    if time_since_activity > 30
                    else self.poll_interval
                )

                await asyncio.sleep(interval)

                # Check if app is still running
                if self.is_exiting:
                    break

                # Check for new events
                latest = await self.db.get_latest_timestamp()
                if latest and latest != self.last_timestamp:
                    self.last_timestamp = latest
                    # Call refresh_data on the main thread to avoid event loop conflicts
                    self.call_from_thread(self.refresh_data)

                    if self.auto_follow:
                        # Scroll to top (newest events) - also needs to be on main thread
                        def scroll_to_top():
                            event_table = self.query_one("#event-stream", EventTable)
                            event_table.scroll_home()

                        self.call_from_thread(scroll_to_top)

            except Exception as e:
                if not self.is_exiting:
                    self.logger.warning(f"Monitoring error: {e}", exc_info=True)
                    self.notify(f"Monitoring error: {e}", severity="warning")

    async def refresh_data(self):
        """Refresh all data from database"""
        try:
            # Get current filters
            filter_panel = self.query_one(FilterPanel)
            selected_projects = filter_panel.get_selected_projects()
            selected_types = filter_panel.get_selected_types()
            selected_sessions = filter_panel.get_selected_sessions()

            # Update stats
            stats = await self.db.get_stats(
                selected_projects, selected_types, selected_sessions
            )
            overview = self.query_one("#overview", OverviewPanel)
            overview.stats = stats

            # Update events
            events = await self.db.get_events(
                projects=selected_projects,
                types=selected_types,
                sessions=selected_sessions,
                search=self.search_query if self.search_mode else None,
            )
            event_table = self.query_one("#event-stream", EventTable)
            event_table.update_events(events)

            # Update available filters
            if not selected_projects and not selected_types and not selected_sessions:
                projects = await self.db.get_unique_projects()
                types = await self.db.get_unique_types()
                sessions = await self.db.get_unique_sessions()
                await filter_panel.update_filters(projects, types, sessions)

            self.last_activity = datetime.now()

        except Exception as e:
            self.logger.error(f"Failed to refresh data: {e}", exc_info=True)
            self.notify(f"Failed to refresh data: {e}", severity="error")

    @on(DataTable.RowSelected)
    async def handle_row_selected(self, event: DataTable.RowSelected):
        """Handle event selection"""
        if event.data_table.id == "event-stream":
            event_id = event.row_key.value
            event_table = self.query_one("#event-stream", EventTable)

            # Find the selected event
            for evt in event_table.events:
                if evt.id == event_id:
                    details_panel = self.query_one("#details", DetailsPanel)
                    details_panel.current_event = evt
                    break

    @on(Checkbox.Changed)
    async def handle_filter_change(self, event: Checkbox.Changed):
        """Handle filter changes"""
        await self.refresh_data()

    def action_quit(self):
        """Quit the application"""
        self.is_exiting = True
        self.exit()

    def action_help(self):
        """Show help screen"""
        self.push_screen(HelpScreen())

    def action_search(self):
        """Enter search mode"""
        self.search_mode = True
        search_input = self.query_one("#search-input", Input)
        search_input.add_class("visible")
        search_input.focus()

    def action_cancel_search(self):
        """Cancel search mode"""
        if self.search_mode:
            self.search_mode = False
            self.search_query = ""
            search_input = self.query_one("#search-input", Input)
            search_input.remove_class("visible")
            search_input.value = ""
            self.run_worker(self.refresh_data())

    @on(Input.Submitted, "#search-input")
    async def handle_search_submit(self, event: Input.Submitted):
        """Handle search input submission"""
        self.search_query = event.value
        await self.refresh_data()

        # Move to first result
        event_table = self.query_one("#event-stream", EventTable)
        if event_table.row_count > 0:
            event_table.move_cursor(row=0)

    def action_next_match(self):
        """Go to next search match"""
        if self.search_mode:
            event_table = self.query_one("#event-stream", EventTable)
            event_table.action_cursor_down()

    def action_prev_match(self):
        """Go to previous search match"""
        if self.search_mode:
            event_table = self.query_one("#event-stream", EventTable)
            event_table.action_cursor_up()

    def action_refresh(self):
        """Manually refresh data"""
        self.run_worker(self.refresh_data())
        self.notify("Refreshed", severity="information")

    def action_toggle_follow(self):
        """Toggle auto-follow mode"""
        self.auto_follow = not self.auto_follow
        status = "enabled" if self.auto_follow else "disabled"
        self.notify(f"Auto-follow {status}", severity="information")

    def action_go_first(self):
        """Go to first event"""
        event_table = self.query_one("#event-stream", EventTable)
        event_table.scroll_home()
        if event_table.row_count > 0:
            event_table.move_cursor(row=0)

    def action_go_last(self):
        """Go to last event"""
        event_table = self.query_one("#event-stream", EventTable)
        event_table.scroll_end()
        if event_table.row_count > 0:
            event_table.move_cursor(row=event_table.row_count - 1)

    def action_focus_filters(self):
        """Focus the filters panel"""
        filter_panel = self.query_one(FilterPanel)
        filter_panel.focus()

    async def action_clear_filters(self):
        """Clear all filters"""
        filter_panel = self.query_one(FilterPanel)

        # Reset all checkboxes
        if filter_panel.all_projects_check:
            filter_panel.all_projects_check.value = True
        if filter_panel.all_types_check:
            filter_panel.all_types_check.value = True

        for check in filter_panel.project_checks:
            check.value = False
        for check in filter_panel.type_checks:
            check.value = False

        await self.refresh_data()
        self.notify("Filters cleared", severity="information")


def main():
    """Main entry point"""
    import argparse

    parser = argparse.ArgumentParser(description="Claude Code Events TUI Dashboard")
    parser.add_argument(
        "--db",
        default="~/.claude/events.db",
        help="Path to SQLite database (default: ~/.claude/events.db)",
    )
    parser.add_argument(
        "--config", help="Path to configuration file (not implemented yet)"
    )
    parser.add_argument("--debug", action="store_true", help="Enable debug logging")

    args = parser.parse_args()

    # Set up logging
    log_dir = Path("~/.claude").expanduser()
    log_dir.mkdir(exist_ok=True)
    log_file = log_dir / "dashboard.log"

    log_level = logging.DEBUG if args.debug else logging.INFO
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler() if args.debug else logging.NullHandler(),
        ],
    )

    logger = logging.getLogger(__name__)
    logger.info(
        f"Starting Claude Dashboard with log level: {logging.getLevelName(log_level)}"
    )

    # Check if database exists
    db_path = Path(args.db).expanduser()
    if not db_path.exists():
        logger.error(f"Database not found at {db_path}")
        print(f"Error: Database not found at {db_path}")
        sys.exit(1)

    app = ClaudeDashboard(db_path=args.db)
    app.run()


if __name__ == "__main__":
    main()
