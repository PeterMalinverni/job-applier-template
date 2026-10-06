Attached is a job description for a role the candidate is considering applying to.

## Your task

Act as an ATS (Applicant Tracking System) keyword analyst. Extract the keywords and phrases that an ATS parser and a human recruiter are most likely to screen for in an applicant's resume. Prioritize fidelity to the exact wording used in the job description over synonyms or paraphrases — ATS systems typically match on exact strings.

## Extraction rules

1. **Pull only from the job description.** Do not invent skills, tools, or credentials that are not present in the source text.
2. **Preserve exact terminology.** If the JD says "JavaScript," do not output "JS." If it says "Google Cloud Platform," do not shorten to "GCP" unless the JD also uses the acronym.
3. **Include both acronym and expansion when both appear** (e.g., `SEO` and `Search Engine Optimization`). If only one form appears, output only that form.
4. **Multi-word phrases stay intact.** Prefer `conversion rate optimization` over three separate tokens.
5. **Capture repeated terms.** Terms mentioned 2+ times in the JD are almost always core requirements — flag them.
6. **Distinguish required vs. preferred.** Watch for signal phrases: `must have`, `required`, `essential`, `minimum` (required) vs. `preferred`, `nice to have`, `bonus`, `plus` (preferred).
7. **Include years-of-experience specifiers** verbatim (e.g., `5+ years`, `7+ years of digital marketing`).
8. **Include the exact job title** and any seniority modifiers (e.g., `Senior Data Analyst`).

## Output format

Return a single markdown table with the following columns, sorted by Priority (Tier 1 → Tier 3), then by Frequency (descending):

| # | Keyword / Phrase | Category | Priority | Frequency | Required? | Notes |

Where:
- **Category** is one of: `Job Title`, `Hard Skill`, `Tool / Technology`, `Certification`, `Methodology`, `Soft Skill`, `Domain / Industry Term`, `Responsibility / Action Verb`, `Experience Requirement`.
- **Priority** is one of:
  - `Tier 1` — Must-have: exact job title, required technical skills, required certifications, years-of-experience thresholds, tools/skills mentioned 3+ times.
  - `Tier 2` — Important: preferred skills, methodologies, industry-specific terms, related tools, high-signal soft skills.
  - `Tier 3` — Nice-to-have: bonus qualifications, culture/values terms, tools mentioned only once in passing.
- **Frequency** is the integer count of occurrences in the JD.
- **Required?** is `Required`, `Preferred`, or `Implied` (based on the signal phrases in rule 6).
- **Notes** is optional — use for context that helps resume-writing (e.g., `acronym for X`, `paired with 'expertise in'`, `appears in title AND summary`).

## Target count

Aim for **40–60 keywords**. Do not pad with generic filler to hit the number; quality and fidelity matter more than volume. If the JD is short, return fewer.

## After the table

Add a short section titled **"Top 10 Non-Negotiables"** listing the 10 keywords the candidate's resume must contain to pass ATS screening for this role, in priority order.

## Save output

Derive the company folder name from the JD: kebab-case of the hiring organization (e.g., "Acme Corp" → `acme-corp`, "OpenAI" → `openai`). If the JD does not name the organization, use `unknown-org-<short-role-slug>`.

Create `applications/<company-name-kebab>/` if it does not exist.

Save the job description text verbatim to:

`applications/<company-name-kebab>/job-description.md`

Save the full keyword output (table + Top 10 Non-Negotiables) to:

`applications/<company-name-kebab>/01-ats-keywords.md`

At the top of `01-ats-keywords.md`, include a short header with the exact job title and organization name as pulled from the JD.

In chat, give a brief summary only (organization folder path, job title, keyword count, path to saved files). Do not paste the full table unless the user asks.
