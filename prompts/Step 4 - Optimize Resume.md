Attached are up to six inputs:

1. **The 'full' version of the candidate's resume** (HTML, `inputs/resume_full.html`) — the source of truth for content and the template for formatting. Every claim in the output must trace back to this document. Preserve the existing HTML structure, sections, and styling; only edit content.
2. **The candidate profile** (`inputs/profile.md`) — name, `file_prefix` for the output filename, location, and work authorization.
3. **The job description** for the role the candidate is applying to.
4. **A prioritized ATS keyword list** for the role.
5. **A match chart** showing which rubric rows are STRONG / PARTIAL / INFERRED / GAP against the source resume.
6. **`resume-creation-failure-feedback.md`** at the project root — the running log of past failures on this exact workflow.

## Read this first

Before writing any resume content, open `resume-creation-failure-feedback.md` and read every entry. In your tailoring report (see Output), include an **"Avoided prior failures"** section that lists — by category tag — the failure patterns you deliberately steered clear of on this draft, with one line per category naming the specific temptation you resisted (e.g., "internal-jargon: source had 'ConversationContext model'; wrote 'multi-turn conversation model' instead").

If you finish drafting and cannot fill in that section honestly for the categories relevant to this JD, you have not read the log carefully enough. Reread it.

If the log is missing or has no entries yet, write "No prior failures logged yet" in that section and instead list which of the Anti-patterns below you checked for on this draft.

## Your task

Produce a tailored version of the resume as a new HTML file.

Derive the company folder name from the JD: kebab-case of the hiring organization (e.g., "Acme Corp" → `acme-corp`, "OpenAI" → `openai`). If the JD does not name the organization, use `unknown-org-<short-role-slug>`.

Output path:

`applications/<company-name-kebab>/<file_prefix>-Resume-<role>-at-<company>.html`

`<file_prefix>` comes from `inputs/profile.md` (e.g. `Jane-Doe`). `<role>` and `<company>` are the job title and organization in Title-Case-With-Hyphens (e.g. `Senior-Software-Engineer`, `Acme-Corp`).

Create the folder if it does not exist. So the HTML renders standalone, either copy the source resume's CSS file into the same folder (adjusting the `<link>` href accordingly) or inline the styles into the HTML.

## Rules

### Content sourcing

- **No fabrication.** Every skill, tool, employer, date, achievement, and metric must come from the source resume. Rewording is allowed. Inventing is not.
- **Quantified outcomes only when the source resume provides them.** Do not invent numbers. Do not move a metric from one bullet to another — a number that lived on Product A in the source may not appear on Product B in the tailored resume (`misattribution` / `metric-swap`).
- **No `rubric-gap-overreach`.** Rubric GAPs are for the tailoring report only. Do not invent scope words to close a GAP row. The following words are banned unless they appear verbatim in the source resume for the same role: `sole`, `only`, `single-handedly`, `owned end-to-end`, `led`, `architected`, `drove`, `spearheaded`, `founded`.

### Keyword insertion

- **Prefer exact JD wording over synonyms.** If the JD says "Google Cloud Platform," write "Google Cloud Platform," not "GCP" (unless the JD also uses the acronym, in which case use both).
- **Additive keyword insertion only, and only as generalization.**
    - Allowed: "Postgres" → "Postgres (relational database)" when the JD says "relational databases" — because Postgres *is* a relational database.
    - Not allowed: "Python" → "C#" (different technology).
    - Not allowed: "React" → "React (Svelte-transferable)" — jumping to a different technology and hedging.
    - Not allowed: adding "led a team of 10" when the source says "collaborated with a team."
- **Banned hedge-suffixes.** The tokens `-transferable`, `-adjacent`, `-like`, and `-equivalent` are prohibited anywhere in the tailored resume. If the technology is not on the source resume, it does not go on the tailored resume — even with a hedge.

### Voice, style, and structure

- **Include only JD-relevant material.** Cut roles, projects, and bullets that don't map to the JD.
- **Reverse-chronological order within each section is a hard rule that overrides perceived JD-relevance.** Do not reorder Experience to lead with the most JD-relevant role after the current one — sort by end-date, descending, always.
- **3–5 bullets per Experience role. This is a hard floor and a hard ceiling.**
    - If a role has fewer than 3 honest source bullets, **cut the entire role.** Do not emit 2 bullets. Do not pad.
    - If a role has more than 5 candidate bullets, **choose 5.** Do not emit 6. Do not cram.
    - A Project with 3 bullets while a paid full-time job has 2 signals that the job was less substantial than a class assignment — that inversion is a symptom that a role should have been cut.
