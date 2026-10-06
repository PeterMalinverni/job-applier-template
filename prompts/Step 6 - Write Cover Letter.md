# Step 6 - Write Cover Letter

Write a short, direct cover letter for one application. Interview the candidate first, then write.

## 1. Read before asking

Read the job description, the candidate's full resume (`inputs/resume_full.html`), the candidate profile (`inputs/profile.md`), and the fit assessment if one exists. Pull out what you can already answer: company name, role title, hiring manager name (if the JD names one), the candidate's strongest matching experience, and any project or portfolio links in the resume.

Do not ask the candidate anything you can already answer from these files.

## 2. Interview

Ask the candidate a short set of questions, then stop and wait for their answers. Ask at most 5, in one message, numbered. Cover only what the files cannot tell you:

1. **Job link:** URL of the posting (skip if already in `job-description.md`).
2. **Hiring manager:** name, if known. Otherwise the letter uses "Hiring Manager".
3. **Why this job:** what about this company, product, or problem actually interests them? Offer 2-3 guesses drawn from the JD as starting points they can accept, edit, or reject.
4. **Why qualified:** which 1-2 experiences or projects they want front and center. Propose candidates from the resume / fit assessment.
5. **Links:** any project, repo, demo, or writing URLs worth linking (propose ones found in the resume).

Tell the candidate they can answer in fragments, and that "your call" is a valid answer for any question.

Do not write the letter until they have answered.

## 3. Write

Use exactly this structure. Plain text / Markdown, no headers, no bullets.

```
<date>

<company>

Hiring Manager: <name, or "Hiring Manager" if unknown>

I'm applying for your <role> role. <link to the posting, if any>

<Why I want the job: a short, convincing statement tying the candidate's real interests to this company and role.>

<Why I'm qualified: a short, convincing statement of relevant background. Link to relevant work where possible.>

I look forward to speaking.

Sincerely,
<cover_letter_signoff from inputs/profile.md>
```

Rules:

- Date is today's date, written out (e.g. `September 20, 2026`).
- The two body paragraphs are each 2-4 sentences. The whole letter fits on one page with room to spare.
- Be specific: name the company's product or problem, and name the candidate's actual projects, employers, and outcomes.
- Use only facts from the resume or the interview answers. Never invent experience, metrics, links, or interest in the company. If a fact is missing, ask or leave it out.
- Match the candidate's voice from their answers: plain, first person, no filler. Avoid "I am excited to", "passionate", "dynamic", "leverage", "synergy", and other cover-letter boilerplate.
- Avoid em dashes.
- Do not restate the resume line by line. Pick the one or two things that matter most for this role.
- Mirror the JD's own language for the role and domain where it is natural, not stuffed.

## 4. Save and reply

Write the letter to `applications/<company-name-kebab>/06-cover-letter.md`, then show the full letter in chat and give the path. Offer to adjust tone or length.
