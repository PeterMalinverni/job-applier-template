---
name: 1-ats-keywords
description: Runs Step 1 ATS keyword extraction. Saves job-description.md and 01-ats-keywords.md under applications/. Use when the user invokes /1-ats-keywords or asks for ATS keywords / Step 1.
disable-model-invocation: true
---

# /1-ats-keywords

User invokes this workflow with **`/1-ats-keywords`**.

## Setup

1. Resolve **project root** — see [reference.md](../common/reference.md).
2. Read **`prompts/Step 1 - ATS keyword Extraction.md`** under project root and follow it exactly.

## Inputs

| Input | Required | If missing |
|-------|----------|------------|
| Job description | Yes | Ask user to paste the JD or give a file path. Stop until you have it. |

## Checklist

```
- [ ] Resolve project root
- [ ] Read Step 1 prompt
- [ ] Derive applications/<company-name-kebab>/
- [ ] Write applications/<company-name-kebab>/job-description.md (verbatim JD)
- [ ] Write applications/<company-name-kebab>/01-ats-keywords.md
- [ ] Brief summary in chat (no full table unless asked)
```

## Chat reply

Folder name, job title, keyword count, and full paths to the two saved files.
