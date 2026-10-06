---
name: 3-fit-assessment
description: Runs Step 3 resume vs rubric fit assessment. Saves 03-fit-assessment.md under applications/. Use when the user invokes /3-fit-assessment or asks for fit assessment / Step 3.
disable-model-invocation: true
---

# /3-fit-assessment

User invokes this workflow with **`/3-fit-assessment`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 3 - Score Resume Against Rubric.md`** and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| Application folder or company kebab name | Yes | List `applications/*` and ask. |
| `applications/<company>/job-description.md` | Yes | Tell user which file is missing; suggest `/2-rubric` or paste paths. |
| `applications/<company>/02-rubric.md` | Yes | Same. |
| `inputs/resume_full.html` | Yes | Tell the user to run `/0-setup-resume` first and stop. |
| `inputs/profile.md` | Yes | Tell the user to run `/0-setup-resume` first and stop. |

## Checklist

```
- [ ] Resolve project root and application folder
- [ ] Load job-description.md, 02-rubric.md, inputs/resume_full.html, inputs/profile.md
- [ ] Read Step 3 prompt
- [ ] Write applications/<company-name-kebab>/03-fit-assessment.md
- [ ] Brief summary in chat
```

## Chat reply

Verdict (STRONG / QUALIFIED / STRETCH / WEAK FIT), recommended next step, path to saved file. Full report only if asked — never paste the full report unprompted (long chat streams often disconnect).
