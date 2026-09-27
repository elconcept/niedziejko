#!/usr/bin/env python3
"""Cache-bust every asset reference: rewrite ?v=<content hash> on assets/... URLs in the pages.

Cloudflare/browsers cache assets for hours; without this a changed file under an
unchanged name (CSS, JS, images) is served stale. Run before every commit.
"""
import hashlib, pathlib, re

root = pathlib.Path(__file__).resolve().parents[1]
# fonts are excluded: their preload URL must equal the url() in styles.css
REF = re.compile(r"(/?)(assets/(?!fonts/)[\w./-]+\.\w+)(\?v=[0-9a-f]+)?")


def digest(rel):
    return hashlib.sha256((root / rel).read_bytes()).hexdigest()[:10]


for page in ["index.html", "404.html"]:
    p = root / page
    s = p.read_text(encoding="utf-8")
    s = REF.sub(lambda m: f"{m.group(1)}{m.group(2)}?v={digest(m.group(2))}", s)
    p.write_text(s, encoding="utf-8", newline="\n")
print("stamp_assets: OK")
