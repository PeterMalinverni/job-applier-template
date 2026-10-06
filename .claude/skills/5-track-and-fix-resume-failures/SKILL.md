---
name: 5-track-and-fix-resume-failures
description: Runs Step 5 to track resume rejections and iterate fixes across applications. Use when the user invokes /5-track-and-fix-resume-failures or asks to track/fix resume failures / Step 5.
disable-model-invocation: true
---

# /5-track-and-fix-resume-failures

User invokes this workflow with **`/5-track-and-fix-resume-failures`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 5 - Track and Fix Resume Failures.md`** and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| User feedback on the tailored resume | Yes | Ask the user to paste their critique. Stop until you have it. |
| Application folder or company kebab name | Yes | List `applications/*` and ask. |
| `applications/<company>/<file_prefix>-Resume-<role>-at-<company>.html` | Yes | Tell user which file is missing; suggest running `/4-optimize-resume` first. |
| `applications/<company>/04-tailoring-report.md` | Yes | Same. |
| `applications/<company>/job-description.md` | Yes | Same. |
| `applications/<company>/01-ats-keywords.md` | Yes | Same. |
| `applications/<company>/03-fit-assessment.md` | Yes | Same. |
| `inputs/resume_full.html` | Yes | Tell the user to run `/0-setup-resume` first and stop. |
| `resume-creation-failure-feedback.md` at project root | Yes | If missing, create it with the header from `templates/resume-creation-failure-feedback.md`, then continue. |

## Checklist

```
- [ ] Resolve project root and application folder
- [ ] Collect user's feedback (verbatim)
- [ ] Load tailored resume HTML, tailoring report, JD, keywords, fit assessment, source HTML
- [ ] Read resume-creation-failure-feedback.md (header + all prior entries) to match format and continue numbering
- [ ] Read Step 5 prompt
- [ ] Append new dated section to resume-creation-failure-feedback.md with one numbered entry per distinct failure
- [ ] Rewrite applications/<company>/<file_prefix>-Resume-<role>-at-<company>.html so every logged failure is addressed
- [ ] Run the Step 4 Pre-flight self-review against the revised file; revise until every check passes
- [ ] Rewrite applications/<company>/04-tailoring-report.md with an updated Pre-flight self-review and a new "Revisions from prior draft (feedback loop)" section
- [ ] Brief summary in chat
```

## Hard rules

- Every claim in the revised resume must trace to `inputs/resume_full.html`. When in doubt, cut.
- Do not reword a fabrication into a fresh fabrication. Cut it or reground it in verifiable source material.
- If a section drops below 3 bullets and no honest third bullet exists in the source, cut the role entirely rather than padding.
- Do not restructure sections or change CSS. Content edits only.
- All Step 4 constraints still bind (see `prompts/Step 4 - Optimize Resume.md`).

## Chat reply

- Numbered list of failures logged (one line each).
- Fix applied for each (one line each).
- Final bullet count per Experience role.
- Em-dash count in revised resume vs. source.
- Banned-phrase scan result (must be empty).
- One-line fabrication check.
- Paths to the three updated files.
