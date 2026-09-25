#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
old = "    z-index:1000;\n"
assert old in s, "header bg pattern missing"
s = s.replace(old, "    z-index:1000;\n    background:var(--bg);\n", 1)
p.write_text(s, encoding="utf-8")
print("T21 header opaque ok")
PY
python3 scripts/check_site.py
echo "T21 done"
