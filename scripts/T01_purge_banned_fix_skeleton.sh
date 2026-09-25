#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p scripts reports quarantine/banned-2
cp -f index.html "index.html.bak.T01" 2>/dev/null || true
if [ -f style.css ]; then cp -f style.css "style.css.bak.T01"; fi
for f in assets/images/web/2.jpg assets/images/thumbs/2.jpg; do
  if [ -f "$f" ]; then mv -f "$f" quarantine/banned-2/ 2>/dev/null || cp -f "$f" quarantine/banned-2/; fi
done
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8", errors="strict")
s = s.replace("assets/images/web/2.jpg", "assets/images/web/9.jpg")
s = s.replace("web/2.jpg", "web/9.jpg")
s = s.replace("thumbs/2.jpg", "thumbs/9.jpg")
s = s.replace('assets/css/styles.css\n', '')
s = re.sub(r'assets/css/styles\.css(?!["\'])', '', s)
if '<link rel="stylesheet"' not in s:
    s = s.replace("</title>", "</title>\n<link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">\n<link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>\n<link href=\"https://fonts.googleapis.com/css2?family=Baskervville:ital@0;1&family=Inter:wght@400;500;600&display=swap\" rel=\"stylesheet\">\n<link rel=\"stylesheet\" href=\"assets/css/styles.css\">")
old_nav = re.search(r'<nav class="site-nav">.*?</nav>', s, re.DOTALL)
new_nav = '<nav class="site-nav" aria-label="Nawigacja glowna">\n        <a href="#praktyka">Praktyka</a>\n        <a href="#o-kancelarii">Kancelaria</a>\n        <a href="#wartosci">Wartosci</a>\n        <a href="#kontakt">Kontakt</a>\n      </nav>'
if old_nav:
    s = s[:old_nav.start()] + new_nav + s[old_nav.end():]
s = s.replace("#prakyka", "#praktyka")
s = s.replace('<html lang="pl">', '<html lang="pl">', 1)
if '<meta charset' not in s:
    s = s.replace('<head>', '<head>\n<meta charset="utf-8">', 1)
p.write_text(s, encoding="utf-8")
print("T01 index skeleton fixed")
PY
if [ -f style.css ]; then rm -f style.css; echo "orphan style.css removed"; fi
cat > scripts/check_site.py <<'PY'
#!/usr/bin/env python3
import pathlib, re, sys
root = pathlib.Path(__file__).resolve().parents[1]
idx = root / "index.html"
s = idx.read_text(encoding="utf-8")
errs = []
def chk(cond, msg):
    if not cond: errs.append(msg)
chk("web/2.jpg" not in s, "banned web/2.jpg still referenced")
chk("2.png" not in s or "quarantine" in s, "banned 2.png referenced in HTML")
chk('<link rel="stylesheet" href="assets/css/styles.css">' in s, "stylesheet link missing")
for a in ["#praktyka", "#o-kancelarii", "#wartosci", "#kontakt"]:
    chk(f'href="{a}"' in s, f"nav anchor {a} missing")
for sid in ["praktyka", "o-kancelarii", "kontakt"]:
    chk(f'id="{sid}"' in s, f"section id {sid} missing")
opens = len(re.findall(r"<section\b", s)) + len(re.findall(r"<header\b", s)) + len(re.findall(r"<div\b", s))
closes = len(re.findall(r"</section>", s)) + len(re.findall(r"</header>", s)) + len(re.findall(r"</div>", s))
chk(abs(opens - closes) <= 3, f"tag imbalance div/section/header open={opens} close={closes}")
for img in re.findall(r"<img\b[^>]*>", s):
    chk("alt=" in img, f"img missing alt: {img[:80]}")
print("check_site T01 gate:", "PASS" if not errs else "FAIL")
for e in errs: print(" -", e)
sys.exit(0 if not errs else 1)
PY
chmod +x scripts/check_site.py
python3 scripts/check_site.py
rm -rf quarantine
echo "T01 done"
