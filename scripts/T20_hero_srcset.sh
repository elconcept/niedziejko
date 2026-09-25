#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
magick assets/images/web/hero-9.jpg -strip -resize 800x800\> -quality 80 assets/images/web/hero-9-800.jpg
magick assets/images/web/hero-9-800.jpg -quality 78 assets/images/web/hero-9-800.webp 2>/dev/null || true
ls -l assets/images/web/hero-9-800.jpg assets/images/web/hero-9-800.webp
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
old = '<img src="assets/images/web/hero-9.jpg"'
new = ('<img src="assets/images/web/hero-9.jpg" '
       'srcset="assets/images/web/hero-9-800.webp 800w, assets/images/web/hero-9.webp 1200w" '
       'sizes="(max-width: 900px) 100vw, 50vw"')
assert old in s, "hero img not found"
assert "hero-9-800" not in s, "already applied"
s = s.replace(old, new, 1)
p.write_text(s, encoding="utf-8")
print("T20 hero srcset ok")
PY
python3 scripts/check_site.py
echo "T20 done"
