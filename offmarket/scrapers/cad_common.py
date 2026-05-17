"""Shared helpers for CAD/Comptroller scrapers."""

import datetime
import json
import os
import pathlib
import re
from typing import Callable

_REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
_CACHE_ROOT = pathlib.Path(__file__).resolve().parent.parent / "cache"
_DATA_ROOT = pathlib.Path(__file__).resolve().parent.parent / "data"


# ---------------------------------------------------------------------------
# Cache helpers
# ---------------------------------------------------------------------------

def cache_path(portal: str, key: str) -> pathlib.Path:
    """Absolute path: <repo>/offmarket/cache/{portal}/{key}.json."""
    return _CACHE_ROOT / portal / f"{key}.json"


def load_cached(portal: str, key: str, fresh_until_map: dict[str, str] | None = None) -> dict | None:
    """Return cached payload or None if missing / stale / corrupt."""
    path = cache_path(portal, key)
    if not path.exists():
        return None
    try:
        with path.open("r", encoding="utf-8") as fh:
            payload = json.load(fh)
    except (json.JSONDecodeError, OSError):
        return None
    if fresh_until_map is None:
        return payload
    today = datetime.date.today()
    stored = payload.get("fresh_until", {})
    for field in fresh_until_map:
        raw = stored.get(field)
        if raw is None:
            return None
        try:
            if datetime.date.fromisoformat(raw) < today:
                return None
        except (ValueError, TypeError):
            return None
    return payload


def write_cached(portal: str, key: str, payload: dict) -> None:
    """Atomic write to cache. Creates parent dir if missing."""
    path = cache_path(portal, key)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".json.tmp")
    with tmp.open("w", encoding="utf-8") as fh:
        json.dump(payload, fh, indent=2, default=str)
    os.replace(tmp, path)


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

def log_factory(portal: str) -> Callable[[str], None]:
    """Returns a logger that appends to offmarket/cache/logs/{portal}.log and prints."""
    log_path = _CACHE_ROOT / "logs" / f"{portal}.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)

    def _log(msg: str) -> None:
        ts = datetime.datetime.now().isoformat(timespec="seconds")
        line = f"{ts}  {msg}"
        print(line)
        with log_path.open("a", encoding="utf-8") as fh:
            fh.write(line + "\n")

    return _log


# ---------------------------------------------------------------------------
# Target loading
# ---------------------------------------------------------------------------

def load_targets(vertical: str, county_filter: list[str] | None = None) -> list[dict]:
    """Load offmarket/data/{vertical}_targets.json. Raises FileNotFoundError if missing."""
    path = _DATA_ROOT / f"{vertical}_targets.json"
    if not path.exists():
        raise FileNotFoundError(f"No targets file for vertical '{vertical}': {path}")
    with path.open("r", encoding="utf-8") as fh:
        data = json.load(fh)
    # Support both bare list and {"businesses": [...]} envelope
    if isinstance(data, list):
        targets = data
    else:
        targets = data.get("businesses", data)
    if county_filter is None:
        return targets
    cf_lower = [c.lower() for c in county_filter]
    return [t for t in targets if (t.get("county") or "").lower() in cf_lower]


# ---------------------------------------------------------------------------
# Entity keys — vertical-aware identifier for cache + logging
# ---------------------------------------------------------------------------

# Canonical identifier field per vertical. New verticals add an entry here.
_VERTICAL_KEY_FIELD = {
    "pest-control": "tpcl",
    "dental": "license_number",
    "fire-life-safety": "license_number",
}


def entity_key(target: dict, vertical: str) -> str:
    """Vertical-specific stable identifier for this target (e.g. TPCL, license number).

    Falls back to any common id field if the vertical's canonical field is missing.
    """
    field = _VERTICAL_KEY_FIELD.get(vertical)
    if field and target.get(field):
        return str(target[field])
    for k in ("tpcl", "license_number", "npi", "id"):
        if target.get(k):
            return str(target[k])
    raise KeyError(
        f"No entity_key for vertical={vertical!r} in target with keys {list(target.keys())[:6]}"
    )


def cache_key(target: dict, vertical: str) -> str:
    """Vertical-namespaced cache key. Prevents collision when ids overlap across verticals."""
    return f"{vertical}__{entity_key(target, vertical)}"


# ---------------------------------------------------------------------------
# Cloudflare challenge detection — shared across all CAD scrapers behind CF
# ---------------------------------------------------------------------------

# Ordered from most specific to most general. Any single hit = challenge page.
_CF_MARKERS = [
    "cf-challenge-form",
    "jschl-answer",
    "cf_clearance",
    "cf-spinner",
    "challenges.cloudflare.com",
    "Checking your browser",
    "Ray ID",
]


def is_cloudflare_challenge(html: str) -> bool:
    """True if html looks like a Cloudflare challenge page.

    Scans for known marker strings — one strong signal is sufficient.
    Used by any scraper that hits a CF-protected portal (HCAD, BCAD, future).
    """
    if not html:
        return False
    for marker in _CF_MARKERS:
        if marker in html:
            return True
    return False


