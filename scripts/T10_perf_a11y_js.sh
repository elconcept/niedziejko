#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T10" || true
cp -f assets/js/main.js "assets/js/main.js.bak.T10" || true
for f in assets/images/web/hero-9 assets/images/web/about-4 assets/images/web/practice-3 assets/images/web/values-5 assets/images/web/contact-6; do
  if [ -f "$f.jpg" ] && [ ! -f "$f.webp" ]; then magick "$f.jpg" -quality 80 "$f.webp" 2>/dev/null || true; fi
done
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
if 'rel="preload" as="image"' not in s:
    s = s.replace("</title>", "</title>\n<link rel=\"preload\" as=\"image\" href=\"assets/images/web/hero-9.jpg\" fetchpriority=\"high\">", 1)
s = s.replace('<img src="assets/images/web/about-4.jpg"', '<img src="assets/images/web/about-4.jpg" srcset="assets/images/web/about-4.webp 1x"')
p.write_text(s, encoding="utf-8")
q = root / "assets/js/main.js"
j = q.read_text(encoding="utf-8")
j = re.sub(r'\n{3,}', '\n\n', j).strip() + "\n"
q.write_text(j, encoding="utf-8")
lines = len(j.splitlines())
print(f"T10 js lines={lines}")
assert lines < 150, f"main.js too long: {lines}"
print("T10 perf/a11y ok")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
bad = []
for f in (root / "assets/images/web").glob("*.jpg"):
    if f.stat().st_size > 400 * 1024:
        bad.append(f"{f.name}={f.stat().st_size}")
assert not bad, f"oversize: {bad}"
print("images <=400KB ok")
PY
python3 scripts/check_site.py
rm -f index.html.bak.T10 assets/js/main.js.bak.T10
echo "T10 done"
