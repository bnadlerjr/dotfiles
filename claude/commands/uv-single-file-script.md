<context>
You are generating a self-contained Python script for Claude Code hooks using UV (Astral's package manager) for dependency management. This script will be executed in a sandboxed environment with automatic dependency installation and must follow established patterns for reliability and performance.
</context>

<technical_requirements>
SCRIPT HEADER (mandatory):
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     # List exact dependencies with version constraints
#     # Example: "requests>=2.32.0,<3.0.0",
# ]
# ///

STRUCTURE:
- All imports at the top after the script metadata
- Main logic in a main() function
- Use if __name__ == "__main__": pattern
- Exit with appropriate codes via sys.exit()

EXIT CODES:
- 0: Success - hook executed successfully
- 2: Blocking error - prevents tool execution (PreToolUse only)
- Other non-zero: Non-blocking error - shows stderr but continues

INPUT/OUTPUT:
- Read JSON input from stdin: input_data = json.load(sys.stdin)
- Write results to stdout (print or json.dumps)
- Write errors/debug info to stderr (print(..., file=sys.stderr))
- For blocking decisions, output JSON: {"decision": "block", "reason": "..."}
</technical_requirements>

<performance_optimizations>
- Minimize imports (only import what's needed)
- Use early exits for validation failures
- Leverage UV's caching (dependencies cached after first run)
- Process data efficiently (generators for large datasets)
- Fail fast on invalid inputs
- Use appropriate data structures (set for lookups, dict for mappings)
</performance_optimizations>

<hook_context>
AVAILABLE ENVIRONMENT VARIABLES:
- CLAUDE_PROJECT_DIR: Project root directory
- CLAUDE_TOOL_NAME: Current tool being executed
- CLAUDE_FILE_PATHS: Space-separated list of involved files
- CLAUDE_TOOL_OUTPUT: Output from tool execution (PostToolUse)
- CLAUDE_SESSION_ID: Unique session identifier

HOOK TYPES:
- UserPromptSubmit: Before Claude processes prompt
- PreToolUse: Before tool execution (can block)
- PostToolUse: After tool completion
- Notification: When Claude sends notifications
- Stop: When Claude finishes responding
- SubagentStop: When subagents finish
</hook_context>

<task>
$ARGUMENTS
</task>

<code_patterns>
STANDARD INPUT PROCESSING:
```python
def main():
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get('tool_name', '')
        tool_input = input_data.get('tool_input', {})
        session_id = input_data.get('session_id', '')
        timestamp = input_data.get('timestamp', '')
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)
```

LOGGING PATTERN:
```python
def log_event(event_data, log_filename='hook_log.json'):
    log_dir = Path.cwd() / 'logs'
    log_dir.mkdir(parents=True, exist_ok=True)
    log_path = log_dir / log_filename
    
    # Read existing or initialize
    log_data = []
    if log_path.exists():
        try:
            with open(log_path, 'r') as f:
                log_data = json.load(f)
        except json.JSONDecodeError:
            pass
    
    # Add timestamp and append
    event_data['logged_at'] = datetime.now(timezone.utc).isoformat()
    log_data.append(event_data)
    
    # Write back
    with open(log_path, 'w') as f:
        json.dump(log_data, f, indent=2)
```

VALIDATION PATTERN:

```python
def validate_operation(tool_name, tool_input):
    # Return (is_valid, error_message)
    if tool_name in ['Edit', 'Write'] and '.env' in tool_input.get('file_path', ''):
        return False, "Cannot modify sensitive .env files"
    return True, None
```
</code_patterns>

<best_practices>
Include comprehensive error handling with try/except blocks
Add docstrings for main functions
Use type hints where beneficial for clarity
Validate all inputs before processing
Keep functions focused and single-purpose
Use Path from pathlib for file operations
Handle missing environment variables gracefully
Log important events for debugging
Clean up resources in finally blocks
Use descriptive variable names
</best_practices>
