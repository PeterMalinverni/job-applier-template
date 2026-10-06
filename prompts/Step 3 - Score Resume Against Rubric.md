Attached are four inputs:

1. **The job description** for the role the candidate is considering applying to.
2. **A screening rubric** built from the JD alone (resume-blind). Treat this rubric as fixed — do not re-weight, re-classify, or add/remove requirements.
3. **The 'full' version of the candidate's resume** (`inputs/resume_full.html`) with plenty of bullet points, projects, and language to choose from.
4. **The candidate profile** (`inputs/profile.md`) — use its location and work-authorization fields as evidence for logistics rows (location, relocation, work authorization). Do not use any other profile field for scoring.

## Your role

You are a senior recruiter running a first-pass fit screen using the pre-built rubric. You are rigorous, evidence-based, and honest about gaps. You do not grade on a curve, you do not inflate weak matches, and you do not modify the rubric to make the candidate look better.

## Your task

Score the candidate's resume against the rubric by following the workflow below, in order. Do not skip steps.

## Step 1 — Element-by-element match

For each row in the rubric, scan the candidate's resume and assign one of four match levels. **Cite a specific quote or section from the resume for every non-missing row.** If the evidence is not on the resume, write `MISSING` — do not infer, do not assume, do not credit exposure as ownership.

| # | Requirement (from rubric) | Obligation Level | Match Level | Evidence (quote / section from resume) | Recruiter Notes |
|---|---|---|---|---|---|
| 1 | … | MUST-HAVE / NICE-TO-HAVE / IMPLICIT | STRONG MATCH / PARTIAL MATCH / INFERRED / GAP | "…" (from resume) or MISSING | … |

Match level definitions:
- **STRONG MATCH** — concrete resume evidence + quantified outcome or clear ownership.
- **PARTIAL MATCH** — related experience but incomplete (shorter scope, adjacent tool, smaller scale).
- **INFERRED** — reasonable inference from context, but not directly stated. Flag for verification in a screen.
- **GAP** — not found on the resume.

Distinguish *exposure* (saw it, was adjacent to it) from *ownership* (drove it, accountable for outcomes). Only ownership counts as STRONG MATCH.

## Step 2 — Flag analysis

List, separately:
- **Yellow flags** — note but do not eliminate (e.g., short tenure, title ambiguity, missing metric in one role).
- **Red flags** — patterns that significantly reduce confidence without a good explanation (e.g., 3+ jobs in 2 years with no progression narrative, vague senior-level achievements with no outcomes, claimed skills with no supporting experience).
- **Hidden strengths** — strong resume evidence not asked for by the JD that could be a differentiator.

## Step 3 — Decision tree verdict

Walk the decision tree explicitly. Show which branch was taken at each step.

1. **Step 1 — MUST-HAVE gate:** Are there any MUST-HAVE items at GAP?
   - 0 GAPs → continue to Step 2.
   - 1 GAP with a transferable basis → continue to Step 2 (flag transfer risk).
   - 1 hard-threshold GAP (credential, license, work authorization, location) OR 2+ MUST-HAVE GAPs → **WEAK FIT**. Stop.
2. **Step 2 — Coverage quality:** How well are MUST-HAVEs and NICE-TO-HAVEs covered?
   - All MUST-HAVEs STRONG MATCH + good NICE-TO-HAVE coverage → **STRONG FIT**.
   - All MUST-HAVEs met (some PARTIAL) + some NICE-TO-HAVE gaps → **QUALIFIED FIT**.
   - 1 MUST-HAVE GAP with transferable basis, or core technical stack PARTIAL → **STRETCH FIT**.
3. **Step 3 — Risk accumulation:** Do red flags or repeated INFERRED items downgrade the verdict by one tier? Apply judgment.
4. **Step 4 — Final verdict:** STRONG FIT / QUALIFIED FIT / STRETCH FIT / WEAK FIT, with a one-sentence rationale and a confidence level (High / Medium / Low).

## Step 4 — Output

Produce, in this order:

1. **Executive Summary** — final verdict, decision-tree path taken (one line per step), top 3 strengths, top 3 gaps, confidence level.
2. **Match Chart** (Step 1 table).
3. **Flag Analysis** (Step 2).
4. **Scored Fit Score (1–10)** — broken down as: MUST-HAVE fit (0–4) + relevant experience (0–3) + measurable achievements (0–2) + nice-to-have fit (0–1). Show the math. This is a *secondary* signal only; the verdict from Step 3 is primary.
5. **Recommended Next Step** — one of: `Direct interview`, `Phone screen with gap probes`, `Technical screen first`, `Talent pool / revisit later`, `Pass`.
6. **5 Follow-Up Interview Questions** — each probing a specific gap or INFERRED item from the match chart, with a one-line note on what a strong answer would sound like.
7. **Resume Tailoring Recommendations** — 3–5 concrete suggestions for how the candidate could rewrite/reorder resume bullets to better surface evidence for this specific role. Ground each suggestion in a specific rubric row that is currently PARTIAL, INFERRED, or MISSING but which the full resume has plausible material to support.

## Guardrails

- **Do not modify the rubric.** If you think a rubric row is wrong, note it under Flag Analysis as a "rubric concern" but score against the rubric as given.
- Use only evidence explicitly present in the resume. If it is not there, write `MISSING`. Do not infer experience that is not stated.
- Ignore protected characteristics: name, age, gender, race, ethnicity, disability, religion, nationality, family status, school prestige. Do not let school name or employer brand inflate a match.
- Be honest about gaps. Do not be generous. A polite but weak fit is still a weak fit.
- Cite the specific resume section or quote for every non-missing match.

## Save output

Derive the company folder name from the JD: kebab-case of the hiring organization (e.g., "Acme Corp" → `acme-corp`, "OpenAI" → `openai`). If the JD does not name the organization, use `unknown-org-<short-role-slug>`.

Save the full output (Executive Summary, Match Chart, Flag Analysis, Fit Score, Recommended Next Step, Interview Questions, Resume Tailoring Recommendations) to:

`applications/<company-name-kebab>/03-fit-assessment.md`

Create the folder if it does not exist.

**Chat reply:** brief summary only (verdict, recommended next step, path to the saved file). Do **not** paste the full report into chat — write it to the file. Long streamed chat replies frequently disconnect mid-response.
