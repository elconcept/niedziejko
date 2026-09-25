#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T05" || true
magick assets/images/5.png -crop 48%x100%+799+0 +repage -strip -resize 1200x1200\> -quality 82 assets/images/web/values-5.jpg
magick assets/images/web/values-5.jpg -quality 80 assets/images/web/values-5.webp 2>/dev/null || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
block = """<section id="wartosci">
    <div class="container values-grid">
      <div>
        <p class="eyebrow">Standard pracy</p>
        <h2>Wartosci kancelarii.</h2>
        <div class="values">
          <div class="value"><strong>RZETELNOSC</strong><span>Analiza oparta na faktach i obowiazujacych przepisach.</span></div>
          <div class="value"><strong>DYSKRECJA</strong><span>Poufnosc powierzonych informacji.</span></div>
          <div class="value"><strong>ZAANGAZOWANIE</strong><span>Bezposredni kontakt z adwokatem prowadzacym sprawe.</span></div>
        </div>
      </div>
      <figure class="values-media" aria-hidden="true">
        <img src="assets/images/web/values-5.jpg" alt="" width="800" height="1000" loading="lazy" decoding="async">
      </figure>
    </div>
  </section>"""
if 'id="wartosci"' in s:
    pat = re.compile(r'<section id="wartosci">.*?</section>', re.DOTALL)
    s = pat.sub(block, s)
else:
    s = s.replace('<section id="kontakt">', block + '\n\n<section id="kontakt">', 1)
s = s.replace("assets/images/web/5.jpg", "assets/images/web/values-5.jpg")
s = s.replace("assets/images/thumbs/5.jpg", "assets/images/web/values-5.jpg")
p.write_text(s, encoding="utf-8")
print("T05 values replaced")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
.values-grid{display:grid;grid-template-columns:1.1fr .9fr;gap:5rem;align-items:start;}
.values{margin-top:2.5rem;}
.value{padding:1.4rem 0;border-bottom:1px solid var(--line);}
.value strong{display:block;letter-spacing:.12em;font-size:.85rem;margin-bottom:.4rem;}
.value span{color:var(--muted);}
.values-media{margin:0;background:var(--surface);border:1px solid var(--line);padding:.9rem;}
.values-media img{aspect-ratio:4/5;object-fit:cover;}
@media (max-width:900px){.values-grid{grid-template-columns:1fr;}}
"""
if ".values-grid" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T05 css ok")
PY
python3 scripts/check_site.py || true
rm -f index.html.bak.T05
echo "crop-marker values-5 wall-shadow" > reports/T05_crop.txt
echo "T05 done"
