#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

"""List open GitHub pull requests that need the authenticated user's review."""

import argparse
import json
import subprocess
import sys
from typing import Any

SEARCH_LIMIT = 1000
SEARCH_FIELDS = "repository,number,author,title,url,updatedAt,isDraft"


class GitHubError(Exception):
    """A GitHub CLI command could not provide trustworthy data."""


def run_gh_json(*args: str) -> Any:
    try:
        result = subprocess.run(
            ["gh", *args],
            capture_output=True,
            check=False,
            text=True,
        )
    except FileNotFoundError as error:
        raise GitHubError("GitHub CLI (gh) is not installed or not on PATH") from error
    except OSError as error:
        raise GitHubError(f"could not run gh: {error}") from error

    if result.returncode != 0:
        detail = result.stderr.strip() or f"gh exited with status {result.returncode}"
        raise GitHubError(detail)

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise GitHubError("gh returned invalid JSON") from error


def search_requests(reviewer: str) -> list[dict[str, Any]]:
    requests = run_gh_json(
        "search",
        "prs",
        "--review-requested",
        reviewer,
        "--state",
        "open",
        "--draft=false",
        "--sort",
        "updated",
        "--order",
        "asc",
        "--limit",
        str(SEARCH_LIMIT),
        "--json",
        SEARCH_FIELDS,
    )
    if not isinstance(requests, list):
        raise GitHubError(f"gh returned an unexpected search response for {reviewer}")
    if len(requests) >= SEARCH_LIMIT:
        raise GitHubError(
            f"search for {reviewer} reached the {SEARCH_LIMIT}-result limit"
        )
    return requests


def get_login() -> str:
    user = run_gh_json("api", "user")
    try:
        login = user["login"]
    except (KeyError, TypeError) as error:
        raise GitHubError("gh returned an unexpected user response") from error
    if not isinstance(login, str):
        raise GitHubError("gh returned an unexpected user response")
    return login


def is_direct_request(request: dict[str, Any], login: str) -> bool:
    try:
        repository = request["repository"]["nameWithOwner"]
        number = int(request["number"])
    except (KeyError, TypeError, ValueError) as error:
        raise GitHubError("gh returned an unexpected pull request response") from error

    reviewers = run_gh_json(
        "api", f"repos/{repository}/pulls/{number}/requested_reviewers"
    )
    try:
        users = reviewers["users"]
        return any(user.get("login") == login for user in users)
    except (AttributeError, KeyError, TypeError) as error:
        raise GitHubError("gh returned an unexpected reviewer response") from error


def normalize_field(value: object) -> str:
    return str(value).replace("\t", " ").replace("\r", " ").replace("\n", " ")


def format_requests(requests: list[dict[str, Any]]) -> list[str]:
    records: dict[tuple[str, int], tuple[str, str, int, str, str, str]] = {}

    for request in requests:
        try:
            if request["isDraft"]:
                continue
            repository = request["repository"]["nameWithOwner"]
            number = int(request["number"])
            author = (request.get("author") or {}).get("login", "")
            title = request["title"]
            url = request["url"]
            updated_at = request["updatedAt"]
            if not all(
                isinstance(value, str)
                for value in (repository, author, title, url, updated_at)
            ):
                raise TypeError
        except (AttributeError, KeyError, TypeError, ValueError) as error:
            raise GitHubError(
                "gh returned an unexpected pull request response"
            ) from error

        key = (repository, number)
        records[key] = (updated_at, repository, number, author, title, url)

    ordered = sorted(
        records.values(), key=lambda record: (record[0], record[1], record[2])
    )
    return [
        "\t".join(normalize_field(value) for value in record[1:]) for record in ordered
    ]


def parse_args() -> None:
    parser = argparse.ArgumentParser(
        description="List pull requests that need your review as TSV."
    )
    parser.parse_args()


def main() -> int:
    parse_args()

    try:
        login = get_login()
        candidates = search_requests("@me")
        requests = [
            request for request in candidates if is_direct_request(request, login)
        ]
        lines = format_requests(requests)
    except GitHubError as error:
        print(f"prs-to-review: {error}", file=sys.stderr)
        return 1

    if lines:
        sys.stdout.write("\n".join(lines) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
