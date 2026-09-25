#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
mkdir -p reports
python3 scripts/check_site.py
python3 - "$ROOT" <<'PY'
import pathlib, re, sys, unicodedata, json
root = pathlib.Path(sys.argv[1])
s = (root / "index.html").read_text(encoding="utf-8")
errs = []
for needle in ["web/2.jpg", "thumbs/2.jpg", '"2.png', "/2.jpg", "identyfikacja"]:
    if needle in s: errs.append(f"forbidden string present: {needle}")
def strip_acc(t):
    return ''.join(c for c in unicodedata.normalize('NFD', t) if unicodedata.category(c) != 'Mn').lower()
low = strip_acc(s)
for phrase in ["kompleksowa obsluga", "najwyzsza jakosc", "indywidualne podejscie", "profesjonalne uslugi"]:
    if phrase in low: errs.append(f"generic phrase present: {phrase}")
for a in ['href="#praktyka"', 'href="#o-kancelarii"', 'href="#wartosci"', 'href="#kontakt"']:
    if a not in s: errs.append(f"missing {a}")
for sid in ['id="praktyka"', 'id="o-kancelarii"', 'id="wartosci"', 'id="kontakt"']:
    if sid not in s: errs.append(f"missing {sid}")
if 'mailto:kontakt@kamilniedziejko.pl' not in s: errs.append("mailto missing")
if 'tel:+48512458132' not in s: errs.append("tel missing")
for f in ["assets/css/styles.css", "assets/js/main.js", "og-image.jpg", "favicon.svg", "robots.txt", "sitemap.xml", "404.html", "CNAME"]:
    if not (root / f).exists(): errs.append(f"missing file {f}")
    elif (root / f).stat().st_size == 0: errs.append(f"empty file {f}")
for f in (root / "assets/images/web").glob("*.jpg"):
    if f.stat().st_size > 400 * 1024: errs.append(f"oversize {f.name}")
m = re.search(r'<script type="application/ld\+json">(.*?)</script>', s, re.DOTALL)
json.loads(m.group(1))
print("T11 sweep:", "PASS" if not errs else "FAIL")
for e in errs: print(" -", e)
sys.exit(0 if not errs else 1)
PY
{
echo "# Acceptance T11"
echo ""
echo "- URL: https://niedziejko.pl"
echo "- CNAME: $(cat CNAME)"
echo "- check_site: PASS"
echo "- sweep (banned/copy/links/files/sizes/schema): PASS"
echo "- og-image: $(magick identify -format '%w x %h, %B bytes' og-image.jpg)"
echo "- hero-9: $(stat -c '%s bytes' assets/images/web/hero-9.jpg) + webp $(stat -c '%s bytes' assets/images/web/hero-9.webp)"
echo "- Lighthouse: MANUAL (run Chrome DevTools on https://niedziejko.pl after deploy; gate >=95 P/A/BP/SEO)"
echo "- Pages/HTTPS: MANUAL (gh api repos/{owner}/{repo}/pages -> status==built, cname==niedziejko.pl, https_enforced==true; confirm owner/repo, open_question from plan)"
echo "- Release: commit-ready, message 'Production release v1' (not committed by executor)"
} > reports/acceptance.md
cat reports/acceptance.md
echo "T11 done"
