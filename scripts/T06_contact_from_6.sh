#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T06" || true
magick assets/images/6.png -crop 50%x100%+768+0 +repage -strip -resize 1200x1200\> -quality 82 assets/images/web/contact-6.jpg
magick assets/images/web/contact-6.jpg -quality 80 assets/images/web/contact-6.webp 2>/dev/null || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
s = s.replace("assets/images/web/6.jpg", "assets/images/web/contact-6.jpg")
block = """<section id="kontakt">
    <div class="container contact-grid">
      <div>
        <p class="eyebrow">Kontakt</p>
        <h2>Porozmawiajmy o Twojej sprawie.</h2>
        <p class="contact-lead">Pierwszy kontakt pozwala okreslic charakter sprawy oraz mozliwe kierunki dalszego dzialania.</p>
        <p>ul. Dobrego Pasterza 189<br>31-416 Krakow</p>
        <p><a href="mailto:kontakt@kamilniedziejko.pl">kontakt@kamilniedziejko.pl</a><br><a href="tel:+48512458132">+48 512 458 132</a></p>
        <div class="hero-actions"><a class="btn" href="mailto:kontakt@kamilniedziejko.pl?subject=Konsultacja%20-%20zg%C5%82oszenie%20sprawy">Skontaktuj sie</a></div>
      </div>
      <div class="contact-card">
        <p><strong>ADWOKAT KAMIL NIEDZIEJKO</strong></p>
        <p>ul. Dobrego Pasterza 189<br>31-416 Krakow</p>
        <p><a href="mailto:kontakt@kamilniedziejko.pl">kontakt@kamilniedziejko.pl</a></p>
        <p><a href="tel:+48512458132">+48 512 458 132</a></p>
        <figure class="contact-media" aria-hidden="true"><img src="assets/images/web/contact-6.jpg" alt="" width="800" height="600" loading="lazy" decoding="async"></figure>
      </div>
    </div>
  </section>"""
pat = re.compile(r'<section id="kontakt">.*?</section>', re.DOTALL)
s = pat.sub(block, s) if pat.search(s) else s
p.write_text(s, encoding="utf-8")
print("T06 contact replaced")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
block = """
.contact-grid{display:grid;grid-template-columns:1fr 1fr;gap:5rem;align-items:start;}
.contact-lead{color:var(--muted);max-width:32em;}
.contact-card{background:var(--surface);border:1px solid var(--line);padding:2.2rem;}
.contact-card a{text-decoration:underline;text-underline-offset:3px;}
.contact-media{margin:1.5rem 0 0;}
.contact-media img{aspect-ratio:4/3;object-fit:cover;}
@media (max-width:900px){.contact-grid{grid-template-columns:1fr;gap:2.5rem;}}
"""
if ".contact-grid" not in s:
    s = s.rstrip() + "\n" + block.strip() + "\n"
p.write_text(s, encoding="utf-8")
print("T06 css ok")
PY
python3 scripts/check_site.py
rm -f index.html.bak.T06
echo "crop-marker contact-6 desk-card" > reports/T06_crop.txt
echo "T06 done"
