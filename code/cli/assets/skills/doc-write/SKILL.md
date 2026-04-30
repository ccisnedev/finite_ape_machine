---
name: doc-write
description: 'Protocol for writing investigation material. Use when: documenting findings, recording confirmed hypotheses, writing analysis documents. The CLI creates file templates with pre-filled frontmatter — the AI fills content sections and maintains the index.'
---

# doc-write — Investigation Documentation Writing Protocol

## When to Use

- When recording confirmed findings during analysis
- When documenting research, evidence, or investigation results
- When creating additional topic-specific documents
- After any write operation (to update the index)

## Reading the inquiry-context Block

At the end of your prompt, the CLI injects a fenced YAML block:

```yaml
# --- inquiry-context ---
output_dir: cleanrooms/<branch>/analyze/
index_file: cleanrooms/<branch>/analyze/index.md
confirmed_doc: cleanrooms/<branch>/analyze/confirmed.md
```

- `output_dir` — where ALL your documents go
- `index_file` — the index you MUST update after every write
- `confirmed_doc` — the mandatory living document for confirmed findings

## How It Works

The CLI creates file templates with pre-filled YAML frontmatter. Your job:

1. **Fill content sections** — write below the frontmatter
2. **Never modify frontmatter** — the CLI sets id, title, date, status, tags, author
3. **Update the index** — after every write (see Index Update Procedure below)

## Creating New Documents

When you need a new document beyond `confirmed.md`:

1. Create the file in `output_dir` with this frontmatter:

```yaml
---
id: <slug>                           # Matches filename (without .md)
title: <descriptive title>           # One sentence
date: <YYYY-MM-DD>                   # Today's date
status: active                       # Start as active
tags: [tag1, tag2]                   # Lowercase, hyphenated
author: <your-ape-name>              # e.g., socrates
---
```

2. Use a descriptive filename: `root-cause-analysis.md`, not `doc1.md`
3. One topic per document — if covering two themes, split into two files
4. No empty sections — write "To be determined" if content is pending

## Index Update Procedure

After EVERY file create or modify, update `index_file`:

### Format

Add or update a row in the documents table:

```markdown
| # | File | Title | Status | Tags |
|---|------|-------|--------|------|
| 1 | confirmed.md | Confirmed findings | active | findings, confirmed |
| 2 | <new-file>.md | <title> | <status> | <tags> |
```

### Rules

1. Every document in `output_dir` MUST have a row in the index
2. Index rows MUST match the frontmatter of the file they reference
3. Update the index **immediately** after writing — never defer
4. Increment the row number sequentially
4. If the index doesn't exist, create it with a descriptive H1 and the table

## Checklist

Before completing any write operation, verify:

```
□ Frontmatter YAML present and valid
□ All required fields populated
□ ID is unique (checked against index)
□ Document covers a single topic
□ No empty sections
□ index.md updated with new/modified entry
```
