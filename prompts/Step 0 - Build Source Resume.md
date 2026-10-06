# Step 0 - Build Source Resume

Turn the candidate's existing resume material into the two files every later step depends on:

- `inputs/resume_full.html` — the "full" source resume. Steps 3–6 treat it as the **only** legal source of claims about the candidate.
- `inputs/profile.md` — identity, logistics, and output-naming details.

## 1. Read the sources

Read every file in `inputs/source/`. Typical contents: a current resume (PDF or DOCX), older resumes, a brag doc, a LinkedIn export, project notes.

- PDF, Markdown, and plain text: read directly.
- DOCX: convert to text first with `textutil -convert txt -stdout <file>` (macOS) or `pandoc -t plain <file>`. If neither is available, ask the user to export a PDF and stop.
- Anything else you cannot read: name the file and ask the user for a PDF or text version.

If `inputs/source/` is empty, ask the user to put their resume there (or paste it in chat) and stop.

## 2. Write `inputs/resume_full.html`

Start from `templates/resume_full.template.html`. Keep its HTML structure and class names exactly; replace all placeholder content. Copy `templates/resume.css` to `inputs/resume_full.css`.

Rules:

- **Full means superset.** Include every role, project, degree, bullet, metric, tool, and skill found in any source. Merge duplicates across sources into one bullet, keeping the most specific wording and every distinct metric. Do not trim for length; the tailoring step selects from this file.
- **No fabrication.** Rewording for clarity is fine. New facts, numbers, scope words ("led", "owned", "sole"), or technologies are not. If two sources conflict (dates, titles, metrics), ask in the interview instead of picking one.
- **Keep metrics attached to the work they describe.** Never move a number from one product, team, or role to another.
- **Reverse-chronological** within Experience, Projects, and Education.
- **One accomplishment per bullet.** Split bullets that weld two unrelated efforts together.
- Use `&ndash;` for date ranges and escape `&` as `&amp;`.

## 3. Write `inputs/profile.md`

Use exactly this format:

```
# Candidate profile

name: <full name as it should appear on the resume>
file_prefix: <First-Last, used in output filenames, e.g. Jane-Doe>
email: <email>
phone: <phone, or blank>
links: <LinkedIn, GitHub, portfolio URLs, comma-separated>
location: <City, ST / Country>
open_to: <remote / hybrid / onsite / relocation preferences>
work_authorization: <e.g. US citizen; needs H-1B sponsorship; EU work permit>
cover_letter_signoff: <name to sign cover letters with>
```

## 4. Interview

Ask the user one short, numbered list of questions (at most 7), then stop and wait. Ask only what the sources leave out or contradict:

- Missing or conflicting dates, titles, or metrics (quote the conflict).
- `location`, `open_to`, and `work_authorization` if not stated.
- Whether to include old, short, or unrelated roles that appear in only one source.
- Any experience they have that is missing from every source. Record only what they actually state.

Tell them they can answer in fragments. After they answer, update both files.

## 5. Finish

1. If `resume-creation-failure-feedback.md` does not exist at the project root, copy `templates/resume-creation-failure-feedback.md` there.
2. Reply in chat with: the number of roles, projects, and degrees captured; the number of Experience bullets; any source content you could not use and why; and the paths to both files.
3. Tell the user to open `inputs/resume_full.html` in a browser and check it carefully, because every later step trusts it. Corrections can be made by editing the file directly or by asking you.
