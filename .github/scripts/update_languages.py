"""Update language percentages by code bytes across public, non-fork repositories."""

import html
import json
import os
from pathlib import Path
from urllib.parse import quote
from urllib.request import Request, urlopen

START = "<!--START_SECTION:languages-->"
END = "<!--END_SECTION:languages-->"


def fetch_json(endpoint: str):
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "github-profile-readme",
    }
    if token := os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {token}"
    request = Request(f"https://api.github.com/{endpoint}", headers=headers)
    with urlopen(request, timeout=30) as response:
        return json.load(response)


def fetch_repos(owner: str) -> list:
    repos = []
    page = 1
    while True:
        batch = fetch_json(
            f"users/{quote(owner, safe='')}/repos?type=owner&per_page=100&page={page}"
        )
        repos.extend(batch)
        if len(batch) < 100:
            return repos
        page += 1


def fetch_languages(owner: str, repos: list) -> dict:
    totals = {}
    for repo in repos:
        if repo.get("fork") or repo.get("private"):
            continue
        languages = fetch_json(
            f"repos/{quote(owner, safe='')}/{quote(repo['name'], safe='')}/languages"
        )
        for language, size in languages.items():
            totals[language] = totals.get(language, 0) + size
    return totals


def cell(value: str) -> str:
    value = html.escape(" ".join(value.split()), quote=False)
    for char in "\\|[]*_`":
        value = value.replace(char, f"&#{ord(char)};")
    return value


def refresh(content: str, totals: dict) -> str:
    if content.count(START) != 1 or content.count(END) != 1:
        raise ValueError("README must contain exactly one pair of languages markers")
    start = content.index(START) + len(START)
    end = content.index(END)
    if end < start:
        raise ValueError("Languages markers are out of order")
    total = sum(totals.values())
    rows = ["| Language | Percentage |", "| :--- | ---: |"]
    if total:
        for language, size in sorted(totals.items(), key=lambda item: (-item[1], item[0].lower())):
            rows.append(f"| {cell(language)} | {size / total * 100:.2f}% |")
    else:
        rows.append("| No language data yet | — |")
    return content[:start] + "\n\n" + "\n".join(rows) + "\n\n" + content[end:]


if __name__ == "__main__":
    path = Path(__file__).resolve().parents[2] / "README.md"
    content = path.read_text(encoding="utf-8")
    # Finish all API requests before writing, so failures leave README untouched.
    updated = refresh(content, fetch_languages("adnannpm", fetch_repos("adnannpm")))
    if updated != content:
        path.write_text(updated, encoding="utf-8")
