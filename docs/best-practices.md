# Best Practices

Tips for getting the most out of the claude-cortex.

## Starting Out

### Start with the activity log
The single most impactful habit is updating the activity log at the end of every session. Even if you do nothing else, this alone gives Claude enough context to pick up where you left off.

### Don't over-document upfront
Start with `MEMORY.md`, `activity-log.md`, and one project file. Add more files as the need arises naturally. A lean memory that gets updated is better than a comprehensive one that goes stale.

### Write for your future self
Memory files are read by Claude, but they should also make sense to you. Write in clear, direct language. If a future you would need more context to understand an entry, add it now.

## Writing Effective Memory

### MEMORY.md: Keep it lean
The index should be scannable in seconds. Each entry should be one line with a brief description. If you find yourself writing paragraphs in MEMORY.md, that content belongs in a topic file.

Good:
```markdown
- [project-api.md](project-api.md) -- Backend API routes, auth, background jobs
```

Bad:
```markdown
- [project-api.md](project-api.md) -- This file contains documentation about our
  backend API including all the route handlers for authentication, user management,
  project CRUD operations, and the background job processing system that handles
  email sending and file processing...
```

### Activity log: Be specific about "next"
The "Next" section of each session entry is what Claude reads first in the following session. Make it actionable.

Good:
```markdown
**Next:**
- Add pagination to the /api/tasks endpoint (currently returns all tasks)
- Fix the date picker timezone bug (dates off by one day in UTC-negative timezones)
```

Bad:
```markdown
**Next:**
- Continue working on the API
- Fix bugs
```

### Decisions: Record the "why"
Code shows what was done. Memory should record why it was done that way.

Good:
```markdown
**Decisions:**
- Chose cookie-based auth over JWT because the app uses SSR and cookies
  work transparently with server-side rendering. JWT would require
  additional client-side logic to attach tokens to SSR requests.
```

Bad:
```markdown
**Decisions:**
- Using cookies for auth
```

### Incidents: Include the exact error
When documenting a bug fix, include the exact error message. This makes the runbook searchable and immediately recognizable when the same error appears again.

Good:
```markdown
## Symptoms
Error in server logs:
    PrismaClientKnownRequestError: Unique constraint failed on the fields: (`email`)
    at Object.fn (/app/node_modules/@prisma/client/runtime/library.js:...)
```

Bad:
```markdown
## Symptoms
Database error when creating users with duplicate emails.
```

## Maintenance

### Review monthly
Set a monthly reminder to review your memory files. Look for:
- Stale entries that no longer apply (remove or archive them)
- Missing context that you've been re-explaining to Claude
- Patterns that have emerged but aren't documented yet

### Archive, don't delete
When information becomes outdated, move it to an "Archive" section at the bottom of the file rather than deleting it. Old decisions and patterns can still provide useful context.

### Run validation weekly
Use `scripts/validate.sh` (or `scripts/validate.ps1` on Windows) to catch structural issues before they become problems. Common issues:
- Files linked in MEMORY.md that were renamed or deleted
- Files in the directory that aren't referenced in the index
- Files that have grown too large and should be split

## Team Usage

### Shared memory
For team projects, memory files can live in the project's Git repo. This way, knowledge is shared with the whole team and code-reviewed like any other change.

### Personal vs. project memory
Keep personal preferences (code style, commit conventions) in your global memory. Keep project-specific knowledge (architecture, patterns, incidents) in the project's memory.

Global memory location: `~/.claude/memory/`
Project memory location: `<project>/.claude/memory/`

### Code review memory changes
When memory files are in a shared repo, review them in pull requests. This catches:
- Incorrect information before it becomes "truth"
- Sensitive information that shouldn't be committed
- Overly verbose entries that should be condensed

## Common Pitfalls

### Pitfall: Memory as a TODO list
Memory files document knowledge, not tasks. Use your project's issue tracker for TODO items. The activity log's "Next" section is the exception: it bridges between sessions, not a backlog.

### Pitfall: Duplicating code in memory
Don't paste large code blocks into memory files. Instead, reference the file path and describe the pattern. Code changes; memory should describe the intent and approach, not the implementation.

### Pitfall: Never updating
Memory only works if it stays current. If you find yourself ignoring memory files, simplify. Cut back to just the activity log and one project file. A small, maintained memory beats a large, stale one.

### Pitfall: Over-categorizing
Don't create a file for every small piece of information. If a note is only a few lines, it probably belongs as a section in an existing file rather than its own file.
