"""
Universal listing extractor. Sends page text to Claude Sonnet,
returns structured listing data. Works on any real estate listing page
with zero per-site configuration.
"""
import json
import os
import re
from anthropic import AsyncAnthropic

def _get_client():
    """Lazy-init the Anthropic client so imports don't fail without a key."""
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not key:
        raise EnvironmentError("ANTHROPIC_API_KEY is not set")
    return AsyncAnthropic(api_key=key)

EXTRACTION_MODEL = "claude-sonnet-4-20250514"

EXTRACTION_PROMPT = """You are extracting real estate property listings from a webpage.
Extract EVERY listing visible on this page. Do not filter or skip any listing.
If the page has no property listings, return an empty array.

For each listing, extract these fields (use null if not visible on the page):
- title: property name or headline text
- price: integer dollar amount (no commas, no $). null if not shown.
- price_raw: original price text exactly as shown (e.g. "$1,200,000")
- location: "City, State" format
- address: street address if visible. null if not shown.
- url: full URL to the individual listing detail page. Match each listing to a link from the PAGE LINKS section below using location, price, or address cues in the link text or URL path. If relative, prefix with the site domain. null only if no link can be matched.
- acreage: number (float). null if not shown.
- rooms_keys: number of rooms, units, or keys (integer). null if not shown.
- revenue_hint: any revenue, income, or cash flow text. null if none.
- dom_hint: days on market or date listed. null if not shown.
- condition_hint: any signals about condition (turnkey, fixer, as-is, renovated). null if none.
- description: first 300 characters of the listing description. null if none.
- property_type: best guess (resort, hotel, cabin, lodge, campground, rv park, land, etc). null if unclear.

Return ONLY a JSON array of objects. No markdown, no explanation, no preamble.
If zero listings found, return: []

PAGE URL: {source_url}
{links_section}
PAGE TEXT:
{page_text}"""

LISTING_SCHEMA = {
    "title": None, "price": None, "price_raw": None, "location": None,
    "address": None, "url": None, "acreage": None, "rooms_keys": None,
    "revenue_hint": None, "dom_hint": None, "condition_hint": None,
    "description": None, "property_type": None, "source": None,
}


async def extract_listings_from_page_text(
    page_text: str,
    source_url: str,
    source_name: str,
    page_links: list[dict] | None = None,
    max_text_chars: int = 100_000,
) -> list[dict]:
    """
    Universal extractor. Works on any site. No CSS selectors.

    Args:
        page_text: Raw text from document.body.innerText (no HTML tags)
        source_url: The URL this page was loaded from
        source_name: Slug for the source site (e.g. "bizbuysell")
        page_links: List of {href, text} dicts extracted from <a> tags on the page.
                    Passed separately because innerText strips href attributes.
        max_text_chars: Truncate page text to this length to control token cost

    Returns:
        List of listing dicts matching the standard schema.
        Empty list if no listings found or extraction fails.
    """
    truncated = page_text[:max_text_chars]

    # Build links section for the prompt so Claude can match listings to URLs
    links_section = ""
    if page_links:
        link_lines = []
        for link in page_links[:200]:  # cap at 200 to control token cost
            href = link.get("href", "")
            text = link.get("text", "")
            if href and text:
                link_lines.append(f"  {href}  |  {text}")
        if link_lines:
            links_section = "PAGE LINKS (href | link text):\n" + "\n".join(link_lines)

    prompt = EXTRACTION_PROMPT.format(
        source_url=source_url,
        page_text=truncated,
        links_section=links_section,
    )

    try:
        response = await _get_client().messages.create(
            model=EXTRACTION_MODEL,
            max_tokens=8192,
            messages=[{"role": "user", "content": prompt}],
        )

        raw_text = response.content[0].text.strip()
        # Handle markdown code blocks if model wraps response
        raw_text = re.sub(r"^```[a-z]*\n?", "", raw_text)
        raw_text = re.sub(r"\n?```$", "", raw_text).strip()

        listings = json.loads(raw_text)

        if not isinstance(listings, list):
            return []

        # Normalize: ensure all schema fields exist, set source
        normalized = []
        for item in listings:
            listing = {**LISTING_SCHEMA, **item}
            listing["source"] = source_name
            # Ensure price is int or None
            if listing["price"] is not None:
                try:
                    listing["price"] = int(
                        float(str(listing["price"]).replace(",", "").replace("$", ""))
                    )
                except (ValueError, TypeError):
                    listing["price"] = None
            # Ensure acreage is float or None
            if listing["acreage"] is not None:
                try:
                    listing["acreage"] = float(
                        str(listing["acreage"]).replace(",", "")
                    )
                except (ValueError, TypeError):
                    listing["acreage"] = None
            normalized.append(listing)

        return normalized

    except (json.JSONDecodeError, IndexError, KeyError) as e:
        print(f"[claude_extract] Parse error for {source_url}: {e}")
        return []
    # Anthropic API errors (AuthenticationError, RateLimitError, etc.) propagate
