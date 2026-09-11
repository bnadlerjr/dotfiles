#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.8"
# dependencies = []
# ///

"""Run the live semantic eval corpus for validate-commit-message."""

from __future__ import annotations

import importlib.util
import json
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path

HERE = Path(__file__).parent
CLI = HERE / "validate-commit-message"
CORPUS = HERE / "validate_commit_message_evals.jsonl"


def load_validator():
    spec = importlib.util.spec_from_file_location(
        "validate_commit_message_eval_target",
        CLI,
        loader=SourceFileLoader("validate_commit_message_eval_target", str(CLI)),
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def compare(actual: dict, expected: dict) -> list[str]:
    """Compare stable classifications while ignoring explanatory prose."""
    differences = []
    for key in ("valid", "body_warranted", "sentences", "references"):
        if actual.get(key) != expected.get(key):
            differences.append(
                f"{key}: expected {expected.get(key)!r}, got {actual.get(key)!r}"
            )
    return differences


def load_cases(path: Path):
    try:
        with path.open() as corpus:
            for line_number, line in enumerate(corpus, 1):
                if line.strip():
                    yield line_number, json.loads(line)
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"cannot read eval corpus: {error}") from error


def main(argv: list[str]) -> int:
    if argv:
        print("usage: validate_commit_message_evals.py", file=sys.stderr)
        return 2

    validator = load_validator()
    failures = 0
    cases = list(load_cases(CORPUS))

    for line_number, case in cases:
        message = validator.parse_message(case["message"])
        context = validator.Context(case["diff"], case["files"])
        try:
            actual = validator.invoke_claude(validator.build_prompt(message, context))
            differences = compare(actual, case["expected"])
        except validator.OperationalError as error:
            differences = [str(error)]

        if differences:
            failures += 1
            print(f"FAIL {case['name']} (line {line_number})")
            for difference in differences:
                print(f"  {difference}")
        else:
            print(f"PASS {case['name']}")

    print(f"\n{len(cases) - failures}/{len(cases)} evals passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
