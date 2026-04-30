---
name: doc-read
description: 'Protocol for reading investigation material. Use when: consulting existing analysis, looking up previous findings, checking for duplicates. Implements query planner: index scan → filter → partial read → full read. Never scan directories file by file.'
---

# doc-read — Investigation Documentation Reading Protocol

## When to Use

- Before writing new documentation (to avoid duplicates)
- When you need context from previous findings
- When referencing existing analysis documents
- When checking what has already been confirmed

## Reading the inquiry-context Block

At the end of your prompt, the CLI injects a fenced YAML block:

```yaml
# --- inquiry-context ---
output_dir: cleanrooms/<branch>/analyze/
index_file: cleanrooms/<branch>/analyze/index.md
```

- `index_file` — ALWAYS read this first
- `output_dir` — where all investigation documents live

## Protocol

Follow these steps in order. Stop as soon as you have enough information.

### Step 1: Read the Index

Read `index_file` from the inquiry-context block. This is your primary index.

```
ALWAYS read index_file FIRST.
NEVER list or scan a directory file by file.
```

### Step 2: Filter on Index

Use the index table columns (File, Title, Status, Tags) to identify relevant documents. If the index provides enough information, **stop here**.

### Step 3: Partial Read

If you need more detail, read only the frontmatter (first 15 lines) of candidate files to verify relevance before committing to a full read.

### Step 4: Full Read

Only perform a full read of files confirmed as relevant in Steps 2-3.

## Rules

1. **Index first** — Never open individual files without consulting the index
2. **Filter before reading** — Use index metadata to narrow candidates
3. **Partial before full** — Read frontmatter to verify relevance
4. **No full scans** — If the index doesn't help, report that the query returned no results
5. **Minimum reads** — Optimize for fewest file reads that answer the question
