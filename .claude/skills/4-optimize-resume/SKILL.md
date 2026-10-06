---
name: 4-optimize-resume
description: Runs Step 4 resume optimization based on the fit assessment. Saves 04-tailoring-report.md and the tailored resume under applications/. Use when the user invokes /4-optimize-resume or asks for resume optimization / Step 4.
disable-model-invocation: true
---

# /4-optimize-resume

User invokes this workflow with **`/4-optimize-resume`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 4 - Optimize Resume.md`** under project root and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| Application folder or company kebab name | Yes | List `applications/*` and ask. |
| `applications/<company>/job-description.md` | Yes | Name missing files; suggest the matching `/1-` … `/4-` skill or provide paths. |
| `applications/<company>/01-ats-keywords.md` | Yes | Same. |
| `applications/<company>/03-fit-assessment.md` | Yes | Same. |
| `inputs/resume_full.html` + `inputs/resume_full.css` | Yes | Tell the user to run `/0-setup-resume` first and stop. |
| `inputs/profile.md` | Yes | Tell the user to run `/0-setup-resume` first and stop. |
| `resume-creation-failure-feedback.md` at project root | No | If missing or empty, proceed and say so in the "Avoided prior failures" section. |

## Checklist

```
- [ ] Resolve project root and application folder
- [ ] Read resume-creation-failure-feedback.md end-to-end BEFORE drafting
- [ ] Load JD, keywords, fit assessment, source HTML/CSS, inputs/profile.md
- [ ] Read Step 4 prompt
- [ ] Write applications/<company>/<file_prefix>-Resume-<role>-at-<company>.html
- [ ] Copy or inline CSS so HTML is standalone
- [ ] Write applications/<company>/04-tailoring-report.md, including the "Avoided prior failures" and "Pre-flight self-review" sections
- [ ] Run the Pre-flight self-review against the output file; if any check fails, revise and re-run before finalizing
- [ ] Brief summary in chat
```

## Chat reply

- Paths to the tailored resume HTML and `04-tailoring-report.md`.
- Bullet count per Experience role.
- Em-dash count in tailored resume vs. source.
- Banned-phrase scan result (must be empty).
- One-line fabrication check from the report.

Full report only if asked.
