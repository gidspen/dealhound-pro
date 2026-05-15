#!/usr/bin/env python3
"""DCAD owner search → OV65 + homestead + deed date for Dallas County pest businesses.

Strategy: ASP.NET form at https://www.dallascad.org/SearchOwner.aspx
After visiting homepage for cookies, POST owner name → results table with account # + address.
Click into top match → detail page has exemptions and deed history.
"""
import json
import time
from datetime import datetime, timezone
from pathlib import Path
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

TARGETS = Path('/Users/gideonspencer/dealhound-pro/offmarket/data/pest-control_targets.json')
OUT = Path('/tmp/pestrun_results/dcad_results.json')
LOG = Path('/tmp/pestrun_results/dcad.log')

def log(msg):
    ts = datetime.now(timezone.utc).strftime('%H:%M:%S')
    line = f"[{ts}] [DCAD] {msg}"
    print(line, flush=True)
    with open(LOG, 'a') as f:
        f.write(line + '\n')

def search_dcad(page, last_name, first_name=None):
    """Search by owner name; returns list of result rows or empty."""
    # Build search term: "LASTNAME, FIRSTNAME" or just lastname
    search_term = f"{last_name}, {first_name}" if first_name else last_name
    try:
        page.goto("https://www.dallascad.org/SearchOwner.aspx", wait_until='domcontentloaded', timeout=20000)
        page.fill('input[name="txtOwnerName"]', search_term)
        page.click('input[name="cmdSubmit"]')
        page.wait_for_load_state('domcontentloaded', timeout=15000)
        time.sleep(1)
    except PWTimeout:
        return [], "timeout_on_search"
    except Exception as e:
        return [], f"err_{type(e).__name__}"

    # Extract result rows. DCAD results page has a table with results.
    try:
        rows = page.evaluate("""
        () => {
            // Try grid-like tables; results have account numbers like 17 digits or similar
            const tables = Array.from(document.querySelectorAll('table'));
            for (const t of tables) {
                const trs = Array.from(t.querySelectorAll('tr'));
                if (trs.length < 2) continue;
                // First row has headers
                const dataRows = trs.slice(1).map(r => {
                    const cells = Array.from(r.querySelectorAll('td'));
                    if (cells.length < 2) return null;
                    // Find anchor (link to detail)
                    const a = r.querySelector('a');
                    return {
                        cells: cells.map(c => c.innerText.trim()),
                        link: a ? a.href : null,
                        account: a ? a.innerText.trim() : null
                    };
                }).filter(x => x && x.cells.length >= 2);
                if (dataRows.length > 0) return dataRows;
            }
            return [];
        }
        """)
        return rows, None
    except Exception as e:
        return [], f"parse_err_{type(e).__name__}"

def get_detail(page, link_url):
    """Visit detail page for an account; extract OV65, homestead, deed info."""
    try:
        page.goto(link_url, wait_until='domcontentloaded', timeout=20000)
        time.sleep(1)
        info = page.evaluate("""
        () => {
            const text = document.body.innerText;
            // Heuristics: look for "OVER 65" / "OVER-65" / "HS" / "HOMESTEAD"
            const has_ov65 = /\\b(?:OV65|OVER\\s*65|OVER-65|OV-65)\\b/i.test(text);
            const has_hs = /\\b(?:HOMESTEAD|HS\\s+EXEMPT|HS EXEMPT|GEN HS)\\b/i.test(text);
            const has_disabled = /\\bDISABLED\\b/i.test(text);
            // Find exemptions area
            const exemptionMatch = text.match(/EXEMPTIONS?[:\\s]+([^\\n]{0,200})/i);
            // Find deed date
            const deedMatch = text.match(/DEED\\s+DATE[:\\s]+(\\d{1,2}\\/\\d{1,2}\\/\\d{4})/i);
            // Find address
            const ownerMatch = text.match(/OWNER[:\\s]+([^\\n]{0,80})/i);
            const addressMatch = text.match(/(SITUS|PROPERTY)\\s+ADDRESS[:\\s]+([^\\n]{0,80})/i);
            const mailingMatch = text.match(/MAILING\\s+ADDRESS[:\\s]+([^\\n]{0,150})/i);
            const buildYearMatch = text.match(/YEAR\\s+BUILT[:\\s]+(\\d{4})/i);
            const apprValMatch = text.match(/APPRAISED\\s+VALUE[:\\s]+\\$?([\\d,]+)/i);
            return {
                has_ov65,
                has_homestead: has_hs,
                has_disabled,
                exemption_text: exemptionMatch ? exemptionMatch[1].trim() : null,
                deed_date: deedMatch ? deedMatch[1] : null,
                owner: ownerMatch ? ownerMatch[1].trim() : null,
                situs_address: addressMatch ? addressMatch[2].trim() : null,
                mailing_address: mailingMatch ? mailingMatch[1].trim() : null,
                year_built: buildYearMatch ? buildYearMatch[1] : null,
                appraised_value: apprValMatch ? apprValMatch[1] : null,
                page_text_sample: text.slice(0, 800),
            };
        }
        """)
        return info, None
    except Exception as e:
        return None, f"detail_err_{type(e).__name__}_{str(e)[:60]}"

