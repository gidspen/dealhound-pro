#!/usr/bin/env python3
"""Generate compact scores + signals SQL for surveying upload."""
import json, uuid, os

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = json.load(open(os.path.join(ROOT, "..", "surveying_targets.json")))
RUN_ID = DATA["run"]["score_run_id"]
NS = uuid.UUID("6f1d2c00-0000-4000-8000-000000000001")

def bid(b):
    key = f"{b.get('vertical','land_surveying')}|{b['legal_name']}|{b.get('city','')}|{b.get('state','TX')}"
    return str(uuid.uuid5(NS, "business:" + key))

def esc(v):
    if v is None: return "NULL"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return str(v)
    if isinstance(v, (dict, list)):
        return "'" + json.dumps(v).replace("'", "''") + "'::jsonb"
    return "'" + str(v).replace("'", "''") + "'"

SCOLS = ["layer1_base_rate","layer1_comment","layer2_sellability","layer2_comment",
         "layer3_behavioral_trigger","layer3_comment","layer4_market_pull","layer4_comment",
         "final_score","final_tier","final_comment","value_add_thesis","confidence","data_completeness"]

# Truncate verbose comments to keep batches compact (300 char max per comment for short fields,
# 1200 for the long-form final_comment and value_add_thesis fields)
def truncate(s, n=300):
    if not isinstance(s, str): return s
    return s[:n] if len(s) > n else s

LONG_COLS = {"final_comment", "value_add_thesis"}

score_rows = []
for b in DATA["businesses"]:
    sc = b['score']
    i = bid(b)
    vals = [esc(i), esc(RUN_ID)]
    for c in SCOLS:
        v = sc.get(c)
        if isinstance(v, str):
            # Very aggressively truncate to keep batches under MCP token budget
            v = v[:400] if c in LONG_COLS else v[:120]
        vals.append(esc(v))
    score_rows.append("(" + ", ".join(vals) + ")")

# Split into smaller batches
batch_size = 60
for i in range(0, len(score_rows), batch_size):
    chunk = score_rows[i:i+batch_size]
    fn = f"scores_batch_{i//batch_size+1:02d}.sql"
    with open(os.path.join(ROOT, fn), "w") as f:
        setc = ", ".join(f"{c} = excluded.{c}" for c in SCOLS)
        f.write(f"insert into offmarket.business_scores (business_id, score_run_id, {', '.join(SCOLS)}) values\n")
        f.write(",\n".join(chunk))
        f.write(f"\non conflict (business_id, score_run_id) do update set {setc};\n")
    print(f"  Wrote {fn} ({len(chunk)} rows, {os.path.getsize(os.path.join(ROOT, fn))} bytes)")
