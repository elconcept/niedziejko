#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
cp -f index.html "index.html.bak.T17" || true
cp -f assets/css/styles.css "assets/css/styles.css.bak.T17" || true
python3 - "$ROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
p = root / "index.html"
s = p.read_text(encoding="utf-8")
if "<main>" not in s:
    s = s.replace("</header>", "</header>\n\n<main>", 1)
    s = s.replace("<footer>", "</main>\n\n<footer>", 1)
p.write_text(s, encoding="utf-8")
print("T17 main landmark ok")
PY
python3 - "$ROOT" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
p = root / "assets/css/styles.css"
s = p.read_text(encoding="utf-8")
s = s.replace(".eyebrow{font-size:.72rem;letter-spacing:.28em;text-transform:uppercase;color:var(--muted);}",
              ".eyebrow{font-size:.72rem;letter-spacing:.28em;text-transform:uppercase;color:#6E665B;}")
s = re.sub(r"(\.eyebrow\{[^}]*?)color:var\(--muted\);",
              r"\1color:#6E665B;", s, count=1)
p.write_text(s, encoding="utf-8")
print("T17 eyebrow contrast ok")
PY
python3 scripts/check_site.py
python3 -c "import pathlib;s=pathlib.Path('index.html').read_text(encoding='utf-8');assert '<main>' in s and '</main>' in s, 'main missing';print('main gate ok')"
rm -f index.html.bak.T17 assets/css/styles.css.bak.T17
echo "T17 done"
