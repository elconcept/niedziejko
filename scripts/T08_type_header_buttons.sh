#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T08" || true
cp -f assets/css/styles.css "assets/css/styles.css.bak.T08" || true
cp -f assets/js/main.js "assets/js/main.js.bak.T08" || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys, unicodedata
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
def strip_acc(t):
    return ''.join(c for c in unicodedata.normalize('NFD', t) if unicodedata.category(c) != 'Mn').lower()
low = strip_acc(s)
for phrase in ["kompleksowa obsluga", "najwyzsza jakosc", "indywidualne podejscie", "profesjonalne uslugi"]:
    if phrase in low:
        print("WARN generic phrase found:", phrase)
s = re.sub(r'indywidualne podej.?cie', 'bezposredni kontakt z adwokatem', s, flags=re.IGNORECASE)
p.write_text(s, encoding="utf-8")
print("T08 copy-purge ok")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
h1{font-size:clamp(2.6rem,5vw,4.5rem);}h2{font-size:clamp(1.9rem,3.5vw,3rem);}h3{font-size:1.75rem;}
body{font-size:18px;}p{line-height:1.75;}
.eyebrow{font-size:.72rem;letter-spacing:.28em;text-transform:uppercase;color:var(--muted);}
.site-header{position:sticky;top:0;z-index:50;background:rgba(247,244,239,.92);backdrop-filter:blur(10px);border-bottom:1px solid var(--line);}
.site-header-inner{display:flex;justify-content:space-between;align-items:center;gap:1.5rem;padding:1.1rem 0;}
.site-logo{font-size:.8rem;letter-spacing:.18em;font-weight:600;}
.site-nav{display:flex;gap:2rem;font-size:.78rem;letter-spacing:.14em;text-transform:uppercase;}
.site-nav a{padding:.4rem 0;}
.site-nav a:hover{opacity:.6;}
a:focus-visible,button:focus-visible{outline:2px solid var(--accent);outline-offset:3px;}
.btn{display:inline-flex;align-items:center;justify-content:center;padding:1rem 1.8rem;background:var(--accent);color:#fff;border:1px solid var(--accent);font-size:.78rem;letter-spacing:.14em;text-transform:uppercase;}
.btn-outline{background:transparent;color:var(--accent);}
.reveal{opacity:0;transform:translateY(14px);transition:opacity .5s ease,transform .5s ease;}
.revealed{opacity:1;transform:none;}
@media (prefers-reduced-motion:reduce){.reveal{opacity:1;transform:none;transition:none;}html{scroll-behavior:auto;}}
@media (max-width:900px){.site-header-inner{flex-direction:column;}.site-nav{flex-wrap:wrap;justify-content:center;gap:1.2rem;}}
"""
if ".site-header-inner" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T08 css ok")
PY
python3 scripts/check_site.py
rm -f index.html.bak.T08 assets/css/styles.css.bak.T08 assets/js/main.js.bak.T08
echo "T08 done"
