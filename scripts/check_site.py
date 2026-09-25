#!/usr/bin/env python3
import pathlib, re, sys
root = pathlib.Path(__file__).resolve().parents[1]
idx = root / "index.html"
s = idx.read_text(encoding="utf-8")
errs = []
def chk(cond, msg):
    if not cond: errs.append(msg)
chk("web/2.jpg" not in s, "banned web/2.jpg still referenced")
chk("2.png" not in s or "quarantine" in s, "banned 2.png referenced in HTML")
chk('<link rel="stylesheet" href="assets/css/styles.css">' in s, "stylesheet link missing")
for a in ["#praktyka", "#o-kancelarii", "#wartosci", "#kontakt"]:
    chk(f'href="{a}"' in s, f"nav anchor {a} missing")
for sid in ["praktyka", "o-kancelarii", "kontakt"]:
    chk(f'id="{sid}"' in s, f"section id {sid} missing")
opens = len(re.findall(r"<section\b", s)) + len(re.findall(r"<header\b", s)) + len(re.findall(r"<div\b", s))
closes = len(re.findall(r"</section>", s)) + len(re.findall(r"</header>", s)) + len(re.findall(r"</div>", s))
chk(abs(opens - closes) <= 3, f"tag imbalance div/section/header open={opens} close={closes}")
for img in re.findall(r"<img\b[^>]*>", s):
    chk("alt=" in img, f"img missing alt: {img[:80]}")
print("check_site T01 gate:", "PASS" if not errs else "FAIL")
for e in errs: print(" -", e)
sys.exit(0 if not errs else 1)
