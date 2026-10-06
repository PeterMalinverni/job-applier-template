# Resume creation failure feedback

A running log of mistakes found in tailored resumes. `/5-track-and-fix-resume-failures` appends to it; `/4-optimize-resume` reads all of it before every draft so the same mistake is less likely next time.

## How to read this file

Entries are grouped in dated sections, one section per feedback session. Each entry is numbered; numbering is global across the whole file and never restarts.

```
## <YYYY-MM-DD> — <company-folder> (<role>)

### <n>. <short name of the failure>

- **Failure:** "<the offending resume text, quoted verbatim>"
- **Context:** <what inputs/resume_full.html actually supports (or doesn't), and which rule from the Step 4 prompt, the user's feedback, or a prior entry the output violated. For repeats, cite the prior entry, e.g. "same pattern as #4 on acme-corp".>
- **Category:** <comma-separated tags>
```

Category tags (reuse these; add a new one only when none fit): `fabrication`, `misattribution`, `metric-swap`, `ordering`, `keyword-stuffing`, `prompt-rule-violation`, `bullet-count`, `internal-jargon`, `conflation`, `implementation-detail-noise`, `rubric-gap-overreach`, `seniority-inflation`, `analogy-smuggling`, `repeat-failure`, `role-under-development`.

## Entries

_No entries yet._
