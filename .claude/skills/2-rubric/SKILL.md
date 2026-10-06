---
name: 2-rubric
description: Runs Step 2 resume-blind screening rubric from a job description. Saves 02-rubric.md under applications/. Use when the user invokes /2-rubric or asks for rubric / Step 2.
disable-model-invocation: true
---

# /2-rubric

User invokes this workflow with **`/2-rubric`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 2 - Assess Job Fit.md`** and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| Application folder or company kebab name | Yes | List `applications/*` under project root and ask which one. |
| `applications/<company>/job-description.md` | Yes | Ask for company folder, or JD path; if user supplies JD only, create folder, save `job-description.md`, then continue. |

## Hard rule

Do **not** read any file with `resume` in the path or filename.

## Checklist

```
- [ ] Resolve project root and application folder
- [ ] Load job-description.md only (no resume files)
- [ ] Read Step 2 prompt
- [ ] Write applications/<company-name-kebab>/02-rubric.md
- [ ] Brief summary in chat
```

## Chat reply

Folder name, path to `02-rubric.md`, MUST-HAVE count. Full rubric only if asked.
