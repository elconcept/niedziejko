#!/usr/bin/env bash
set -euo pipefail

cp index.html index.html.bak.$(date +%s)

python3 <<'PY'
from pathlib import Path

p = Path("index.html")

if not p.exists():
    raise SystemExit("Brak index.html")

html = p.read_text(encoding="utf-8")

header = """
<header class="site-header">
  <div class="container">
    <div class="site-header-inner">

      <div class="site-logo">
        KAMIL NIEDZIEJKO
      </div>

      <nav class="site-nav">
        <a href="#prakyka</a>
        <a href="#o-kKancelaria</a>
        <aartosciWartości</a>
        <a href="#kontakt">
      </nav>

    </div>
  </div>
</header>
"""

if '<header class="site-header">' not in html:
    html = html.replace(
        "<body>",
        "<body>\n" + header,
        1
    )

if 'assets/js/main.js' not in html:
    html = html.replace(
        "</body>",
       ' \n<script src="assets/js/main.js"></script>'
    )

html = html.replace(
    '<figure class="hero-image">\n                assets/images/web/2.jpg\n            </figure>',
    '<figure class="hero-image">assets/images/web/2.jpg</figure>'
)

html = html.replace(
    '<figure class="about-image">\n                assets/images/web/4.jpg\n            </figure>',
    '<figure class="about-image">assets/images/web/4.jpg</figure>'
)
gallery_map = {
    "assets/images/thumbs/1.jpg":"Identyfikacja wizualna",
    "assets/images/thumbs/3.jpg":"Obszary praktyki",
    "assets/images/thumbs/5.jpg":"Wartości kancelarii",
    "assets/images/thumbs/6.jpg":"Kontakt",
    "assets/images/thumbs/7.jpg":"Paleta kolorów",
    "assets/images/thumbs/8.jpg":"Typografia"
}

for file, alt in gallery_map.items():
    html = html.replace(
        f"<figure>\n                {file}\n            </figure>",
        f'<figure>{file}</figure>'
    )

p.write_text(html, encoding="utf-8")

print("index.html zaktualizowany")
PY

echo
echo "OK"
echo
echo "Nastepny krok:"
echo "07_build_seo_and_schema.sh"
