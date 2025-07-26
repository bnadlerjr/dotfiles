#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path


def run_command(command, cwd):
    """Run a shell command and return its output."""
    try:
        result = subprocess.run(
            command, shell=True, capture_output=True, text=True, cwd=cwd, timeout=30
        )
        return {
            "command": command,
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr,
        }
    except subprocess.TimeoutExpired:
        return {
            "command": command,
            "returncode": -1,
            "stdout": "",
            "stderr": f"Command timed out after 30 seconds: {command}",
        }
    except Exception as e:
        return {
            "command": command,
            "returncode": -1,
            "stdout": "",
            "stderr": f"Error running command: {str(e)}",
        }


def lint_elixir_file(file_path, project_dir):
    """Run Elixir linting commands in parallel."""
    commands = [
        "mix compile --warnings-as-errors",
        "mix credo --strict",
        f"mix format {file_path}",
    ]

    results = []
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {
            executor.submit(run_command, cmd, project_dir): cmd for cmd in commands
        }
        for future in as_completed(futures):
            results.append(future.result())

    return results


def lint_ruby_file(file_path, project_dir):
    """Run Ruby linting command."""
    command = f"bundle exec rubocop -A {file_path}"
    return [run_command(command, project_dir)]


def lint_python_file(file_path, project_dir):
    """Run Python linting commands in parallel."""
    commands = [f"uvx ruff check {file_path}", f"uvx ruff format {file_path}"]

    results = []
    with ThreadPoolExecutor(max_workers=2) as executor:
        futures = {
            executor.submit(run_command, cmd, project_dir): cmd for cmd in commands
        }
        for future in as_completed(futures):
            results.append(future.result())

    return results


def lint_typescript_file(file_path, project_dir):
    """Run TypeScript linting commands in parallel."""
    commands = [
        f"npx eslint --fix {file_path}",
        f"npx prettier --write {file_path}",
        f"npx tsc --noEmit --skipLibCheck {file_path}",
    ]

    results = []
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {
            executor.submit(run_command, cmd, project_dir): cmd for cmd in commands
        }
        for future in as_completed(futures):
            results.append(future.result())

    return results


def format_output(results, file_path):
    """Format linting results for output."""
    has_errors = False
    output_lines = []

    for result in results:
        if result["returncode"] != 0:
            has_errors = True
            output_lines.append(f"\n=== Linting error for {file_path} ===")
            output_lines.append(f"Command: {result['command']}")
            if result["stdout"]:
                output_lines.append("STDOUT:")
                output_lines.append(result["stdout"])
            if result["stderr"]:
                output_lines.append("STDERR:")
                output_lines.append(result["stderr"])
            output_lines.append("=" * 50)

    return has_errors, "\n".join(output_lines)


def main():
    try:
        input_data = json.load(sys.stdin)
        tool_name = input_data.get("tool_name", "")
        tool_input = input_data.get("tool_input", {})

        # Only process Write, Edit, and MultiEdit tools
        if tool_name not in ["Write", "Edit", "MultiEdit"]:
            sys.exit(0)

        # Extract file path
        file_path = tool_input.get("file_path", "")
        if not file_path:
            sys.exit(0)

        # Get project directory
        project_dir = os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())

        # Determine file type and run appropriate linters
        path = Path(file_path)
        results = []

        if path.suffix in [".ex", ".exs"]:
            results = lint_elixir_file(file_path, project_dir)
        elif path.suffix == ".rb":
            results = lint_ruby_file(file_path, project_dir)
        elif path.suffix == ".py":
            results = lint_python_file(file_path, project_dir)
        elif path.suffix in [".ts", ".tsx", ".js", ".jsx"]:
            results = lint_typescript_file(file_path, project_dir)
        else:
            # No linting for other file types
            sys.exit(0)

        # Format and output results
        has_errors, output = format_output(results, file_path)

        if has_errors:
            print(output)
            sys.exit(1)

        sys.exit(0)

    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
