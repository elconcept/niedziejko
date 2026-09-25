#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T04" || true
cp -f assets/js/main.js "assets/js/main.js.bak.T04" || true
magick assets/images/3.png -crop 37%x100%+968+0 +repage -strip -resize 1000x1000\> -quality 82 assets/images/web/practice-3.jpg
magick assets/images/web/practice-3.jpg -quality 80 assets/images/web/practice-3.webp 2>/dev/null || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
block = """<section id="praktyka">
    <div class="container practice-grid">
      <div>
        <p class="eyebrow">Obszary praktyki</p>
        <h2>Przejrzysta lista uslug.</h2>
        <div class="practice-list">
          <div class="practice-item"><button aria-expanded="false">Prawo karne<span aria-hidden="true">+</span></button><div class="practice-panel" hidden>Obrona i reprezentacja na kazdym etapie postepowania karnego.</div></div>
          <div class="practice-item"><button aria-expanded="false">Prawo cywilne<span aria-hidden="true">+</span></button><div class="practice-panel" hidden>Spory majatkowe, zobowiazania, odszkodowania i dochodzenie naleznosci.</div></div>
          <div class="practice-item"><button aria-expanded="false">Prawo rodzinne<span aria-hidden="true">+</span></button><div class="practice-panel" hidden>Rozwody, kontakty z dziecmi, alimenty i wladza rodzicielska.</div></div>
          <div class="practice-item"><button aria-expanded="false">Obsluga przedsiebiorcow<span aria-hidden="true">+</span></button><div class="practice-panel" hidden>Opiniowanie umow i reprezentacja w sporach gospodarczych.</div></div>
          <div class="practice-item"><button aria-expanded="false">Dochodzenie roszczen<span aria-hidden="true">+</span></button><div class="practice-panel" hidden>Analiza i dochodzenie roszczen od podmiotow prywatnych i instytucji.</div></div>
        </div>
      </div>
      <figure class="practice-media" aria-hidden="true">
        <img src="assets/images/web/practice-3.jpg" alt="" width="700" height="900" loading="lazy" decoding="async">
      </figure>
    </div>
  </section>"""
pat = re.compile(r'<section id="praktyka">.*?</section>', re.DOTALL)
s = pat.sub(block, s) if pat.search(s) else s
p.write_text(s, encoding="utf-8")
print("T04 practice replaced")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
.practice-grid{display:grid;grid-template-columns:1.2fr .8fr;gap:5rem;align-items:start;}
.practice-list{margin-top:2.5rem;border-top:1px solid var(--line);}
.practice-item{border-bottom:1px solid var(--line);}
.practice-item button{width:100%;display:flex;justify-content:space-between;align-items:center;background:none;border:0;padding:1.4rem 0;font-family:"Baskervville",serif;font-size:clamp(1.3rem,2vw,1.8rem);color:var(--text);cursor:pointer;text-align:left;}
.practice-panel{padding:0 0 1.4rem;color:var(--muted);max-width:40em;}
.practice-media{margin:0;background:var(--surface);border:1px solid var(--line);padding:.9rem;position:sticky;top:6rem;}
.practice-media img{aspect-ratio:3/4;object-fit:cover;}
@media (max-width:900px){.practice-grid{grid-template-columns:1fr;}.practice-media{position:static;}}
"""
if ".practice-grid" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T04 css ok")
q = root / "assets/js/main.js"
j = q.read_text(encoding="utf-8")
if "practice-item button" not in j:
    j = j.replace("document.querySelectorAll('.practice-item')", "document.querySelectorAll('.practice-item button')")
    j += "\n;document.querySelectorAll('.practice-item button').forEach(function(btn){var panel=btn.parentElement.querySelector('.practice-panel');if(!panel)return;btn.addEventListener('click',function(){var open=btn.getAttribute('aria-expanded')==='true';document.querySelectorAll('.practice-item button[aria-expanded=\"true\"]').forEach(function(o){o.setAttribute('aria-expanded','false');var pp=o.parentElement.querySelector('.practice-panel');if(pp)pp.hidden=true;});btn.setAttribute('aria-expanded',String(!open));panel.hidden=open;});});\n"
    q.write_text(j, encoding="utf-8")
print("T04 js ok")
PY
python3 scripts/check_site.py
rm -f index.html.bak.T04 assets/js/main.js.bak.T04
echo "crop-marker practice-3 paper-pencil" > reports/T04_crop.txt
echo "T04 done"
