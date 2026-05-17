"""Split SQL files into chunks of 10 inserts each by splitting on 'INSERT INTO' marker."""
import re
from pathlib import Path

ROOT = Path("/Users/gideonspencer/dealhound-pro/.claude/worktrees/crazy-khayyam-7adaed/offmarket")
SQL = ROOT / "data" / "sql"

def split_inserts(content):
    """Split by '\n\nINSERT INTO offmarket.' markers."""
    # Find positions where new INSERT starts (preceded by blank line or BOF)
    parts = re.split(r'(?=^INSERT INTO offmarket\.)', content, flags=re.MULTILINE)
    parts = [p.strip() for p in parts if p.strip() and p.strip().startswith("INSERT INTO")]
    return parts

with open(SQL / "plumbing_10_businesses.sql") as f:
    biz_stmts = split_inserts(f.read())

with open(SQL / "plumbing_30_scores.sql") as f:
    score_stmts = split_inserts(f.read())

with open(SQL / "plumbing_20_signals.sql") as f:
    signal_stmts = split_inserts(f.read())

print(f"biz: {len(biz_stmts)}, scores: {len(score_stmts)}, signals: {len(signal_stmts)}")

def chunk_and_write(stmts, prefix, chunk_size=10):
    for i in range(0, len(stmts), chunk_size):
        chunk = stmts[i:i+chunk_size]
        idx = i // chunk_size
        out_path = SQL / f"{prefix}_{idx:02d}.sql"
        with open(out_path, "w") as f:
            f.write("\n\n".join(chunk))
    print(f"Wrote {prefix}: {(len(stmts)+chunk_size-1)//chunk_size} chunks ({chunk_size} each)")

chunk_and_write(biz_stmts, "plumbing_biz_chunk")
chunk_and_write(score_stmts, "plumbing_score_chunk")
chunk_and_write(signal_stmts, "plumbing_signal_chunk", chunk_size=10)
