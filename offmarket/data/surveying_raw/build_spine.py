#!/usr/bin/env python3
"""Build the TX land surveying spine from TBPELS rosters.

Strategy:
- Filter to TX HQ Registered firms (1053 of them).
- Cross-reference each firm's License # against the RPLS roster to identify
  the active RPLS(s) at that firm. The "Firm Num" column in rpls_roster.csv
  links to "License #" in sur-firm_roster.csv (zero-stripped).
- Compute n_active_rpls and earliest_rpls_granted_year per firm.
- Tier firms into a target-priority queue:
  TIER A (highest priority — likely solo coasting owner):
    - solo RPLS (n=1)
    - RPLS granted 1975-1995 (owner now ~58-78)
    - in a target metro / energy corridor
  TIER B:
    - solo RPLS with grant 1996-2005 (owner 50-65)
    - 2-RPLS firms with both granted before 1995 (peer-age, no younger successor)
    - in target metro
  TIER C:
    - all other TX HQ Registered firms in target geographies
- Cap spine at ~100 firms, ~70/20/10 split A/B/C.

Output: surveying_spine.json with one row per firm:
  - license_number, legal_name, address, city, state, zip
  - n_active_rpls, principal_rpls_list (name + granted year)
  - earliest_rpls_year, tier (spine prioritization tier — NOT scoring tier)
  - county (derived from city heuristic)
  - geo_bucket (major_metro / permian / eagle_ford / coastal_flood / secondary / rural)
"""
import csv, json, re, os, sys
from collections import defaultdict, Counter
from datetime import datetime

ROOT = os.path.dirname(os.path.abspath(__file__))

