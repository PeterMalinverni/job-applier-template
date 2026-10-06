# How to Find a Company's Careers Page (the one with current postings)

Lessons from finding the careers pages of 40 target companies. Roughly 35 of 40 were resolved quickly with steps 1–3. Once you have a posting, save it with `./scripts/add-job.sh <company> <file>`.

## Fastest workflow

1. **Fetch the homepage and grep the links.** Look for `href`s containing `career`, `jobs`, `join`, `work-with-us`, or a known ATS domain. About half of the companies exposed their careers link this way, usually in the footer. A one-liner works:
   `curl -sL -A "Mozilla/5.0" https://example.com/ | grep -oiE 'href="[^"]*(career|jobs|join)[^"]*"'`
2. **Open the careers page and grep it for ATS links.** Most small companies embed or link to an applicant tracking system, and that board is the real list of postings. Recognize these hosts:
   - Greenhouse: `boards.greenhouse.io/<co>`, `job-boards.greenhouse.io/<co>`, `job-boards.eu.greenhouse.io/<co>`
   - Ashby: `jobs.ashbyhq.com/<co>`
   - Lever: `jobs.lever.co/<Co>` (slug is case-sensitive)
   - Workable: `apply.workable.com/<co>`
   - BambooHR: `<co>.bamboohr.com/careers`
   - Others seen: Recruitee, Teamtailor, Darwinbox, careers-page.com, Workday (`*.myworkdayjobs.com`), Dover
3. **If step 1 finds nothing, try common paths:** `/careers`, `/career`, `/jobs`, `/join`, `/join-us`, `/about/careers`, `/company/careers`, `/about#careers`.
4. **If that fails or the site blocks bots, web-search** `"<company> careers"` or `"<company> jobs"`. The official page or ATS board is almost always in the top results, even when curl gets a 403.
5. **Last resorts:** the company's LinkedIn `/jobs` tab, Y Combinator's `ycombinator.com/companies/<co>/jobs` for YC startups, and job boards (Built In, Wellfound, or one specific to your field). These show that a company hires but are third-party, so prefer a first-party page.

## Gotchas

- **Guessed paths can lie.** Some sites (e.g. Terrestrial Energy) return HTTP 200 for every URL. Check the page `<title>` and content, not just the status code.
- **Sites block bots.** Rocket Lab, Climeworks, and Form Energy returned 403 (Cloudflare) to curl. Their pages are real; use search results or open them in a browser. Their ATS boards were often reachable when the marketing site was not.
- **Postings are often JavaScript-rendered.** A fetch of Deep Sky, Thalo, Arcadia, Rhizome, or Terrestrial shows an empty shell or "Loading open roles…". You'll need a browser to see the actual list.
- **Companies rename or move domains.** Project Vesta moved from `projectvesta.org` to `vesta.earth`; Vibrant Planet from `.net` to `.com`. Old `/jobs` URLs 404. Follow redirects and re-check the homepage.
- **The URL in your list may be stale or not the careers page.** A list may have a bare domain, a LinkedIn URL, or a careers URL that had moved (GHGSat's `/en/careers/` is now a 404; the real board is on Workable).
- **A live-looking ATS link can be dead.** Floodbase's site links to `boards.greenhouse.io/floodbase`, which 404s. Verify the board loads. The Greenhouse and Ashby JSON APIs are a fast check:
  - `https://boards-api.greenhouse.io/v1/boards/<slug>/jobs`
  - `https://api.ashbyhq.com/posting-api/job-board/<slug>`
  - `https://api.lever.co/v0/postings/<Slug>`
  A 404 means the slug is wrong or the board doesn't exist. An empty `jobs` list means the board is real but has no openings right now (Capella Space).
- **Ashby/Lever HTML pages give 200 for fake slugs in some cases**, so use the API endpoints above to confirm a board really exists.
- **Some tiny startups have no careers page at all** (Sustaera, Nellie, Ebb Carbon, Equatic). Their sites have an email or nothing. Don't burn time; use LinkedIn or a job board and, if interested, an email to the contact address.
- **Guessing an ATS slug can land on the wrong company.** `jobs.lever.co/arcadia` exists but is Arcadia.io (healthcare), not arcadia.com (energy). Confirm a board's company from the job text or by finding the link on the company's own site.
- **When a careers page says "Loading open roles…", read its JavaScript.** Grepping the site's bundles (`/_next/static/*.js`) for `greenhouse|lever|ashby|rippling|workable` revealed Arcadia's real source, a Rippling feed at `/api/rippling-jobs`. Rippling boards live at `ats.rippling.com/<slug>`.
- **Prefer the direct ATS board when you have both.** It is usually cleaner, filterable, and doesn't depend on JavaScript on the company site.
