#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T03" || true
magick assets/images/4.png -crop 55%x100%+691+0 +repage -strip -resize 1200x1200\> -quality 82 assets/images/web/about-4.jpg
magick assets/images/web/about-4.jpg -quality 80 assets/images/web/about-4.webp 2>/dev/null || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
s = s.replace("assets/images/web/4.jpg", "assets/images/web/about-4.jpg")
block = """<section id="o-kancelarii">
    <div class="container about-grid">
      <div class="about-copy">
        <p class="eyebrow">O kancelarii</p>
        <h2>Analiza stanu faktycznego i ocena ryzyka.</h2>
        <p>Kazda sprawa wymaga dokladnej analizy dokumentow i praktycznej oceny dostepnych srodkow prawnych.</p>
        <p>Kancelaria zapewnia bezposredni kontakt z adwokatem, przejrzysta komunikacje i reprezentacje na kazdym etapie postepowania.</p>
        <ul class="about-points">
          <li>Bezposredni kontakt z prowadzacym sprawe</li>
          <li>Przejrzysta informacja o sytuacji prawnej</li>
          <li>Odpowiedzialne prowadzenie postepowan</li>
        </ul>
      </div>
      <figure class="about-media">
        <img src="assets/images/web/about-4.jpg" alt="Rece adwokata przegladajace akta sprawy na biurku" width="1000" height="800" loading="lazy" decoding="async">
      </figure>
    </div>
  </section>"""
pat = re.compile(r'<section id="o-kancelarii">.*?</section>', re.DOTALL)
s = pat.sub(block, s) if pat.search(s) else s
p.write_text(s, encoding="utf-8")
print("T03 about replaced")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
.about-grid{display:grid;grid-template-columns:.9fr 1.1fr;gap:5rem;align-items:center;}
.about-points{margin-top:1.5rem;padding-left:1.2rem;color:var(--text);}
.about-media{margin:0;background:var(--surface);border:1px solid var(--line);padding:.9rem;}
.about-media img{width:100%;height:auto;aspect-ratio:5/4;object-fit:cover;}
@media (max-width:900px){.about-grid{grid-template-columns:1fr;gap:2.5rem;}}
"""
if ".about-grid" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T03 css ok")
PY
python3 scripts/check_site.py
rm -f index.html.bak.T03
echo "crop-marker about-4 hands-document no-face" > reports/T03_crop.txt
echo "T03 done"
