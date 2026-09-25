#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f assets/css/styles.css "assets/css/styles.css.bak.T16" || true
BEFORE=$(stat -c '%s' assets/css/styles.css)
python3 - "$ROOT" "$BEFORE" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
dead = [".hero-image", ".about-image", ".gallery", ".gallery figure",
        ".practice-panel-inner", ".practice-panel.is-open"]
removed = []
for sel in dead:
    pat = re.compile(r'(?m)^[ \t]*' + re.escape(sel) + r'\s*\{[^}]*\}\s*\n?')
    n = len(pat.findall(s))
    s = pat.sub('', s)
    removed.append((sel, n))
multi = re.compile(r'(?m)^[ \t]*\.(?:hero-image|about-image)[^\{]*img[^\{]*\{[^}]*\}\s*\n?|^[ \t]*\.gallery[^\{]*img[^\{]*\{[^}]*\}\s*\n?|^[ \t]*\.(?:hero-image|about-image)[^\{]*hover[^\{]*\{[^}]*\}\s*\n?|^[ \t]*\.gallery[^\{]*hover[^\{]*\{[^}]*\}\s*\n?')
mn = len(multi.findall(s))
s = multi.sub('', s)
s = re.sub(r'\n{3,}', '\n\n', s)
p.write_text(s, encoding="utf-8")
rep = [f"BEFORE={int(sys.argv[2])}"]
for sel, n in removed:
    rep.append(f"{sel}: removed {n}")
rep.append(f"multi-img/hover groups: removed {mn}")
after = len(s.encode("utf-8"))
rep.append(f"AFTER={after}")
(root / "reports" / "T16_optimize.txt").write_text("\n".join(rep) + "\n", encoding="utf-8")
print("\n".join(rep))
assert after < int(sys.argv[2]), "no reduction"
for sel in dead:
    assert re.search(r'(?m)^[ \t]*' + re.escape(sel) + r'\s*\{', s) is None, f"{sel} still present"
print("T16 prune ok")
PY
python3 scripts/check_site.py
rm -f assets/css/styles.css.bak.T16
echo "T16 done"
