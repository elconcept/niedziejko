# Canonical rule

Every run ends with commit + push. No exceptions.

- After each task/run: `bash scripts/on_run_end.sh "Txx: message"`.
- The hook validates (`scripts/check_site.py`, fail closed), stages only project paths
  (never pre-existing clutter), commits if there is anything to commit, and pushes.
- Belt and suspenders: `.git/hooks/post-commit` auto-pushes every commit on `main`.
  If the hook's push fails (offline/auth), the run is NOT done — fix and push manually.
- Rollback: `git revert HEAD` (single-task commits) or `git reset --hard <hash>`.

## Fail-closed amendment (2026-09-25)
A task script exiting non-zero MUST NOT be followed by on_run_end.sh.
Fix forward in a new commit (Txxb). Never commit a claimed-but-unapplied change.
