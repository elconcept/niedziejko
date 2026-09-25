#!/usr/bin/env bash
# CANONICAL end-of-run hook: validate, commit, push. Every run ends here.
# Usage: bash scripts/on_run_end.sh "Txx: message"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
MSG="${1:-chore: end of run}"
python3 scripts/check_site.py
git add -- index.html assets 404.html robots.txt sitemap.xml favicon.svg favicon.ico og-image.jpg CNAME plan.md tasks.json scripts reports
if [ -z "$(git status --porcelain -- index.html assets 404.html robots.txt sitemap.xml favicon.svg favicon.ico og-image.jpg CNAME plan.md tasks.json scripts reports)" ]; then
  echo "on_run_end: nothing to commit, pushing in case ahead"
else
  git commit -m "$MSG"
fi
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git push origin "$BRANCH"
echo "on_run_end: done ($MSG)"
