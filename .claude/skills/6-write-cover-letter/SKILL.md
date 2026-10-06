---
name: 6-write-cover-letter
description: Runs Step 6 cover letter. Briefly interviews the user, then writes 06-cover-letter.md under applications/. Use when the user invokes /6-write-cover-letter or asks for a cover letter / Step 6.
disable-model-invocation: true
---

# /6-write-cover-letter

User invokes this workflow with **`/6-write-cover-letter`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 6 - Write Cover Letter.md`** and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| Application folder or company kebab name | Yes | List `applications/*` and ask. |
| `applications/<company>/job-description.md` | Yes | Tell user which file is missing; suggest `/1-ats-keywords` or ask them to paste the JD. |
| `applications/<company>/03-fit-assessment.md` | No | Proceed without it; rely on the resume and the interview. |
| `inputs/resume_full.html` | Yes | Tell the user to run `/0-setup-resume` first and stop. |
| `inputs/profile.md` | Yes | Tell the user to run `/0-setup-resume` first and stop. |
| Job posting URL | No | Ask during the interview; omit the link only if the user has none. |

## Checklist

```
- [ ] Resolve project root and application folder
- [ ] Load job-description.md, inputs/resume_full.html, inputs/profile.md, and 03-fit-assessment.md if present
- [ ] Read Step 6 prompt
- [ ] Interview the user (short, only what the files can't answer) and WAIT for answers
- [ ] Write applications/<company-name-kebab>/06-cover-letter.md
- [ ] Show the letter in chat
```

## Chat reply

Interview turn: only the questions. Final turn: the full cover letter (it is short), then the saved file path.
