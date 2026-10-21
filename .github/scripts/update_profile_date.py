"""Refresh only the profile date block, using the Asia/Jakarta calendar date."""

from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

START = "<!--START_SECTION:profile-date-->"
END = "<!--END_SECTION:profile-date-->"
MONTHS = (
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
)


def refresh(content: str, now: datetime) -> str:
    if content.count(START) != 1 or content.count(END) != 1:
        raise ValueError("README must contain exactly one pair of profile-date markers")
    start = content.index(START) + len(START)
    end = content.index(END)
    if end < start:
        raise ValueError("Profile-date markers are out of order")
    local = now.astimezone(ZoneInfo("Asia/Jakarta"))
    date = f"{local.day:02d} {MONTHS[local.month - 1]} {local.year}"
    block = (
        f'\n<p align="center"><sub>{date} · WIB (UTC+7)</sub></p>\n'
    )
    return content[:start] + block + content[end:]


if __name__ == "__main__":
    path = Path(__file__).resolve().parents[2] / "README.md"
    content = path.read_text(encoding="utf-8")
    updated = refresh(content, datetime.now(ZoneInfo("Asia/Jakarta")))
    if updated != content:
        path.write_text(updated, encoding="utf-8")
