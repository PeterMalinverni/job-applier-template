# Shared paths

## Project root

The repository root: the directory that contains `prompts/`, `inputs/`, and `applications/`. All paths below are relative to it.

## Candidate inputs (created by `/0-setup-resume`)

- `inputs/resume_full.html` — the "full" source resume. The only legal source of claims for every later step.
- `inputs/resume_full.css` — its stylesheet.
- `inputs/profile.md` — name, `file_prefix`, contact, location, work authorization, cover-letter sign-off.
- `inputs/source/` — the user's original resume files (PDF, DOCX, notes). Read only by `/0-setup-resume`.

If `inputs/resume_full.html` or `inputs/profile.md` is missing, tell the user to run `/0-setup-resume` first and stop.

## Application folder layout

```
applications/<company-name-kebab>/
  job-description.md
  01-ats-keywords.md
  02-rubric.md
  03-fit-assessment.md
  <file_prefix>-Resume-<role>-at-<company>.html
  <file_prefix>-Resume-<role>-at-<company>.pdf
  resume_full.css
  04-tailoring-report.md
  06-cover-letter.md
```

## Company folder name

Kebab-case hiring organization from the JD (e.g. `Acme Corp` → `acme-corp`). If the JD has no organization: `unknown-org-<short-role-slug>`.

## Failure log

`resume-creation-failure-feedback.md` at project root. Starts with a header and no entries; `/5-track-and-fix-resume-failures` appends to it.

## Prompt files

| Skill | Prompt |
|-------|--------|
| `/0-setup-resume` | `prompts/Step 0 - Build Source Resume.md` |
| `/1-ats-keywords` | `prompts/Step 1 - ATS keyword Extraction.md` |
| `/2-rubric` | `prompts/Step 2 - Assess Job Fit.md` |
| `/3-fit-assessment` | `prompts/Step 3 - Score Resume Against Rubric.md` |
| `/4-optimize-resume` | `prompts/Step 4 - Optimize Resume.md` |
| `/5-track-and-fix-resume-failures` | `prompts/Step 5 - Track and Fix Resume Failures.md` |
| `/6-write-cover-letter` | `prompts/Step 6 - Write Cover Letter.md` |
