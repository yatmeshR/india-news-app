from app.ingest.classify import classify_category, detect_state
from app.ingest.dedupe import NearDupIndex
from app.ingest.text import normalize_url, summarise, url_hash


def test_normalize_strips_tracking_and_fragment():
    a = "https://Example.com/news/story/?utm_source=x&id=1#top"
    b = "https://example.com/news/story?id=1"
    assert normalize_url(a) == b
    assert url_hash(a) == url_hash(b)


def test_summary_capped_at_60_words():
    text = " ".join(["Word"] * 200) + "."
    out = summarise("Title", text, 60)
    assert len(out.replace("…", "").split()) <= 60


def test_summary_uses_leading_sentences_and_strips_html():
    html = "<p>First sentence here. Second one follows. Third one too.</p>"
    out = summarise("Title", html, 60)
    assert out.startswith("First sentence here.")
    assert "<" not in out


def test_summary_empty_when_same_as_title():
    assert summarise("Same", "Same", 60) == ""


def test_near_duplicate_titles():
    idx = NearDupIndex()
    idx.add("RBI keeps repo rate unchanged at 6.5 per cent in policy review")
    assert idx.is_duplicate("RBI keeps repo rate unchanged at 6.5 per cent in latest policy review")
    assert not idx.is_duplicate("India beat Australia by five wickets in first T20 match")


def test_hindi_titles_tokenised():
    idx = NearDupIndex()
    idx.add("भारत ने ऑस्ट्रेलिया को पांच विकेट से हराया पहले मैच में")
    assert idx.is_duplicate("भारत ने ऑस्ट्रेलिया को पांच विकेट से हराया पहले मैच में जीत")


def test_category_refined_only_for_generic_feeds():
    assert classify_category("india", "IPL 2027 auction: BCCI announces date", "cricket franchises") == "sports"
    assert classify_category("business", "IPL 2027 auction: BCCI announces date", "cricket franchises") == "business"


def test_state_detection():
    assert detect_state(None, "Heavy rain lashes Mumbai, Pune", "") == "Maharashtra"
    assert detect_state(None, "Parliament passes new bill", "") is None
