#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T07" || true
cp -f assets/css/styles.css "assets/css/styles.css.bak.T07" || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
s = re.sub(r'<section id="identyfikacja">.*?</section>', '', s, flags=re.DOTALL)
for t in ["thumbs/1.jpg","thumbs/3.jpg","thumbs/5.jpg","thumbs/6.jpg","thumbs/7.jpg","thumbs/8.jpg","web/1.jpg","web/7.jpg","web/8.jpg"]:
    s = s.replace(t, "assets/images/web/hero-9.jpg")
s = re.sub(r'\n{3,}', '\n\n', s)
p.write_text(s, encoding="utf-8")
print("T07 gallery removed")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
.container{width:min(92%,1200px);margin-inline:auto;}
section{padding:110px 0;}
section + section{border-top:1px solid var(--line);}
#praktyka .practice-grid{grid-template-columns:1.2fr .8fr;}
#o-kancelarii .about-grid{grid-template-columns:.9fr 1.1fr;}
#wartosci .values-grid{grid-template-columns:1.1fr .9fr;}
footer{border-top:1px solid var(--line);padding:2rem 0;color:var(--muted);font-size:.85rem;text-align:center;}
@media (max-width:900px){section{padding:64px 0;}}
"""
if "1200px" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T07 css ok")
PY
python3 scripts/check_site.py
python3 -c "import pathlib;s=pathlib.Path('index.html').read_text(encoding='utf-8');assert 'identyfikacja' not in s, 'gallery still present';print('T07 gate: no gallery')"
rm -f index.html.bak.T07 assets/css/styles.css.bak.T07
echo "T07 done"
