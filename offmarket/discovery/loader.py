"""
Supabase persistence stub — idempotent upsert for discovered_listings.

Uses SUPABASE_PAT (personal access token) via HTTP REST API.
Insert-or-ignore on (source, url) — the natural dedup key.

Requires:
  SUPABASE_URL  — project URL (e.g. https://xxxx.supabase.co)
  SUPABASE_KEY  — anon/service key  OR
  SUPABASE_PAT  — personal access token (preferred for bulk writes per CLAUDE.md)
"""
from __future__ import annotations

import json
import logging
import os
from typing import Optional

import requests

from offmarket.discovery.base import Listing

logger = logging.getLogger(__name__)

SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_PAT") or os.environ.get("SUPABASE_KEY", "")
TABLE = "discovered_listings"


def upsert(listings: list[Listing], dry_run: bool = False) -> dict:
    """
    Idempotently insert listings into Supabase discovered_listings table.
    Skips rows where (source, url) already exist.

    Args:
        listings: normalized listing objects
        dry_run: if True, print payload but don't write

    Returns:
        {"inserted": N, "skipped": N, "errors": N}
    """
    if not listings:
        return {"inserted": 0, "skipped": 0, "errors": 0}

    if not SUPABASE_URL or not SUPABASE_KEY:
        logger.warning(
            "SUPABASE_URL / SUPABASE_PAT not set — skipping persistence. "
            "Set env vars to enable Supabase writes."
        )
        return {"inserted": 0, "skipped": len(listings), "errors": 0}

    rows = [_to_row(l) for l in listings]

    if dry_run:
        print(json.dumps(rows[:3], indent=2))
        print(f"[dry_run] Would upsert {len(rows)} rows")
        return {"inserted": 0, "skipped": 0, "errors": 0}

    endpoint = f"{SUPABASE_URL}/rest/v1/{TABLE}"
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "resolution=ignore-duplicates,return=minimal",
    }

    # Batch in chunks of 100 to stay within payload limits
    chunk_size = 100
    inserted = 0
    errors = 0

    for i in range(0, len(rows), chunk_size):
        chunk = rows[i : i + chunk_size]
        try:
            r = requests.post(endpoint, headers=headers, json=chunk, timeout=30)
            if r.status_code in (200, 201):
                inserted += len(chunk)
                logger.info("Upserted chunk %d-%d (%d rows)", i, i + len(chunk), len(chunk))
            else:
                logger.error(
                    "Supabase upsert failed: HTTP %d — %s", r.status_code, r.text[:200]
                )
                errors += len(chunk)
        except requests.RequestException as exc:
            logger.error("Supabase request failed: %s", exc)
            errors += len(chunk)

    return {"inserted": inserted, "skipped": 0, "errors": errors}


def _to_row(listing: Listing) -> dict:
    return {
        "source": listing.source,
        "url": listing.url,
        "title": listing.title,
        "location": listing.location,
        "asking_price": listing.asking_price,
        "asset_type": listing.asset_type,
        "size_metric": listing.size_metric,
        "description": listing.description,
        "posted_date": listing.posted_date,
        "broker_name": listing.broker_name,
        "broker_phone": listing.broker_phone,
        "broker_email": listing.broker_email,
        "scraped_at": listing.scraped_at,
    }