# === METRO + COUNTY MAPPING ===
# Map city (uppercase) -> (county, geo_bucket).
# geo_bucket: major_metro | premium_suburb | secondary | permian | eagle_ford
#             | coastal_flood | east_tx | panhandle | rural
CITY_MAP = {
    # Houston / Harris + suburbs (major metro + flood + energy)
    "HOUSTON":          ("Harris",      "major_metro_coastal"),
    "KATY":             ("Harris",      "major_metro_coastal"),
    "SPRING":           ("Harris",      "major_metro_coastal"),
    "TOMBALL":          ("Harris",      "major_metro_coastal"),
    "HUMBLE":           ("Harris",      "major_metro_coastal"),
    "BELLAIRE":         ("Harris",      "major_metro_coastal"),
    "CYPRESS":          ("Harris",      "major_metro_coastal"),
    "PASADENA":         ("Harris",      "major_metro_coastal"),
    "MISSOURI CITY":    ("Fort Bend",   "major_metro_coastal"),
    "STAFFORD":         ("Fort Bend",   "major_metro_coastal"),
    "ROSENBERG":        ("Fort Bend",   "major_metro_coastal"),
    "RICHMOND":         ("Fort Bend",   "major_metro_coastal"),
    "SUGAR LAND":       ("Fort Bend",   "major_metro_coastal"),
    "PEARLAND":         ("Brazoria",    "major_metro_coastal"),
    "ALVIN":            ("Brazoria",    "major_metro_coastal"),
    "ANGLETON":         ("Brazoria",    "major_metro_coastal"),
    "CONROE":           ("Montgomery",  "major_metro_coastal"),
    "MAGNOLIA":         ("Montgomery",  "major_metro_coastal"),
    "MONTGOMERY":       ("Montgomery",  "major_metro_coastal"),
    "WILLIS":           ("Montgomery",  "major_metro_coastal"),
    "THE WOODLANDS":    ("Montgomery",  "major_metro_coastal"),
    "PORTER":           ("Montgomery",  "major_metro_coastal"),
    "CLEVELAND":        ("Liberty",     "major_metro_coastal"),
    "LEAGUE CITY":      ("Galveston",   "major_metro_coastal"),
    "FRIENDSWOOD":      ("Galveston",   "major_metro_coastal"),
    "TEXAS CITY":       ("Galveston",   "coastal_flood"),
    "GALVESTON":        ("Galveston",   "coastal_flood"),
    "DICKINSON":        ("Galveston",   "major_metro_coastal"),
    "ROSHARON":         ("Brazoria",    "major_metro_coastal"),
    "BAY CITY":         ("Matagorda",   "coastal_flood"),
    "EL CAMPO":         ("Wharton",     "rural"),
    "WHARTON":          ("Wharton",     "rural"),
    "FREEPORT":         ("Brazoria",    "coastal_flood"),
    "BAYTOWN":          ("Harris",      "major_metro_coastal"),
    "LIBERTY":          ("Liberty",     "rural"),
    "BEAUMONT":         ("Jefferson",   "coastal_flood"),
    "PORT ARTHUR":      ("Jefferson",   "coastal_flood"),
    "PORT NECHES":      ("Jefferson",   "coastal_flood"),
    "ORANGE":           ("Orange",      "coastal_flood"),
    "NEDERLAND":        ("Jefferson",   "coastal_flood"),
    "VIDOR":            ("Orange",      "coastal_flood"),

    # Dallas / Tarrant / Collin / Denton (major metro)
    "DALLAS":           ("Dallas",      "major_metro"),
    "RICHARDSON":       ("Dallas",      "major_metro"),
    "GARLAND":          ("Dallas",      "major_metro"),
    "IRVING":           ("Dallas",      "major_metro"),
    "MESQUITE":         ("Dallas",      "major_metro"),
    "FARMERS BRANCH":   ("Dallas",      "major_metro"),
    "DUNCANVILLE":      ("Dallas",      "major_metro"),
    "DESOTO":           ("Dallas",      "major_metro"),
    "ROWLETT":          ("Dallas",      "major_metro"),
    "GRAND PRAIRIE":    ("Dallas",      "major_metro"),
    "PLANO":            ("Collin",      "major_metro"),
    "MCKINNEY":         ("Collin",      "major_metro"),
    "FRISCO":           ("Collin",      "major_metro"),
    "ALLEN":            ("Collin",      "major_metro"),
    "WYLIE":            ("Collin",      "major_metro"),
    "ANNA":             ("Collin",      "major_metro"),
    "PROSPER":          ("Collin",      "major_metro"),
    "DENTON":           ("Denton",      "major_metro"),
    "LEWISVILLE":       ("Denton",      "major_metro"),
    "FLOWER MOUND":     ("Denton",      "major_metro"),
    "LITTLE ELM":       ("Denton",      "major_metro"),
    "THE COLONY":       ("Denton",      "major_metro"),
    "ARGYLE":           ("Denton",      "major_metro"),
    "AUBREY":           ("Denton",      "major_metro"),
    "FORT WORTH":       ("Tarrant",     "major_metro"),
    "FT. WORTH":        ("Tarrant",     "major_metro"),
    "ARLINGTON":        ("Tarrant",     "major_metro"),
    "BEDFORD":          ("Tarrant",     "major_metro"),
    "EULESS":           ("Tarrant",     "major_metro"),
    "HURST":            ("Tarrant",     "major_metro"),
    "GRAPEVINE":        ("Tarrant",     "major_metro"),
    "MANSFIELD":        ("Tarrant",     "major_metro"),
    "KELLER":           ("Tarrant",     "major_metro"),
    "SOUTHLAKE":        ("Tarrant",     "major_metro"),
    "COLLEYVILLE":      ("Tarrant",     "major_metro"),
    "ROCKWALL":         ("Rockwall",    "major_metro"),
    "FORNEY":           ("Kaufman",     "major_metro"),
    "KAUFMAN":          ("Kaufman",     "major_metro"),
    "ENNIS":            ("Ellis",       "major_metro"),
    "WAXAHACHIE":       ("Ellis",       "major_metro"),
    "MIDLOTHIAN":       ("Ellis",       "major_metro"),

    # Austin / Travis / Williamson (major metro)
    "AUSTIN":           ("Travis",      "major_metro"),
    "PFLUGERVILLE":     ("Travis",      "major_metro"),
    "ROUND ROCK":       ("Williamson",  "major_metro"),
    "CEDAR PARK":       ("Williamson",  "major_metro"),
    "GEORGETOWN":       ("Williamson",  "major_metro"),
    "LEANDER":          ("Williamson",  "major_metro"),
    "HUTTO":            ("Williamson",  "major_metro"),
    "TAYLOR":           ("Williamson",  "major_metro"),
    "BUDA":             ("Hays",        "major_metro"),
    "KYLE":             ("Hays",        "major_metro"),
    "DRIPPING SPRINGS": ("Hays",        "major_metro"),
    "BASTROP":          ("Bastrop",     "major_metro"),
    "ELGIN":            ("Bastrop",     "major_metro"),
    "SAN MARCOS":       ("Hays",        "major_metro"),

    # San Antonio / Bexar + suburbs
    "SAN ANTONIO":      ("Bexar",       "major_metro"),
    "BOERNE":           ("Kendall",     "major_metro"),
    "CONVERSE":         ("Bexar",       "major_metro"),
    "HELOTES":          ("Bexar",       "major_metro"),
    "SCHERTZ":          ("Guadalupe",   "major_metro"),
    "CIBOLO":           ("Guadalupe",   "major_metro"),
    "SEGUIN":           ("Guadalupe",   "major_metro"),
    "NEW BRAUNFELS":    ("Comal",       "major_metro"),
    "CANYON LAKE":      ("Comal",       "major_metro"),
    "CASTROVILLE":      ("Medina",      "secondary"),

    # Permian Basin (oil/gas ROW corridor — bonus)
    "MIDLAND":          ("Midland",     "permian"),
    "ODESSA":           ("Ector",       "permian"),
    "ANDREWS":          ("Andrews",     "permian"),
    "BIG SPRING":       ("Howard",      "permian"),
    "SNYDER":           ("Scurry",      "permian"),
    "PECOS":            ("Reeves",      "permian"),
    "FORT STOCKTON":    ("Pecos",       "permian"),
    "MONAHANS":         ("Ward",        "permian"),
    "STANTON":          ("Martin",      "permian"),
    "KERMIT":           ("Winkler",     "permian"),
    "ALPINE":           ("Brewster",    "permian"),

    # Eagle Ford (oil/gas ROW corridor)
    "LAREDO":           ("Webb",        "eagle_ford"),
    "COTULLA":          ("La Salle",    "eagle_ford"),
    "PEARSALL":         ("Frio",        "eagle_ford"),
    "DILLEY":           ("Frio",        "eagle_ford"),
    "CARRIZO SPRINGS":  ("Dimmit",      "eagle_ford"),
    "BEEVILLE":         ("Bee",         "eagle_ford"),
    "FLORESVILLE":      ("Wilson",      "eagle_ford"),
    "JOURDANTON":       ("Atascosa",    "eagle_ford"),
    "POTEET":           ("Atascosa",    "eagle_ford"),
    "PLEASANTON":       ("Atascosa",    "eagle_ford"),
    "KENEDY":           ("Karnes",      "eagle_ford"),
    "KARNES CITY":      ("Karnes",      "eagle_ford"),
    "YOAKUM":           ("Lavaca",      "eagle_ford"),
    "GONZALES":         ("Gonzales",    "eagle_ford"),
    "CUERO":            ("DeWitt",      "eagle_ford"),
    "VICTORIA":         ("Victoria",    "eagle_ford"),
    "GOLIAD":           ("Goliad",      "eagle_ford"),
    "CORPUS CHRISTI":   ("Nueces",      "coastal_flood"),
    "PORTLAND":         ("San Patricio","coastal_flood"),
    "ROCKPORT":         ("Aransas",     "coastal_flood"),
    "ALICE":            ("Jim Wells",   "eagle_ford"),
    "KINGSVILLE":       ("Kleberg",     "coastal_flood"),

    # Rio Grande Valley
    "MCALLEN":          ("Hidalgo",     "secondary"),
    "EDINBURG":         ("Hidalgo",     "secondary"),
    "MISSION":          ("Hidalgo",     "secondary"),
    "PHARR":            ("Hidalgo",     "secondary"),
    "HARLINGEN":        ("Cameron",     "secondary"),
    "BROWNSVILLE":      ("Cameron",     "coastal_flood"),
    "WESLACO":          ("Hidalgo",     "secondary"),
    "SAN BENITO":       ("Cameron",     "coastal_flood"),

    # El Paso
    "EL PASO":          ("El Paso",     "secondary"),

    # East TX / North TX secondary
    "TYLER":            ("Smith",       "secondary"),
    "LONGVIEW":         ("Gregg",       "secondary"),
    "MARSHALL":         ("Harrison",    "secondary"),
    "KILGORE":          ("Gregg",       "secondary"),
    "HENDERSON":        ("Rusk",        "secondary"),
    "ATHENS":           ("Henderson",   "secondary"),
    "PALESTINE":        ("Anderson",    "secondary"),
    "LUFKIN":           ("Angelina",    "east_tx"),
    "NACOGDOCHES":      ("Nacogdoches", "east_tx"),
    "JACKSONVILLE":     ("Cherokee",    "east_tx"),
    "MOUNT PLEASANT":   ("Titus",       "east_tx"),
    "PARIS":            ("Lamar",       "east_tx"),
    "GREENVILLE":       ("Hunt",        "secondary"),
    "SHERMAN":          ("Grayson",     "secondary"),
    "DENISON":          ("Grayson",     "secondary"),

    # Waco / Central TX
    "WACO":             ("McLennan",    "secondary"),
    "TEMPLE":           ("Bell",        "secondary"),
    "BELTON":           ("Bell",        "secondary"),
    "KILLEEN":          ("Bell",        "secondary"),
    "HARKER HEIGHTS":   ("Bell",        "secondary"),
    "COPPERAS COVE":    ("Coryell",     "secondary"),
    "GATESVILLE":       ("Coryell",     "rural"),
    "BRYAN":            ("Brazos",      "secondary"),
    "COLLEGE STATION":  ("Brazos",      "secondary"),
    "HUNTSVILLE":       ("Walker",      "secondary"),
    "BRENHAM":          ("Washington",  "secondary"),
    "COLUMBUS":         ("Colorado",    "rural"),
    "GIDDINGS":         ("Lee",         "rural"),
    "LA GRANGE":        ("Fayette",     "rural"),
    "FAYETTEVILLE":     ("Fayette",     "rural"),
    "SCHULENBURG":      ("Fayette",     "rural"),
    "CALDWELL":         ("Burleson",    "rural"),
    "HEMPSTEAD":        ("Waller",      "rural"),
    "BELLVILLE":        ("Austin",      "rural"),
    "SEALY":            ("Austin",      "rural"),
    "EAGLE LAKE":       ("Colorado",    "rural"),

    # West TX / Panhandle
    "ABILENE":          ("Taylor",      "secondary"),
    "SAN ANGELO":       ("Tom Green",   "secondary"),
    "LUBBOCK":          ("Lubbock",     "secondary"),
    "AMARILLO":         ("Potter",      "panhandle"),
    "CANYON":           ("Randall",     "panhandle"),
    "PLAINVIEW":        ("Hale",        "panhandle"),
    "PAMPA":            ("Gray",        "panhandle"),
    "BORGER":           ("Hutchinson",  "panhandle"),
    "DUMAS":            ("Moore",       "panhandle"),
    "PERRYTON":         ("Ochiltree",   "panhandle"),
    "HEREFORD":         ("Deaf Smith",  "panhandle"),
    "DALHART":          ("Dallam",      "panhandle"),
    "VERNON":           ("Wilbarger",   "rural"),
    "WICHITA FALLS":    ("Wichita",     "secondary"),
    "BURKBURNETT":      ("Wichita",     "rural"),
    "MINERAL WELLS":    ("Palo Pinto",  "rural"),
    "WEATHERFORD":      ("Parker",      "major_metro"),
    "GRANBURY":         ("Hood",        "secondary"),
    "GLEN ROSE":        ("Somervell",   "rural"),
    "STEPHENVILLE":     ("Erath",       "rural"),
    "BROWNWOOD":        ("Brown",       "rural"),
    "FREDERICKSBURG":   ("Gillespie",   "secondary"),
    "KERRVILLE":        ("Kerr",        "secondary"),
    "BANDERA":          ("Bandera",     "rural"),
    "UVALDE":           ("Uvalde",      "rural"),
    "EAGLE PASS":       ("Maverick",    "rural"),
    "DEL RIO":          ("Val Verde",   "rural"),
    "JUNCTION":         ("Kimble",      "rural"),
    "OZONA":            ("Crockett",    "rural"),
    "SONORA":           ("Sutton",      "rural"),
    "STERLING CITY":    ("Sterling",    "rural"),
    "COLORADO CITY":    ("Mitchell",    "rural"),
    "POST":             ("Garza",       "rural"),
    "TAHOKA":           ("Lynn",        "rural"),
    "SEMINOLE":         ("Gaines",      "rural"),
    "LEVELLAND":        ("Hockley",     "rural"),
    "LITTLEFIELD":      ("Lamb",        "rural"),
    "MULESHOE":         ("Bailey",      "rural"),
}

