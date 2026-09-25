#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T02" 2>/dev/null || true
cp -f assets/css/styles.css "assets/css/styles.css.bak.T02" 2>/dev/null || true
magick assets/images/9.png -crop 48%x100%+799+0 +repage -strip -resize 1200x1200\> -quality 82 assets/images/web/hero-9.jpg
magick assets/images/web/hero-9.jpg -strip -quality 80 -define webp:method=4 assets/images/web/hero-9.webp 2>/dev/null || true
ls -l assets/images/web/hero-9.jpg
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
s = s.replace("assets/images/web/9.jpg", "assets/images/web/hero-9.jpg")
new_hero = """<section class="hero">
    <div class="container hero-grid">
      <div class="hero-copy">
        <p class="eyebrow">Adwokat &mdash; Krak&oacute;w</p>
        <h1>Spok&oacute;j, precyzja i odpowiedzialno&#347;&#263; w sprawach, kt&oacute;re maj&#261; znaczenie.</h1>
        <p class="lead">Butikowa kancelaria w Krakowie. Sprawy karne, cywilne i rodzinne prowadzone w oparciu o analiz&#281;, dyskrecj&#281; i bezpo&#347;redni kontakt z adwokatem.</p>
        <div class="hero-actions">
          <a class="btn" href="#kontakt">Um&oacute;w konsultacj&#281;</a>
          <a class="btn btn-outline" href="#praktyka">Obszary praktyki</a>
        </div>
      </div>
      <figure class="hero-media">
        <img src="assets/images/web/hero-9.jpg" alt="Jasne minimalistyczne wnetrze kancelarii, biurko i swiatlo dzienne" width="900" height="1150" fetchpriority="high" decoding="async">
      </figure>
    </div>
  </section>"""
pat = re.compile(r'<header\s+class="hero".*?</header>', re.DOTALL)
if pat.search(s):
    s = pat.sub(new_hero, s)
else:
    pat2 = re.compile(r'<section\s+class="hero".*?</section>', re.DOTALL)
    s = pat2.sub(new_hero, s) if pat2.search(s) else s.replace("</header>", "</header>\n" + new_hero, 1)
s = s.replace("https://niedziejko.pl/assets/images/web/9.jpg", "https://niedziejko.pl/assets/images/web/hero-9.jpg")
p.write_text(s, encoding="utf-8")
print("T02 hero replaced")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
.hero{background:var(--bg);padding:7rem 0 6rem;}
.hero-grid{display:grid;grid-template-columns:1.05fr .95fr;gap:5rem;align-items:center;}
.hero-copy .eyebrow{display:block;margin-bottom:1.8rem;}
.hero-copy h1{font-family:"Baskervville",serif;font-weight:400;font-size:clamp(2.4rem,4.2vw,3.9rem);line-height:1.08;letter-spacing:-.01em;max-width:14em;}
.hero-copy .lead{margin-top:1.8rem;max-width:34em;color:var(--muted);font-size:1.05rem;line-height:1.75;}
.hero-actions{display:flex;gap:1rem;flex-wrap:wrap;margin-top:2.6rem;}
.hero-media{margin:0;background:var(--surface);border:1px solid var(--line);padding:.9rem;}
.hero-media img{width:100%;height:auto;aspect-ratio:3/4;object-fit:cover;}
@media (max-width:900px){.hero{padding:4rem 0 3rem;}.hero-grid{grid-template-columns:1fr;gap:2.5rem;}.hero-media img{aspect-ratio:4/3;}}
"""
if ".hero-grid" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T02 css ok")
PY
python3 scripts/check_site.py
rm -f index.html.bak.T02 assets/css/styles.css.bak.T02
echo "crop-marker hero-9 right-half no-text" > reports/T02_crop.txt
echo "T02 done"
