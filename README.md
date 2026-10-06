# job-applier

Tailor your resume to each job description with Claude Code, without letting it make things up.

You give it your resume once. For each job, it:

1. extracts the ATS keywords from the job description,
2. builds a neutral screening rubric from the job description alone,
3. scores your resume against that rubric, honestly,
4. writes a tailored one-page resume (HTML + PDF) that uses the job's wording but only claims what your resume supports,
5. learns from your corrections (an optional feedback loop), and
6. writes a short cover letter after asking you a few questions (optional).

## Requirements

- [Claude Code](https://claude.com/claude-code), installed and logged in (`claude`)
- Google Chrome, Chromium, Brave, or Edge, used for the PDF export
- macOS for the batch scripts. The skills themselves work anywhere Claude Code runs.

## Setup (once)

1. Click **Use this template** on GitHub (or clone the repo), then `cd` into it.
2. Put your resume in `inputs/source/`: a PDF or DOCX, plus any extras you have, such as older resumes, a brag doc, a LinkedIn export or project notes. More material gives a better result.
3. Run `claude`, then type `/0-setup-resume`. It reads your files, asks a few questions about gaps, and writes:
   - `inputs/resume_full.html`, your "full" resume with every role, bullet and metric
   - `inputs/profile.md`, which holds your name, contact details, location, work authorization and cover-letter sign-off
4. **Open `inputs/resume_full.html` in a browser and check it.** Every later step treats it as the truth about you, so fix anything wrong now, either by editing the file or by asking Claude.

Everything in `inputs/` and `applications/` is gitignored, so your data stays local.

## Applying to a job

**Interactive.** In `claude`, run `/1-ats-keywords` and paste the job description. Then run `/2-rubric`, `/3-fit-assessment` and `/4-optimize-resume`. Run `./scripts/to-pdf.sh <company>` for the PDF.

**One command.** Copy the job description, then:

```bash
./scripts/add-job.sh acme-corp          # reads the clipboard (or pass a file / pipe stdin)
./scripts/run-pipeline.sh acme-corp     # steps 1–4 + PDF, each in a fresh Claude session
```

**Many jobs at once:**

```bash
./scripts/add-job.sh acme-corp acme.txt
./scripts/add-job.sh globex globex.txt
./scripts/run-batch.sh acme-corp globex --jobs 2
```

If you hit a Claude usage limit, the scripts wait for the reset and resume where they left off. Run `--help` on any script for its options.

The output goes in `applications/<company>/`:

| File | What it is |
|------|------------|
| `job-description.md` | The job posting |
| `01-ats-keywords.md` | Keywords ranked by priority, plus the top 10 your resume must contain |
| `02-rubric.md` | MUST-HAVE / NICE-TO-HAVE requirements, built without seeing your resume |
| `03-fit-assessment.md` | Verdict (STRONG / QUALIFIED / STRETCH / WEAK FIT), gaps, and likely interview questions |
| `<You>-Resume-<Role>-at-<Company>.html/.pdf` | The tailored resume |
| `04-tailoring-report.md` | What changed and why, keywords used and omitted, and a self-check for fabrication |

## Fixing a bad draft (step 5)

When a tailored resume gets something wrong, such as an inflated claim, a misplaced metric or jargon, run `/5-track-and-fix-resume-failures` and describe the problem in your own words. It fixes the resume and records the failure in `resume-creation-failure-feedback.md`. Step 4 reads that log before every draft, so the same mistake becomes less likely each time.

## Cover letter (step 6)

`/6-write-cover-letter` asks you up to five short questions: why this job, what to highlight, and which links to include. Then it writes a one-page letter in plain language.

## Why the rules are strict

Asked to "tailor a resume", an LLM will happily invent things: metrics moved between projects, "led" where you "contributed", or a technology you never used with "-adjacent" added to it. `prompts/Step 4 - Optimize Resume.md` bans those patterns explicitly, and every tailored resume ships with a pre-flight self-review in its tailoring report. Read the report before you send anything.

## Customizing

- **Look:** edit `inputs/resume_full.css`.
- **Rules:** edit the files in `prompts/`. The skills in `.claude/skills/` only point at them.
- **Models:** `run-pipeline.sh` uses Sonnet for steps 1–3 and Opus for step 4. Override with `--model`.
- **Cursor:** run `mkdir -p .cursor && ln -s ../.claude/skills .cursor/skills` to use the same skills there.
- **Finding jobs:** `search/how-to-find-careers-pages.md` has tips for finding a company's current postings.
