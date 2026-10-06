---
name: 0-setup-resume
description: Runs Step 0 onboarding. Converts the user's resume files in inputs/source/ into inputs/resume_full.html and inputs/profile.md. Use when the user invokes /0-setup-resume or asks to set up / import their resume.
disable-model-invocation: true
---

# /0-setup-resume

User invokes this workflow with **`/0-setup-resume`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 0 - Build Source Resume.md`** and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| Files in `inputs/source/` (PDF, DOCX, MD, TXT) | Yes | Ask the user to add their resume there, or paste it in chat. Stop until you have it. |
| `templates/resume_full.template.html`, `templates/resume.css` | Yes | Tell the user the repo is incomplete and stop. |

## Existing files

If `inputs/resume_full.html` or `inputs/profile.md` already exists, ask before overwriting. Offer to merge new source material into the existing files instead.

## Checklist

```
- [ ] Resolve project root
- [ ] Read Step 0 prompt
- [ ] Read every file in inputs/source/
- [ ] Write inputs/resume_full.html from the template; copy CSS to inputs/resume_full.css
- [ ] Write inputs/profile.md
- [ ] Interview the user about gaps and conflicts, WAIT for answers, then update both files
- [ ] Create resume-creation-failure-feedback.md from the template if absent
- [ ] Brief summary in chat, and ask the user to review the HTML
```

## Chat reply

Interview turn: only the questions. Final turn: counts of roles / projects / degrees / bullets, anything left out and why, both file paths, and a reminder to review `inputs/resume_full.html`.
