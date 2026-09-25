# Acceptance T11

- URL: https://niedziejko.pl
- CNAME: niedziejko.pl
- check_site: PASS
- sweep (banned/copy/links/files/sizes/schema): PASS
- og-image: 1200 x 630, 68052 bytes
- hero-9: 82967 bytes + webp 43494 bytes
- Lighthouse: MANUAL (run Chrome DevTools on https://niedziejko.pl after deploy; gate >=95 P/A/BP/SEO)
- Pages/HTTPS: MANUAL (gh api repos/{owner}/{repo}/pages -> status==built, cname==niedziejko.pl, https_enforced==true; confirm owner/repo, open_question from plan)
- Release: commit-ready, message 'Production release v1' (not committed by executor)
