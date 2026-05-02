---
name: costar-property-report
description: >
  Searches CoStar for a specific property address, captures key screenshots
  of the listing/comp data, and downloads the standard property report. Assumes
  an authenticated CoStar session is already open (use the costar-login skill
  first if not). Use this skill whenever Gideon asks for "a CoStar report on
  [address]", "pull comps for [address]", "research [address] on CoStar",
  "what does CoStar show for [address]", or any variation of pulling property
  intel from CoStar.
---

# CoStar Property Report

You're searching CoStar for a specific address, capturing screenshots of the
key data screens, and downloading the standard report.

## Inputs

- `address` — full property address (street, city, state, zip)

## Prerequisites

CoStar must be logged in. If you're not sure, run `costar-login` first.

## Step 1 — Navigate to the Properties search

The property search lives at:

```
https://product.costar.com/search/all-properties
```

Reach it from any post-login page by either:
- Clicking the **Properties** button in the top nav, OR
- Navigating directly to the URL above (faster, deterministic)

**Watch for 2FA:** clicking Properties from a fresh session typically
fires the SMS 2FA flow (see `costar-login` Step 3). If the agent hits
`secure.costargroup.com/mfa/otp/verify`, run the 2FA hand-off.

The search page UI:
- Header has a textbox **"Address or Location"** (single combined field —
  not separate street/city/state)
- An **Open** button next to it (opens an expanded search panel)
- A **"Listing Type"** combobox (For Sale, For Lease, etc.) — usually
  leave blank to see all listing types unless Gideon specifies
- A **Filters** link for advanced filtering
- A **Reports** button in the header — this is the export/download path
- A map region (defaults to a regional view based on user location/last
  search) and a list view toggle at `/search/all-properties/list-view/properties`

## Step 2 — Enter the address

Paste the full address into the "Address or Location" textbox. Autocomplete
suggestions appear as you type. Gideon's pattern:

> Paste address → autocomplete pops → press **Enter** (don't click a
> suggestion). Hitting Enter triggers a search of the local area, not a
> direct property match.

The page does NOT navigate to a single-property page. Instead, the URL
stays at `/search/all-properties` and the right side becomes a **list of
nearby properties** (typically dozens) while the map zooms to the
neighborhood of the address you entered. The header shows e.g.
**"47 Properties / 3 Spaces"** — the count of results.

Each list item card shows: address, city/state/zip, property type
(Office / Apartments / Storefront Retail / Warehouse / etc.), key specs
(SF, units, year built, renov year), and listing status (For Sale at
$X, etc.).

## Step 3 — Select the target property

The address you searched for is one of many in the list — find and click
the card that exactly matches the address Gideon (or the orchestrator)
specified. Clicking the card opens a **property detail panel on the
right side of the screen**, replacing or overlaying the list view.

If the exact address isn't in the visible list:
- Scroll the list — there may be more results below the fold
- Use the map zoom to verify you're in the right neighborhood
- If still missing, the address may be a non-listed property; tell
  Gideon and ask whether to pick the closest match or stop

## Step 4 — Capture the property detail

Once the detail panel is open on the right:

<TBD — capture during first run:
- What the detail panel layout looks like
- Which sections matter (overview, sale history, comps, tenant info,
  photos, financials)
- Where the photos are
- How to navigate between detail sections>

## Toolbar reference

The top toolbar above the property list contains the actions we'll use
in later steps:

- **Filters** — refine the result set (property type, price, etc.)
- **Sort** — re-order the list
- **Save** — save the search
- **Reports** ← **this is the report download path (Step 5)**
- **More** — additional options
- View toggles top right: **MAP | LIST | ANALYTICS**

## Sub-tabs

Just below the address bar there are dataset tabs that switch context:
- All Properties
- Multi-Family
- Shopping Centers
- Underwriting & Rent Survey Reports

Default is **All Properties** which is what we want for general property
research.

## Step 2 — Capture key screenshots

Once on the property page, capture screenshots of:

<TBD — capture during first run. Likely candidates:
- Property summary / overview
- Sale history / comps
- Tenant / occupancy info
- Tax & assessment
- Photos / location map>

Save each as `screenshots/{slug}-{section}.png` where `slug` is the address
slugified and `section` describes what's shown.

## Step 3 — Download the report

<TBD — capture during first run:
- Which export/report button to click
- What format (PDF / Excel / both?)
- How long the download takes
- Default filename CoStar gives the file
- Where the file lands>

Rename the downloaded file to `property-report-{slug}-{YYYY-MM-DD}.pdf` and
move it to the working directory the orchestrator passed in (or default to
`/Users/gideonspencer/dealhound-pro/property-data/properties/{slug}/`).

## Output

Return to the caller:
- `slug` — the address slug used for filenames
- `report_path` — absolute path to the downloaded report
- `screenshot_paths` — list of screenshot paths
- `summary_bullets` — 3-5 bullet points pulled directly from the property page (asking
  price, sqft, year built, last sale, occupancy — whatever CoStar displays
  prominently). This becomes the email body and the archive's summary.md.

## Edge cases

- **Address not found**: tell Gideon the search came back empty and stop.
  Don't guess at a similar address.
- **Multiple matches**: present the matches to Gideon and ask which one.
- **Report unavailable for this property type**: capture screenshots and the
  property page as a PDF instead, and note the limitation in the summary.