# ---------------------------------------------------------------------------
# Name variants
# ---------------------------------------------------------------------------

def name_variants(legal_name: str | None, owner_name: str | None) -> list[tuple[str, str | None]]:
    """Return ordered (last, first|None) tuples to try against CAD search, deduped."""
    seen: set[tuple[str, str | None]] = set()
    results: list[tuple[str, str | None]] = []

    def _add(last: str, first: str | None) -> None:
        last = last.strip()
        first = first.strip() if first else None
        if not last:
            return
        key = (last.lower(), (first or "").lower())
        if key not in seen:
            seen.add(key)
            results.append((last, first))

    # --- owner_name handling ---
    if owner_name:
        name = owner_name.strip()
        # Strip honorifics / credentials
        name = re.sub(r'^(Dr\.?|Mr\.?|Mrs\.?|Ms\.?|Prof\.?)\s+', '', name, flags=re.I)
        name = re.sub(r'\s+(DDS|DMD|MD|DO|DVM|JD|CPA|PA|PLLC|LLC|Inc\.?)$', '', name, flags=re.I)
        if "," in name:
            # "Last, First" form
            parts = name.split(",", 1)
            _add(parts[0].strip(), parts[1].strip() or None)
        else:
            parts = name.split()
            if len(parts) >= 2:
                _add(parts[-1], parts[0])
            elif len(parts) == 1:
                _add(parts[0], None)

    # --- legal_name handling ---
    if legal_name:
        ln = legal_name.strip()
        # Strip business suffixes to extract surname
        cleaned = re.sub(
            r'\s+(LLC|Inc\.?|Corp\.?|Ltd\.?|P\.?A\.?|P\.?L\.?L\.?C\.?|DDS|DMD|MD|DO|DVM|PC|PLLC|LP|LLP)\.?$',
            '', ln, flags=re.I
        )
        # Remove generic business words at end
        cleaned = re.sub(
            r'\s+(Pest\s+Control|Dental|Dentistry|Dentist|Orthodontics|Orthodontist|'
            r'Services?|Solutions?|Associates?|Group|Practice|Center|Clinic|'
            r'Fire|Safety|Medical|Consulting|Management|Properties?|Holdings?).*$',
            '', cleaned, flags=re.I
        ).strip()
        # Strip trailing credentials
        cleaned = re.sub(r',?\s+(DDS|DMD|MD|DO|DVM|JD|CPA)\.?$', '', cleaned, flags=re.I).strip()

        if "," in cleaned:
            parts = cleaned.split(",", 1)
            _add(parts[0].strip(), parts[1].strip() or None)
        else:
            parts = cleaned.split()
            if len(parts) == 1:
                _add(parts[0], None)
            elif len(parts) == 2:
                # Could be "First Last" or "Last First" — try both
                _add(parts[1], parts[0])  # assume "First Last"
                _add(parts[0], parts[1])  # "Last First" backup
            elif len(parts) >= 3:
                # "John A. Doe" or "Mary Beth Smith"
                _add(parts[-1], parts[0])
                # Multi-word last name: "Van Der Berg" — try last two words
                if len(parts) >= 3:
                    _add(" ".join(parts[-2:]), parts[0])

    return results


# ---------------------------------------------------------------------------
# Exemption extraction
# ---------------------------------------------------------------------------

_BEXAR_OV65_PROXY_THRESHOLD = 6000  # USD tax-savings ratio that strongly indicates OV65


