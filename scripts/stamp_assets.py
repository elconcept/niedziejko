#!/usr/bin/env python3
"""Cache-bust CSS/JS: rewrite ?v=<content hash> on their references in the HTML pages.

Cloudflare/browsers cache assets for hours; without this a new index.html gets an old
styles.css and the layout breaks. Run before every commit that touches CSS/JS.
"""
import hashlib, pathlib, re

root = pathlib.Path(__file__).resolve().parents[1]
assets = ["assets/css/styles.css", "assets/js/main.js"]
for page in ["index.html", "404.html"]:
    p = root / page
    s = p.read_text(encoding="utf-8")
    for a in assets:
        h = hashlib.sha256((root / a).read_bytes()).hexdigest()[:10]
        s = re.sub(re.escape(a) + r'(\?v=[0-9a-f]+)?"', f'{a}?v={h}"', s)
    p.write_text(s, encoding="utf-8", newline="\n")
print("stamp_assets: OK")
