#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p reports
curl -s --max-time 30 -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36" https://niedziejko.pl/ -o reports/live-index.html
python3 - "$ROOT" <<'PY'
import sys, unicodedata, re
import pathlib as _pl
root = sys.argv[1]
html = (_pl.Path(root) / "reports" / "live-index.html").read_text(encoding="utf-8")
errs = []
def chk(c, m):
    if not c: errs.append(m)
chk("hero-9.jpg" in html, "live: no hero-9")
chk("web/2.jpg" not in html and "2.png" not in html, "live: banned asset present")
for a in ['href="#praktyka"', 'href="#o-kancelarii"', 'href="#wartosci"', 'href="#kontakt"']:
    chk(a in html, f"live: missing {a}")
chk("mailto:kontakt@kamilniedziejko.pl" in html or "__cf_email__" in html, "live: mailto missing (direct or CF-obfuscated)")
chk("tel:+48512458132" in html, "live: tel missing")
chk("Dobrego Pasterza 189" in html, "live: NAP missing")
low = "".join(c for c in unicodedata.normalize("NFD", html) if unicodedata.category(c) != "Mn").lower()
for phrase in ["kompleksowa obsluga", "najwyzsza jakosc", "indywidualne podejscie", "profesjonalne uslugi"]:
    chk(phrase not in low, f"live: generic phrase {phrase}")
chk(len(re.findall(r"<img\b", html)) >= 5, "live: fewer than 5 imgs")
print("T15 live-content:", "PASS" if not errs else "FAIL")
for e in errs: print(" -", e)
sys.exit(0 if not errs else 1)
PY
echo "T15 done"
