"""
Per-buy-box source memory for off-market discovery.

Tracks which sources (broker sites, marketplaces, single listings) have
been discovered for a given buy-box, when they last yielded results, and
auto-demotes sources that go quiet.

State is keyed by a stable hash of the buy-box JSON and persisted to
`offmarket/discovery/memory/{bbid}.json`. The memory directory is
gitignored — these are per-machine working files.
"""
from __future__ import annotations

import hashlib
import json
import os
import tempfile
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from typing import Optional

MEMORY_DIR = "offmarket/discovery/memory"
ZERO_YIELD_DEMOTE_THRESHOLD = 3


@dataclass
class SourceRecord:
    url: str
    name: str
    kind: str                       # "broker" | "marketplace" | "single-listing"
    asset_types: list[str] = field(default_factory=list)
    first_seen: str = ""            # ISO datetime
    last_seen: str = ""             # ISO — last time discovery surfaced it
    last_yielded_at: Optional[str] = None  # ISO — last successful (non-zero) scrape
    last_yield_count: int = 0       # most recent run's listing count
    total_yield: int = 0            # cumulative
    runs_with_zero: int = 0         # consecutive zero-yield runs
    status: str = "active"          # "active" | "demoted"
    notes: str = ""

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> "SourceRecord":
        return cls(**data)


# ---------- ids + paths ----------

def buy_box_id(buy_box: dict) -> str:
    """Stable 12-char hash of buy_box canonical JSON."""
    canonical = json.dumps(buy_box, sort_keys=True, separators=(",", ":"))
    return hashlib.sha1(canonical.encode()).hexdigest()[:12]


def memory_path(bbid: str) -> str:
    return os.path.join(MEMORY_DIR, f"{bbid}.json")


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _ensure_dir() -> None:
    os.makedirs(MEMORY_DIR, exist_ok=True)


# ---------- load / save ----------

def load_memory(bbid: str) -> list[SourceRecord]:
    """Returns [] if no memory file yet."""
    path = memory_path(bbid)
    if not os.path.exists(path):
        return []
    try:
        with open(path) as f:
            data = json.load(f)
    except (json.JSONDecodeError, OSError):
        return []
    records: list[SourceRecord] = []
    for item in data.get("sources", []):
        try:
            records.append(SourceRecord.from_dict(item))
        except TypeError:
            # Skip records with unexpected fields rather than crashing.
            continue
    return records


def save_memory(bbid: str, records: list[SourceRecord]) -> None:
    """Creates MEMORY_DIR if needed. Writes atomically (temp file + rename)."""
    _ensure_dir()
    path = memory_path(bbid)
    payload = {
        "bbid": bbid,
        "updated_at": _now_iso(),
        "sources": [r.to_dict() for r in records],
    }
    # Atomic write: temp file in same directory, then os.replace.
    fd, tmp_path = tempfile.mkstemp(
        prefix=f".{bbid}.", suffix=".tmp", dir=MEMORY_DIR
    )
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(payload, f, indent=2, sort_keys=True)
        os.replace(tmp_path, path)
    except Exception:
        if os.path.exists(tmp_path):
            try:
                os.remove(tmp_path)
            except OSError:
                pass
        raise


# ---------- mutations ----------

def _find(records: list[SourceRecord], url: str) -> Optional[SourceRecord]:
    for r in records:
        if r.url == url:
            return r
    return None


def upsert_source(bbid: str, url: str, **fields) -> SourceRecord:
    """Insert or update a source record.

    Sets first_seen on insert, always updates last_seen, and merges the
    provided ``fields`` (name, kind, asset_types, notes, status, …) onto
    the record. Persists to disk and returns the updated record.
    """
    records = load_memory(bbid)
    existing = _find(records, url)
    now = _now_iso()

    if existing is None:
        rec = SourceRecord(
            url=url,
            name=fields.get("name", url),
            kind=fields.get("kind", "broker"),
            asset_types=list(fields.get("asset_types", [])),
            first_seen=fields.get("first_seen", now),
            last_seen=now,
            last_yielded_at=fields.get("last_yielded_at"),
            last_yield_count=int(fields.get("last_yield_count", 0)),
            total_yield=int(fields.get("total_yield", 0)),
            runs_with_zero=int(fields.get("runs_with_zero", 0)),
            status=fields.get("status", "active"),
            notes=fields.get("notes", ""),
        )
        records.append(rec)
    else:
        existing.last_seen = now
        for key, value in fields.items():
            if key == "first_seen":
                continue  # immutable after creation
            if hasattr(existing, key):
                setattr(existing, key, value)
        rec = existing

    save_memory(bbid, records)
    return rec


def record_run_result(bbid: str, source_url: str, yielded: int) -> None:
    """After a run: update last_yield_count, total_yield, runs_with_zero.

    Auto-demotes (status='demoted') after ``ZERO_YIELD_DEMOTE_THRESHOLD``
    consecutive zero-yield runs. No-op if the source is unknown — call
    ``upsert_source`` first.
    """
    records = load_memory(bbid)
    rec = _find(records, source_url)
    if rec is None:
        return
    now = _now_iso()
    rec.last_seen = now
    rec.last_yield_count = int(yielded)
    if yielded > 0:
        rec.total_yield += int(yielded)
        rec.last_yielded_at = now
        rec.runs_with_zero = 0
        # Successful yield reactivates a previously demoted source.
        if rec.status == "demoted":
            rec.status = "active"
    else:
        rec.runs_with_zero += 1
        if rec.runs_with_zero >= ZERO_YIELD_DEMOTE_THRESHOLD:
            rec.status = "demoted"
    save_memory(bbid, records)


# ---------- queries ----------

def active_sources(bbid: str) -> list[SourceRecord]:
    """Return sources where status != 'demoted'."""
    return [r for r in load_memory(bbid) if r.status != "demoted"]


def novel_sources_since(bbid: str, since_iso: str) -> list[SourceRecord]:
    """Sources with first_seen > since_iso (lexicographic ISO compare)."""
    return [r for r in load_memory(bbid) if r.first_seen and r.first_seen > since_iso]
