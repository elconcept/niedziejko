#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/icons

cat > robots.txt <<'ROBOTS'
User-agent: *
Allow: /

Sitemap: https://niedziejko.pl/sitemap.xml
ROBOTS

cat > sitemap.xml <<'SITEMAP'
<?xml version="1.0" encoding="UTF-8"?>

<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

  <url>
    <loc>https://niedziejko.pl/</loc>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>

</urlset>
SITEMAP

cat > CNAME <<'CNAME'
niedziejko.pl
CNAME

python3 <<'PY'
from pathlib import Path

p = Path("index.html")

if not p.exists():
    raise SystemExit("Brak index.html")

html = p.read_text(encoding="utf-8")

seo_block = r'''
<meta name="robots" content="index,follow,max-image-preview:large">
<meta name="author" content="Kamil Niedziejko">
<meta name="theme-color" content="#25211d">

<link rel="canonical" href="https://niedziejko.pl/">

<meta property="og:title" content="Adwokat Kamil Niedziejko">
<meta property="og:description" content="Prawo karne, cywilne, rodzinne oraz reprezentacja przed sądami.">
<meta property="og:type" content="website">
<meta property="og:url" content="https://niedziejko.pl/">
<meta property="og:image" content="https://niedziejko.pl/assets/images/web/2.jpg">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Adwokat Kamil Niedziejko">
<meta name="twitter:description" content="Pomoc prawna dla klientów indywidualnych i przedsiębiorców.">
<meta name="twitter:image" content="https://niedziejko.pl/assets/images/web/2.jpg">

<script type="application/ld+json">
{
  "@context":"https://schema.org",
  "@type":"LegalService",
  "name":"Adwokat Kamil Niedziejko",
  "url":"https://niedziejko.pl",
  "telephone":"+48512458132",
  "email":"kontakt@kamilniedziejko.pl",
  "address":{
    "@type":"PostalAddress",
    "streetAddress":"ul. Dobrego Pasterza 189",
    "postalCode":"31-416",
    "addressLocality":"Kraków",
    "addressCountry":"PL"
  }
}
</script>
'''

if '"application/ld+json"' not in html:
    html = html.replace(
        "</head>",
        seo_block + "\n</head>"
    )

p.write_text(html, encoding="utf-8")
PY

if [ -f assets/images/original/1.png ]; then

    if command -v magick >/dev/null 2>&1; then

        magick assets/images/original/1.png \
            -resize 512x512 \
            assets/icons/icon-512.png

        magick assets/images/original/1.png \
            -resize 192x192 \
            assets/icons/icon-192.png

        magick assets/images/original/1.png \
            -resize 180x180 \
            assets/icons/apple-touch-icon.png

        magick assets/images/original/1.png \
            -resize 64x64 \
            favicon.ico

    elif command -v convert >/dev/null 2>&1; then

        convert assets/images/original/1.png \
            -resize 512x512 \
            assets/icons/icon-512.png

        convert assets/images/original/1.png \
            -resize 192x192 \
            assets/icons/icon-192.png

        convert assets/images/original/1.png \
            -resize 180x180 \
            assets/icons/apple-touch-icon.png

        convert assets/images/original/1.png \
            -resize 64x64 \
            favicon.ico
    fi

fi

echo
echo "SEO gotowe"
echo "robots.txt"
echo "sitemap.xml"
echo "CNAME"
echo "schema.org JSON-LD"
echo "OpenGraph"
echo "favicon.ico"
echo

echo "Nastepny krok:"
echo "08_build_real_content_and_fix_markup.sh"
echo