def lookup_geo(city):
    c = (city or "").upper().strip()
    if c in CITY_MAP:
        return CITY_MAP[c]
    # heuristic: unknown city -> rural / unknown
    return (None, "unknown")


def main():
    # Load firms
    with open(os.path.join(ROOT, "sur-firm_roster.csv")) as f:
        firms = [r for r in csv.DictReader(f)
                 if r["Status"]=="Registered"
                 and r["State"]=="TX"
                 and r["Rank"]=="Headquarters"]
    print(f"TX HQ Registered firms: {len(firms)}", file=sys.stderr)

    # Load RPLS, group by firm number
    with open(os.path.join(ROOT, "rpls_roster.csv"), encoding="latin-1") as f:
        rpls_all = list(csv.DictReader(f))
    rpls_active = [r for r in rpls_all if r["Status"]=="Registered"]
    firm_to_rpls = defaultdict(list)
    for r in rpls_active:
        if r["Firm Num"]:
            # firm num in rpls roster is plain int string; sur-firm License # is 8-digit with trailing zeros
            firm_to_rpls[r["Firm Num"].strip()].append(r)

    # Try both raw and stripped license # to match
    def find_rpls_for_firm(license_num):
        v = firm_to_rpls.get(license_num)
        if v: return v
        # Try stripping trailing zeros / common transforms
        v = firm_to_rpls.get(license_num.lstrip("0"))
        if v: return v
        # The RPLS firm_num corresponds to the firm's BASE id without status digits.
        # sur-firm License # format is 8-digit, e.g. 10000100. The first 6 digits often
        # match the rpls Firm Num.
        for n in (license_num[:6], license_num[:5], license_num[:4]):
            v = firm_to_rpls.get(n)
            if v: return v
        return []

    spine = []
    for f in firms:
        rpls_for_firm = find_rpls_for_firm(f["License #"].strip())
        county, geo_bucket = lookup_geo(f["City"])
        principals = sorted(rpls_for_firm, key=lambda r: r["Granted"] or "9999")
        principal_names = [
            f"{p['First Name'].strip()} {p['Middle Name'].strip()} {p['Last Name'].strip()}".replace("  "," ").strip()
            for p in principals
        ]
        principal_grants = [p["Granted"] for p in principals]
        earliest = principal_grants[0] if principal_grants else None
        earliest_year = int(earliest[:4]) if earliest else None
        latest = principal_grants[-1] if principal_grants else None
        latest_year = int(latest[:4]) if latest else None

        spine.append({
            "license_number": f["License #"].strip(),
            "legal_name": f["Name"].strip().strip('"'),
            "address1": f["Address 1"].strip().strip('"'),
            "address2": (f["Address 2"] or "").strip().strip('"'),
            "city": f["City"].strip().title(),
            "state": "TX",
            "zip": f["Zip"].strip(),
            "county": county,
            "geo_bucket": geo_bucket,
            "firm_granted": f["Granted"],
            "n_active_rpls": len(principals),
            "principal_rpls_list": [
                {
                    "rpls_number": p["RPLS"],
                    "name": f"{p['First Name'].strip()} {p['Middle Name'].strip()} {p['Last Name'].strip()}".replace("  "," ").strip(),
                    "granted": p["Granted"],
                    "expires": p["Expires"],
                    "tenure_years_from_grant": 2026 - int(p["Granted"][:4]) if p["Granted"] else None,
                }
                for p in principals
            ],
            "earliest_rpls_granted": earliest,
            "earliest_rpls_year": earliest_year,
            "latest_rpls_granted": latest,
            "latest_rpls_year": latest_year,
            # Tenure of senior RPLS (assumes earliest RPLS at the firm = owner)
            "owner_rpls_tenure_years": (2026 - earliest_year) if earliest_year else None,
        })

    # === Prioritization ===
    # PRIORITY A (definitely include): n_active_rpls in [1,2] AND earliest_rpls_year <= 1995
    #                                  AND geo_bucket in target metros + energy + flood
    # PRIORITY B (include if room):    n_active_rpls in [1,2] AND earliest_rpls_year in 1996..2005
    #                                  AND geo_bucket in target metros + energy + flood
    # PRIORITY C (broader):            n_active_rpls in [3,4] AND earliest_rpls_year <= 2000
    #                                  AND geo_bucket in target metros + energy
    # Geographic distribution: cap at ~25% per metro to avoid Houston dominating.

    TARGETS_BUCKETS = {"major_metro", "major_metro_coastal", "permian", "eagle_ford", "coastal_flood", "secondary"}

    a_pool, b_pool, c_pool = [], [], []
    for r in spine:
        if r["geo_bucket"] not in TARGETS_BUCKETS:
            continue
        if r["earliest_rpls_year"] is None:
            continue
        if r["n_active_rpls"] in (1,2) and r["earliest_rpls_year"] <= 1995:
            r["spine_priority"] = "A"
            a_pool.append(r)
        elif r["n_active_rpls"] in (1,2) and 1996 <= r["earliest_rpls_year"] <= 2005:
            r["spine_priority"] = "B"
            b_pool.append(r)
        elif r["n_active_rpls"] in (3,4) and r["earliest_rpls_year"] <= 2000:
            r["spine_priority"] = "C"
            c_pool.append(r)
        else:
            r["spine_priority"] = "D"  # not selected

    # Sort each pool by earliest_rpls_year ascending (most-tenured first), then by city size proxy
    def metro_weight(r):
        # Lower = higher priority (more major)
        bucket_w = {"major_metro_coastal":0, "major_metro":1, "permian":2, "eagle_ford":3,
                    "coastal_flood":3, "secondary":4}.get(r["geo_bucket"], 5)
        return (r["earliest_rpls_year"] or 9999, bucket_w)
    a_pool.sort(key=metro_weight)
    b_pool.sort(key=metro_weight)
    c_pool.sort(key=metro_weight)

    # Diversity cap: ≤8 per city, ≤25 per county
    selected = []
    city_count = Counter()
    county_count = Counter()

    def admit(pool, max_n):
        added = 0
        for r in pool:
            if added >= max_n:
                break
            if city_count[r["city"]] >= 8:
                continue
            if county_count[r["county"] or "_unk"] >= 22:
                continue
            selected.append(r)
            city_count[r["city"]] += 1
            county_count[r["county"] or "_unk"] += 1
            added += 1
        return added

    n_a = admit(a_pool, 60)   # Prefer A
    n_b = admit(b_pool, 30)   # then B
    n_c = admit(c_pool, 15)   # then C
    print(f"Selected: A={n_a} B={n_b} C={n_c} total={len(selected)}", file=sys.stderr)

    # Final spine output (sort by spine_priority, then earliest year)
    selected.sort(key=lambda r: (r["spine_priority"], r["earliest_rpls_year"] or 9999))

    out = {
        "score_run_id": "02713a3e-ded7-4f5d-8e3c-ff77f8e796b6",
        "run_label": "surveying-tx-2026-05-15",
        "vertical": "land_surveying",
        "geography": "TX — major metros + energy corridors + coastal-flood metros",
        "spine_source": "TBPELS Surveying Firms Roster CSV + RPLS Roster CSV (https://pels.texas.gov/roster/ls_rosters.html)",
        "fetched_at": datetime.utcnow().isoformat() + "Z",
        "filters_applied": [
            "TX state",
            "Headquarters rank",
            "Status=Registered",
            "geo_bucket in major_metro/major_metro_coastal/permian/eagle_ford/coastal_flood/secondary",
            "n_active_rpls in [1,2,3,4]",
            "earliest_rpls_year <= 2005 (priority A/B) or <= 2000 (priority C)"
        ],
        "spine_priority_explanation": {
            "A": "1-2 active RPLS, earliest RPLS granted 1995 or earlier (owner ~58-78+) - prime exit-window candidates",
            "B": "1-2 active RPLS, earliest RPLS granted 1996-2005 (owner ~50-65) - secondary exit-window",
            "C": "3-4 active RPLS, earliest RPLS granted before 2000 (older multi-RPLS firms - possible succession-in-place but still candidates)"
        },
        "n_spine": len(selected),
        "n_by_priority": {"A": n_a, "B": n_b, "C": n_c},
        "geo_distribution": dict(Counter(r["geo_bucket"] for r in selected)),
        "county_distribution": dict(Counter(r["county"] for r in selected if r["county"])),
        "spine": selected,
    }

    out_path = os.path.join(os.path.dirname(ROOT), "surveying_spine.json")
    with open(out_path, "w") as f:
        json.dump(out, f, indent=2)
    print(f"Wrote {out_path} ({len(selected)} firms)", file=sys.stderr)


if __name__ == "__main__":
    main()