def extract_exemptions(text: str) -> dict:
    """Extract OV65/homestead/disabled flags and property data from CAD page text.

    Returns:
      ov65                       — bool, True if "OV65" / "OVER 65" appears explicitly.
      ov65_inferred              — bool, True if a proxy fires even when "OV65" is absent.
                                   See "Bexar OTHER + tax-savings proxy" and "DCAD Tax Ceiling line".
      ov65_inference_source      — str | None, name of the proxy that fired.
      ov65_any                   — bool, ov65 OR ov65_inferred (convenience for scoring).
      tax_savings_amount         — int | None, dollar amount of with-exempt vs without-exempt savings
                                   parsed from Bexar property pages.
      tax_ceiling                — bool, True if "Tax Ceiling" line is present (DCAD's OV65 marker).
      homestead, disabled, deed_date, year_built, appraised_value — as before.
    """
    result: dict = {
        "ov65": False,
        "ov65_inferred": False,
        "ov65_inference_source": None,
        "ov65_any": False,
        "tax_savings_amount": None,
        "tax_ceiling": False,
        "homestead": False,
        "disabled": False,
        "deed_date": None,
        "year_built": None,
        "appraised_value": None,
    }
    if not text:
        return result

    try:
        result["ov65"] = bool(re.search(r'\b(?:OV65|OVER\s*65|OVER-65|OV-65)\b', text, re.I))
    except Exception:
        pass

    try:
        result["homestead"] = bool(re.search(r'\b(?:HOMESTEAD|HS\s+EXEMPT|GEN\s+HS)\b', text, re.I))
    except Exception:
        pass

    try:
        result["disabled"] = bool(re.search(r'\bDISABLED\b', text, re.I))
    except Exception:
        pass

    try:
        m = re.search(r'Deed\s+Date.{0,200}?(\d{2}/\d{2}/\d{4})', text, re.I | re.S)
        if m:
            result["deed_date"] = m.group(1)
    except Exception:
        pass

    try:
        m = re.search(r'Year\s+Built\D{0,10}(\d{4})', text, re.I)
        if m:
            result["year_built"] = int(m.group(1))
    except Exception:
        pass

    try:
        m = re.search(r'(?:Appraised\s+Value|Total\s+Value)\D{0,20}([\d,]+)', text, re.I)
        if m:
            result["appraised_value"] = int(m.group(1).replace(",", ""))
    except Exception:
        pass

    # ------------------------------------------------------------------
    # OV65 proxies (Finding 3, 2026-05-15 deep-dive)
    # ------------------------------------------------------------------
    # Proxy 1 — Bexar "OTHER" exemption + tax-savings ratio.
    # Bexar property pages list exemption codes like "HS, OTHER" and a tax
    # comparison row ("with-exempt $1,977.80 vs without-exempt $8,185.58").
    # OV65 freezes the school-district tax ceiling, producing $6K+ savings
    # vs the unfrozen amount. $6K threshold is the empirically observed
    # Bexar floor (Whitaker Insurance, May 2026 deep-dive: $6,207 = OV65).
    try:
        has_other = bool(re.search(r'(?<![A-Z])OTHER(?![A-Z])', text))
        savings = _parse_bexar_tax_savings(text)
        if savings is not None:
            result["tax_savings_amount"] = savings
        if has_other and savings is not None and savings >= _BEXAR_OV65_PROXY_THRESHOLD:
            result["ov65_inferred"] = True
            result["ov65_inference_source"] = "bexar_other_exemption_savings_proxy"
    except Exception:
        pass

    # Proxy 2 — DCAD "Tax Ceiling" line.
    # Dallas CAD displays "Tax Ceiling" (school + county) when an Over-65 or
    # Disabled-Person freeze is in place. Pure presence of the phrase is the
    # signal — DCAD does not separately label OV65 vs Disabled, but combined
    # with deed-age > 15 yrs it's a strong OV65 proxy. The orchestrator can
    # tighten with "OTHER EXEMPTION" amount matching ($60K/$100K Dallas County
    # OV65 amounts) if needed.
    try:
        if re.search(r'\bTax\s+Ceiling\b', text, re.I):
            result["tax_ceiling"] = True
            if not result["ov65"] and not result["ov65_inferred"]:
                result["ov65_inferred"] = True
                result["ov65_inference_source"] = "dcad_tax_ceiling_line"
    except Exception:
        pass

    result["ov65_any"] = bool(result["ov65"] or result["ov65_inferred"])

    return result


def _parse_bexar_tax_savings(text: str) -> int | None:
    """Parse the with-exempt-vs-without-exempt savings ratio from Bexar pages.

    Bexar shows two tax-due rows on the property detail page:
      "Tax Due (with exemption): $1,977.80"
      "Tax Due (without exemption): $8,185.58"
    Returns the integer dollar difference, or None if either side is missing.
    """
    if not text:
        return None
    try:
        with_m = re.search(
            r'(?:Tax\s+Due\s*\(?\s*with[\s\-]*exempt(?:ion)?\)?|with[\s\-]*exempt(?:ion)?\s*tax)\D{0,40}'
            r'\$?\s*([\d,]+(?:\.\d{1,2})?)',
            text, re.I
        )
        without_m = re.search(
            r'(?:Tax\s+Due\s*\(?\s*without[\s\-]*exempt(?:ion)?\)?|without[\s\-]*exempt(?:ion)?\s*tax)\D{0,40}'
            r'\$?\s*([\d,]+(?:\.\d{1,2})?)',
            text, re.I
        )
        if not (with_m and without_m):
            return None
        with_amt = float(with_m.group(1).replace(",", ""))
        without_amt = float(without_m.group(1).replace(",", ""))
        diff = without_amt - with_amt
        if diff < 0:
            return None
        return int(round(diff))
    except Exception:
        return None


# ---------------------------------------------------------------------------
# Summary histogram
# ---------------------------------------------------------------------------

def summary(results: dict[str, dict], log: Callable[[str], None]) -> None:
    """Log status histogram from results dict."""
    counts: dict[str, int] = {}
    for rec in results.values():
        status = rec.get("status", "unknown")
        counts[status] = counts.get(status, 0) + 1
    total = sum(counts.values())
    for status, n in sorted(counts.items(), key=lambda x: -x[1]):
        pct = (n / total * 100) if total else 0
        log(f"{status}: {n} ({pct:.0f}%)")
    log(f"Total: {total}")
