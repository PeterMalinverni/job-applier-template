# job-applier

Resume / job-application pipeline run through Claude Code skills. Project root = this directory.

## Pipeline steps

| Step | Skill | Prompt | Output |
|------|-------|--------|--------|
| 0 | `/0-setup-resume` | `prompts/Step 0 - Build Source Resume.md` | `inputs/resume_full.html`, `inputs/profile.md` |
| 1 | `/1-ats-keywords` | `prompts/Step 1 - ATS keyword Extraction.md` | `applications/<company>/01-ats-keywords.md` |
| 2 | `/2-rubric` | `prompts/Step 2 - Assess Job Fit.md` | `applications/<company>/02-rubric.md` |
| 3 | `/3-fit-assessment` | `prompts/Step 3 - Score Resume Against Rubric.md` | `applications/<company>/03-fit-assessment.md` |
| 4 | `/4-optimize-resume` | `prompts/Step 4 - Optimize Resume.md` | tailored HTML + `04-tailoring-report.md` |
| 5 | `/5-track-and-fix-resume-failures` | `prompts/Step 5 - Track and Fix Resume Failures.md` | revised HTML + failure log entry |
| 6 | `/6-write-cover-letter` | `prompts/Step 6 - Write Cover Letter.md` | `06-cover-letter.md` |

Path conventions: `.claude/skills/common/reference.md`.

## Rules

- `inputs/resume_full.html` is the only source of claims about the candidate. Never add facts that aren't in it.
- Step 2: never read any path containing `resume`.
- Read each input file at most once. Do not echo large file contents into chat.
- Write the required output file, then give a brief summary.
- Personal data (`inputs/`, `applications/`, the failure log) is gitignored. Don't commit it.