def name_to_last_first(legal_name):
    """Convert 'DAVID FINCANNON' or 'A ALL PEST TERMITE EXTERM INC' to lastname guess."""
    parts = legal_name.strip().split()
    if not parts:
        return None, None
    # If has corp markers, return full name (search by org)
    if any(m in legal_name.upper() for m in ['INC', 'LLC', 'CORP', 'CORPORATION', 'COMPANY', 'LTD']):
        return None, None  # let caller use full name
    # Person name: last word is lastname
    return parts[-1], parts[0]

def lookup_one(page, biz):
    """Look up a Dallas County business owner; return enrichment dict."""
    legal = biz['legal_name']
    owner = biz.get('owner_name') or legal
    result = {
        'legal_name': legal,
        'owner_name': owner,
        'tpcl': biz['tpcl'],
        'searches': [],
        'fetched_at': datetime.now(timezone.utc).isoformat(),
    }

    # Build search list: try [owner_name "last, first"], [owner_name as-is], [legal_name]
    search_terms = []
    last, first = name_to_last_first(owner)
    if last:
        search_terms.append((last, first))
    search_terms.append((owner, None))  # full as-is
    if legal != owner:
        search_terms.append((legal, None))

    rows = []
    matched_term = None
    for last_or_full, first in search_terms:
        these_rows, err = search_dcad(page, last_or_full, first)
        result['searches'].append({
            'term': f"{last_or_full},{first}" if first else last_or_full,
            'rows': len(these_rows),
            'err': err
        })
        if these_rows:
            rows = these_rows
            matched_term = last_or_full
            break

    if not rows:
        result['dcad_status'] = 'No Match'
        return result

    # Filter rows: look for ones with owner's last name + a Dallas-area zip
    # Find best match — pick the one with homestead exemption if available, else first
    result['dcad_status'] = 'Search Matched'
    result['rows_count'] = len(rows)
    result['matched_term'] = matched_term

    # Pick best: prefer rows where owner string contains the last name
    target_last = (last or '').upper() if last else (owner.split()[-1] if owner else '').upper()
    best = None
    for r in rows[:30]:
        row_text = ' '.join(r['cells']).upper()
        if target_last and target_last in row_text:
            best = r
            break
    if not best:
        best = rows[0]

    result['top_row'] = best['cells']
    result['detail_link'] = best.get('link')
    result['account'] = best.get('account')

    # Fetch detail if we have a link
    if best.get('link'):
        detail, err = get_detail(page, best['link'])
        if detail:
            result.update({
                'cad_ov65': detail.get('has_ov65'),
                'cad_homestead': detail.get('has_homestead'),
                'cad_disabled': detail.get('has_disabled'),
                'cad_exemption_text': detail.get('exemption_text'),
                'cad_deed_date': detail.get('deed_date'),
                'cad_owner': detail.get('owner'),
                'cad_situs_address': detail.get('situs_address'),
                'cad_mailing_address': detail.get('mailing_address'),
                'cad_year_built': detail.get('year_built'),
                'cad_appraised_value': detail.get('appraised_value'),
                'cad_page_sample': detail.get('page_text_sample'),
            })
            result['dcad_status'] = 'Detail Fetched'
        else:
            result['detail_error'] = err
    return result

def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    LOG.unlink(missing_ok=True)

    with open(TARGETS) as f:
        data = json.load(f)
    dallas = [b for b in data['businesses'] if 'DALLAS' in b['county'].upper()]
    log(f"Processing {len(dallas)} Dallas County businesses")

    results = {}
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        ctx = browser.new_context(
            user_agent="Mozilla/5.0 (Macintosh) Chrome/120.0.0.0",
            viewport={'width': 1280, 'height': 800}
        )
        page = ctx.new_page()
        # Warm up with homepage visit for cookies
        page.goto("https://www.dallascad.org/", wait_until='domcontentloaded', timeout=20000)

        for i, biz in enumerate(dallas, 1):
            try:
                r = lookup_one(page, biz)
            except Exception as e:
                r = {'legal_name': biz['legal_name'], 'tpcl': biz['tpcl'],
                     'dcad_status': 'Error', 'error': f"{type(e).__name__}: {str(e)[:120]}"}
            results[biz['tpcl']] = r
            ov65 = r.get('cad_ov65', '?')
            hs = r.get('cad_homestead', '?')
            log(f"[{i}/{len(dallas)}] {biz['legal_name'][:30]:32s} → {r.get('dcad_status','?'):20s} OV65={ov65} HS={hs}")
            # Save every 3
            if i % 3 == 0:
                with open(OUT, 'w') as f:
                    json.dump(results, f, indent=2)

        browser.close()

    with open(OUT, 'w') as f:
        json.dump(results, f, indent=2)
    log(f"DONE. Wrote {len(results)} results")

if __name__ == '__main__':
    main()
