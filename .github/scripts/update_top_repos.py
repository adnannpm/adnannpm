"""Update the five most-starred public, non-fork repositories via GitHub's API."""

import html
import json
import os
from pathlib import Path
from urllib.request import Request, urlopen

START = "<!--START_SECTION:top-repos-->"
END = "<!--END_SECTION:top-repos-->"


def fetch_page(owner: str, page: int) -> list:
    headers = {
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
        "User-Agent": "github-profile-readme",
    }
    if token := os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {token}"
    request = Request(
        f"https://api.github.com/users/{owner}/repos?type=owner&per_page=100&page={page}",
        headers=headers,
    )
    with urlopen(request, timeout=30) as response:
        return json.load(response)


def fetch_repos(owner: str) -> list:
    repos = []
    page = 1
    while True:
        batch = fetch_page(owner, page)
        repos.extend(batch)
        if len(batch) < 100:
            return repos
        page += 1


def cell(value: str | None) -> str:
    # Escape both HTML and Markdown, and prevent descriptions breaking table rows.
    value = html.escape(" ".join((value or "—").split()), quote=False)
    for char in "\\|[]*_`":
        value = value.replace(char, f"&#{ord(char)};")
    return value


def refresh(content: str, repos: list) -> str:
    if content.count(START) != 1 or content.count(END) != 1:
        raise ValueError("README must contain exactly one pair of top-repos markers")
    start = content.index(START) + len(START)
    end = content.index(END)
    if end < start:
        raise ValueError("Top-repos markers are out of order")
    ranked = sorted(
        (repo for repo in repos if not repo.get("fork") and not repo.get("private")),
        key=lambda repo: (-repo["stargazers_count"], repo["name"].lower()),
    )[:5]
    rows = ["| Repository | Description | Language | Stars |",
            "| :--- | :--- | :--- | ---: |"]
    for repo in ranked:
        rows.append(
            f'| [{cell(repo["name"])}]({repo["html_url"]}) '
            f'| {cell(repo.get("description"))} | {cell(repo.get("language"))} '
            f'| ⭐ {repo["stargazers_count"]} |'
        )
    if not ranked:
        rows.append("| No public repositories yet | — | — | — |")
    return content[:start] + "\n\n" + "\n".join(rows) + "\n\n" + content[end:]


if __name__ == "__main__":
    path = Path(__file__).resolve().parents[2] / "README.md"
    content = path.read_text(encoding="utf-8")
    # Fetch everything before writing: API failures leave the README untouched.
    updated = refresh(content, fetch_repos("adnannpm"))
    if updated != content:
        path.write_text(updated, encoding="utf-8")
