#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f assets/css/styles.css "assets/css/styles.css.bak.T22" || true
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
a = ".site-nav a{\n    color:var(--muted);"
assert a in s, "nav color rule missing"
s = s.replace(a, ".site-nav a{\n    color:#6E665B;", 1)
b = """    .site-nav{
        display:none;
    }"""
assert b in s, "mobile nav rule missing"
s = s.replace(b, """    .site-header-inner{
        height:auto;
        flex-direction:column;
        padding:.9rem 0 .7rem;
        gap:.55rem;
    }

    .site-nav{
        display:flex;
        flex-wrap:wrap;
        justify-content:center;
        gap:.35rem 1.3rem;
        font-size:.72rem;
    }""", 1)
c = """    h1{
        font-size:3.5rem;
    }"""
assert c in s, "h1 mobile scale missing"
s = s.replace(c, """    h1{
        font-size:clamp(2.05rem,9vw,2.9rem);
        overflow-wrap:break-word;
    }""", 1)
p.write_text(s, encoding="utf-8")
print("T22 css fixes ok")
PY
python3 scripts/check_site.py
rm -f assets/css/styles.css.bak.T22
echo "T22 done"
