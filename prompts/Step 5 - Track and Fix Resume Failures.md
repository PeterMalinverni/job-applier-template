Attached are up to six inputs:

1. **User feedback** — the free-form critique the user just gave on the tailored resume. This is the primary driver of the work.
2. **The tailored resume HTML** at `applications/<company-name-kebab>/<file_prefix>-Resume-<role>-at-<company>.html`.
3. **The tailoring report** at `applications/<company-name-kebab>/04-tailoring-report.md`.
4. **The source resume** at `inputs/resume_full.html` — the only legal source of claims.
5. **The job description, ATS keywords, and fit assessment** for context on why bullets were framed the way they were.
6. **`resume-creation-failure-feedback.md`** at the project root — the running log of past failures. If it has no entries yet, start numbering at 1.

## Your task

Do three things, in order:

### 1. Log the failures

Append one new dated section to `resume-creation-failure-feedback.md`, following the existing format exactly. Read the top of that file first — it defines the "How to read this file" contract (Date/application, Failure quoted verbatim, Context, Category) and every prior entry follows it. Match it.

Rules:

- **One numbered entry per distinct failure mode.** If the user's feedback names five problems, log five entries (continue the global numbering from the last entry in the file).
- **Quote the offending output verbatim** from the current tailored resume. Do not paraphrase the failure.
- **Explain in Context what the source resume actually supports** (or does not) and why the LLM's output violated the Step 4 prompt, the user's feedback, or a prior failure-log entry.
- **Tag Category with short kebab-or-lowercase tags** matching the existing vocabulary where possible: `fabrication`, `misattribution`, `metric-swap`, `ordering`, `keyword-stuffing`, `prompt-rule-violation`, `bullet-count`, `internal-jargon`, `conflation`, `implementation-detail-noise`, `rubric-gap-overreach`, `seniority-inflation`, `analogy-smuggling`, `repeat-failure`, `role-under-development`. Invent a new tag only when none of the existing ones fit.
- **Flag repeats.** If the current failure matches a prior entry's category and pattern, add `repeat-failure` to Category and reference the prior entry number in Context (e.g., "same pattern as #4 on Acme Corp").
- **Do not sanitize.** The user's feedback may be blunt. The log entry should reflect the substance of what went wrong, not soften it. Do not editorialize about the user's tone.

### 2. Fix the resume

Rewrite `applications/<company-name-kebab>/<file_prefix>-Resume-<role>-at-<company>.html` in place so that **every logged failure is addressed**.

Rules:

- **Apply every rule from `prompts/Step 4 - Optimize Resume.md`.** All Step 4 constraints still bind: no fabrication, additive keyword insertion only (generalization only, no hedge-suffixes), JD-relevant material only, 3–5 bullets per Experience role as a hard floor and ceiling, STAR bullets, strong action verbs, exactly two Projects, preserve HTML/CSS structure, reverse-chronological within each section, banned anti-patterns (`internal-jargon`, `implementation-detail-noise`, `conflation`, `analogy-smuggling`, target-company name in resume body, `seniority-inflation`), and source em-dash density.
- **You must run the Step 4 Pre-flight self-review against the revised resume** and include its results in the updated tailoring report (see step 3 below). A revision that does not pass the pre-flight is not finished.
- **Every claim must trace to `inputs/resume_full.html`.** If a failure was a fabrication, the fix is either to cut the bullet or to reground it in verifiable source material. Do not reword a fabrication into a fresh fabrication.
- **When in doubt, cut.** A missing bullet is better than a stretched one. If a section drops below 3 bullets and no honest third bullet exists in the source, cut the entire role instead of padding.
- **Preserve JD-relevant keywords already surfaced** unless they were themselves part of the failure. Do not silently regress keyword coverage from the prior draft.
- **Do not restructure sections, add new sections, or change the CSS** — content edits only.

### 3. Update the tailoring report

Rewrite `applications/<company-name-kebab>/04-tailoring-report.md` so it reflects the *current* state of the resume, and add a new section titled **"Revisions from prior draft (feedback loop)"** that:

- Lists each failure that was fixed, numbered to match the entries just appended to `resume-creation-failure-feedback.md`.
- States exactly what was changed (cut, reworded, replaced) for each.
- Confirms the bullet count per Experience role.

Keep the existing Avoided prior failures / Keywords surfaced / Keywords omitted / Bullets rewritten / Cuts made / Hard-threshold gaps / Pre-flight self-review / Fabrication check sections; update them to match the current resume. The Pre-flight self-review must reflect the revised file, not the prior draft.

## Output

1. Append new entries to `resume-creation-failure-feedback.md`.
2. Overwrite `applications/<company-name-kebab>/<file_prefix>-Resume-<role>-at-<company>.html`.
3. Overwrite `applications/<company-name-kebab>/04-tailoring-report.md`.
4. In chat, return: the numbered failures logged (one line each), the fix applied for each (one line each), the final bullet count per Experience role, the em-dash count vs. source, the banned-phrase scan result, and a one-line fabrication check confirming every claim traces to the source.