- **Bullet #1 for each role should be the most JD-relevant achievement** — recruiters skim top-down.
- **Bullets in STAR form** (Situation/Task → Action → Result), max two sentences each.
- **Strong action verbs** that signal ownership (`Architected`, `Led`, `Owned`, `Drove`, `Shipped`, `Migrated`, `Reduced`) — subject to the banned-word rule above (must be source-supported).
- **Exactly two Projects entries**, the two most JD-relevant from the source.
- **Summary line** may bridge to the company's mission or domain only if the source resume supports the domain claim. No invented culture fit, no cliché filler ("results-driven professional," "passionate about leveraging synergies").
- **Match the source's em-dash density.** Count em-dashes in the source resume (both `&mdash;` and `—`) and do not exceed that count in the tailored resume. Every added em-dash is almost always carrying a smuggled JD-flavored appositive — cutting the em-dash forces cutting the smuggled clause, which is the actual fix.

### Anti-patterns (from `resume-creation-failure-feedback.md`)

The following patterns have all appeared repeatedly and are hard-banned:

- **`internal-jargon`.** No internal project names, internal acronyms, internal table names, or team-internal terminology. If a phrase would require an ex-colleague to explain, rewrite generically ("system-prompt evaluation subsystem," not the internal name).
- **`implementation-detail-noise`.** PR counts (`"18-PR feature line"`), table counts (`"three-table schema"`), migration types (`JSONB migrations`), design-pattern names (`singleton`, `registry factory`, `adapter`), and other internal-workflow metrics do not belong in bullets. Recruiters get no signal from them; ATS gets no credit for them.
- **`conflation`.** Do not weld two unrelated efforts together with an em-dash to fit a bullet budget. If both efforts are worth including, they are two bullets. If only one is, cut the other.
- **`analogy-smuggling`.** No "the same [X] as [target company]'s [Y]" constructions. No "a problem analogous to what [target company] does." These are cover-letter rhetoric wearing resume grammar.
- **Target-company name is banned inside the resume body.** Do not name the target company in the Summary, in any bullet, or in any project description. A resume is a claim about the candidate's past, not a pitch to a specific employer. (Domain bridge in Summary is allowed only when it does not name the company — e.g., "10 years in the healthcare sector" is fine; "…that maps directly to [Company]'s mission" is not.)
- **`seniority-inflation`.** Do not invent scope-signals ("sole platform engineer," "led a team of N," "owned end-to-end") to counter a rubric yellow flag. This is the same failure mode as `rubric-gap-overreach`.

## Output

1. Write the tailored HTML file at the path specified above.
2. Write a **Tailoring Report** to `applications/<company-name-kebab>/04-tailoring-report.md` and also echo it in chat. It must contain, in this order:
    - **Avoided prior failures** — the category-by-category list described in "Read this first."
    - **Keywords surfaced** — which prioritized keywords ended up in the resume and where (Summary / Skills / which bullet).
    - **Keywords omitted** — any high-priority keyword you could not honestly include, with a one-line reason.
    - **Bullets rewritten** — before/after for the top 3–5 rewrites.
    - **Cuts made** — which roles, projects, or bullets you dropped and why.
    - **Hard-threshold gaps** — any JD requirement the candidate does not have (credential, license, work authorization, minimum years in a named function). Do not paper over these.
    - **Pre-flight self-review** (see below). This section must appear before the Fabrication check.
    - **Fabrication check** — one-line confirmation that every claim traces to the source. If you were tempted to stretch, name where.

### Pre-flight self-review (mandatory section of the report)

Fill in every item below with concrete values read from the file you just wrote. If any check fails, revise the resume and re-run the check before finalizing.

- **Bullet count per Experience role.** List every role in the tailored resume with its bullet count (e.g., `Acme Corp: 4`, `Globex: 4`, `Initech: 3`). **Any value outside 3–5 is a failure.** If a role has fewer than 3 honest bullets, cut the role and re-run this check.
- **Experience order.** List each role with its end-date in the order it appears. Confirm dates are strictly non-increasing (reverse-chronological).
- **Em-dash count.** Report the em-dash count in the tailored resume (count both `&mdash;` and `—`) and the em-dash count in the source resume. Tailored must be ≤ source.
- **Target company name scan.** Report the number of occurrences of the target company's name in the resume body (excluding the `<title>` and filename). Must be 0.
- **Banned-phrase scan.** For each of the following tokens, list every occurrence in the tailored resume (must all be empty):
    - `-transferable`, `-adjacent`, `-like`, `-equivalent`
    - `sole`, `single-handedly`, `only engineer`
    - `the same … as`, `analogous to`
    - Any internal-jargon token you identified in the "Avoided prior failures" section
- **Per-bullet source trace.** For the top 5 bullets across the resume (Bullet #1 of each role, then Projects), cite the line number(s) in `inputs/resume_full.html` the bullet derives from. Any bullet with no citable source line must be cut.
- **Repeat-failure check.** For each category listed in "Avoided prior failures," confirm in one line that this draft does not repeat it.
