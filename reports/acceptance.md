# Acceptance — Production release v1

- URL: https://niedziejko.pl (HTTPS 200, HSTS, http->301)
- CNAME: niedziejko.pl, Pages: built
- Lighthouse desktop: 96/100/100/100 (LCP 1.1s)
- Lighthouse mobile (lab, 4x throttle): 81/100/100/100 (TBT 0, CLS 0, 408 KiB, zero opportunities)
- Banned asset 2: zero references. No overflow (0px both viewports, screenshot-verified).
- Known externals: Pages https_enforced toggle (dashboard), real-device glance.
