#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T09" || true
magick assets/images/web/hero-9.jpg -resize 1200x630^ -gravity center -extent 1200x630 -quality 84 og-image.jpg
printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64"><rect width="64" height="64" fill="#2F241D"/><text x="32" y="42" font-family="Georgia,serif" font-size="28" fill="#F7F4EF" text-anchor="middle">KN</text></svg>' > favicon.svg
python3 - "$ROOT" <<'PY'
import pathlib, sys, re
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
s = s.replace("https://niedziejko.pl/assets/images/web/hero-9.jpg", "https://niedziejko.pl/og-image.jpg")
s = s.replace("assets/images/web/2.jpg", "og-image.jpg")
if "og-image.jpg" not in s:
    s = s.replace("</title>", "</title>\n<meta property=\"og:image\" content=\"https://niedziejko.pl/og-image.jpg\">")
schema = """<script type="application/ld+json">
{"@context":"https://schema.org","@type":"LegalService","name":"Adwokat Kamil Niedziejko","url":"https://niedziejko.pl","telephone":"+48512458132","email":"kontakt@kamilniedziejko.pl","address":{"@type":"PostalAddress","streetAddress":"ul. Dobrego Pasterza 189","postalCode":"31-416","addressLocality":"Krakow","addressCountry":"PL"},"areaServed":"Krakow"}
</script>"""
s = re.sub(r'<script type="application/ld\+json">.*?</script>', schema, s, flags=re.DOTALL)
if '<link rel="icon"' not in s:
    s = s.replace('<link rel="stylesheet"', '<link rel="icon" href="favicon.ico">\n<link rel="icon" type="image/svg+xml" href="favicon.svg">\n<link rel="apple-touch-icon" href="assets/icons/apple-touch-icon.png">\n<link rel="stylesheet"')
p.write_text(s, encoding="utf-8")
(root / "robots.txt").write_text("User-agent: *\nAllow: /\n\nSitemap: https://niedziejko.pl/sitemap.xml\n", encoding="utf-8")
(root / "sitemap.xml").write_text('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n  <url><loc>https://niedziejko.pl/</loc><changefreq>weekly</changefreq><priority>1.0</priority></url>\n</urlset>\n', encoding="utf-8")
(root / "404.html").write_text('<!DOCTYPE html>\n<html lang="pl">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width,initial-scale=1">\n<title>Nie znaleziono strony | Adwokat Kamil Niedziejko</title>\n<link rel="stylesheet" href="assets/css/styles.css">\n</head>\n<body>\n<main class="container" style="padding:6rem 0;text-align:center;">\n<p class="eyebrow">Adwokat Kamil Niedziejko</p>\n<h1>Nie znaleziono strony.</h1>\n<p><a href="/">Wroc na strone glowna</a></p>\n</main>\n</body>\n</html>\n', encoding="utf-8")
print("T09 seo ok")
PY
python3 scripts/check_site.py
python3 -c "import json,pathlib,re;s=pathlib.Path('index.html').read_text(encoding='utf-8');m=re.search(r'<script type=\"application/ld\+json\">(.*?)</script>',s,re.DOTALL);json.loads(m.group(1));print('JSON-LD valid');assert 'og-image.jpg' in s;print('OG ok')"
rm -f index.html.bak.T09
echo "T09 done"
