import string

_STOP = {"the", "a", "an", "of", "in", "on", "to", "and", "for", "at", "is", "as", "by", "with", "from"}
_PUNCT = string.punctuation + "।“”‘’…–—"


def title_tokens(title: str) -> frozenset[str]:
    # str.split (not \w regex) so Devanagari words with combining marks stay intact
    tokens = (w.strip(_PUNCT).lower() for w in title.split())
    return frozenset(t for t in tokens if t and t not in _STOP)


def jaccard(a: frozenset[str], b: frozenset[str]) -> float:
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)


class NearDupIndex:
    """Detects the same story reported by different outlets (similar headlines)."""

    def __init__(self, threshold: float = 0.7):
        self.threshold = threshold
        self._titles: list[frozenset[str]] = []

    def add(self, title: str) -> None:
        self._titles.append(title_tokens(title))

    def is_duplicate(self, title: str) -> bool:
        tokens = title_tokens(title)
        if len(tokens) < 4:  # too short to compare reliably
            return False
        return any(jaccard(tokens, other) >= self.threshold for other in self._titles)
