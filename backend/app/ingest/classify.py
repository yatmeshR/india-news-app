import re

from ..constants import CATEGORY_KEYWORDS, STATE_KEYWORDS

GENERIC_CATEGORIES = {"top", "india"}


def _count(keyword: str, text: str) -> int:
    return len(re.findall(r"(?<!\w)" + re.escape(keyword.strip()) + r"(?!\w)", text))


def classify_category(default: str, title: str, summary: str) -> str:
    """Refine generic feeds (top/india) using keywords; specific feeds keep their category."""
    if default not in GENERIC_CATEGORIES:
        return default
    t, s = title.lower(), summary.lower()
    best, best_score = default, 0
    for category, keywords in CATEGORY_KEYWORDS.items():
        score = sum(2 * _count(k, t) + _count(k, s) for k in keywords)
        if score > best_score:
            best, best_score = category, score
    return best if best_score >= 2 else default


def detect_state(default: str | None, title: str, summary: str) -> str | None:
    t, s = title.lower(), summary.lower()
    best, best_score = default, 0
    for state, keywords in STATE_KEYWORDS.items():
        score = sum(2 * _count(k, t) + _count(k, s) for k in keywords)
        if score > best_score:
            best, best_score = state, score
    return best
