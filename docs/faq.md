# Frequently Asked Questions

## General

### Does this work with other AI coding assistants?
The memory system is designed for Claude Code but the concept is universal. Any AI assistant that reads project files can benefit from structured memory. You may need to adjust the instructions in `.claude/CLAUDE.md` to match your tool's configuration mechanism.

### How is this different from just using CLAUDE.md?
`CLAUDE.md` is a single file. It works for small projects but doesn't scale. When you have multiple projects, integrations, incident history, and research notes, a single file either becomes too long (wasting context window) or too sparse (missing critical information). The memory system uses an index that points to topic files, so Claude loads only what's relevant.

### Will this slow down Claude?
Reading a few Markdown files at session start takes negligible time. The index file is kept under 200 lines specifically to avoid loading unnecessary content. Claude reads additional topic files only when they're relevant to the task at hand.

### Can I use this with a team?
Yes. Memory files can live in your project's Git repository and be reviewed in pull requests like any other code. See the "Team Usage" section in [best-practices.md](best-practices.md).

## Setup

### Where should memory files live?
Inside your project at `.claude/memory/`. For cross-project knowledge that applies everywhere, use `~/.claude/memory/` (your home directory).

### How do I add memory to an existing project?
Run `scripts\init.ps1 your-project-name C:\path\to\project`. This creates the `.claude\memory\` directory with templates. Then start filling in the project file and activity log.

### What if I have multiple projects?
Each project gets its own `.claude/memory/` directory. For shared knowledge (patterns that apply everywhere), create a global memory at `~/.claude/memory/` and reference it from each project's MEMORY.md.

### Can I rename the memory directory?
Yes, but you'll need to update the paths in `.claude/CLAUDE.md` and any scripts you use. The default `.claude/memory/` is recommended because it's consistent and already gitignored by many Claude Code configurations.

## Usage

### How often should I update memory?
Update the activity log at the end of every session. Update other files when something changes: new patterns discovered, bugs fixed, integrations modified. Don't update files that haven't changed.

### What goes in the activity log vs. project files?
The activity log captures what happened in each session (temporal). Project files capture how things work (structural). "We migrated to session cookies today" goes in the activity log. "Authentication uses session cookies because of SSR" goes in the project file.

### How do I handle sensitive information?
Never store secrets (API keys, passwords, tokens) in memory files. Instead, reference environment variable names: "Auth token is stored in `AUTH_SERVICE_KEY` environment variable." If your memory files contain project-sensitive information, add `.claude/memory/` to `.gitignore`.

### What if a memory file gets too long?
Split it. A 400-line project file should become `project-frontend.md` and `project-backend.md`. Update the links in MEMORY.md. The validation script warns when files exceed recommended sizes.

### Should Claude update memory automatically?
Instruct Claude (via CLAUDE.md) to update the activity log at the end of every session. For other files, it depends on your preference. Some users prefer Claude to update files automatically; others prefer to review changes before they're written. Specify your preference in the feedback file.

## Sync

### How do I sync across devices?
Use `scripts\sync.ps1` with one of the supported methods: Dropbox, iCloud, Git, or a custom directory. The simplest approach is to keep memory files in a Git repo and push/pull normally.

### What about sync conflicts?
The activity log is append-only with timestamps, so conflicts are rare and easy to resolve (keep both entries). For other files, the most recently modified version is usually correct. See [architecture.md](architecture.md) for detailed conflict resolution guidance.

### Can I sync only memory files (not the whole project)?
Yes. Use `scripts\sync.ps1 directory` to copy memory files to any shared location. Or create a separate Git repo just for memory files and symlink it into each project.

## Maintenance

### How do I know if my memory is healthy?
Run `scripts\validate.ps1 .claude\memory`. It checks for broken links, unreferenced files, oversized files, and stale activity logs.

### When should I archive old entries?
When activity log entries are older than 3 months and no longer provide useful context, move them to an archive file. Similarly, incident runbooks for bugs that have been stable for months can be archived. See the "Seasonal Cleanup" pattern in [patterns.md](patterns.md).

### Can I delete memory files?
Yes, but update MEMORY.md to remove the reference. The validation script will flag any broken links. Consider archiving instead of deleting, in case the information becomes relevant again.

## Troubleshooting

### Claude isn't reading the memory files
Check that `.claude/CLAUDE.md` contains instructions to read the memory system. Claude needs explicit instructions to look for and load memory files at session start.

### Claude is loading too much context
Keep MEMORY.md under 200 lines. If Claude is loading files that aren't relevant, restructure the index so that file descriptions clearly indicate their scope. Claude should be able to determine relevance from the index alone.

### Memory files are out of date
Run validation to identify stale files. Set a calendar reminder for monthly reviews. If keeping memory current feels like a burden, simplify: cut back to just the activity log and one project file.

### The validation script shows errors
Common fixes:
- **Missing linked file:** The file was renamed or deleted. Update the link in MEMORY.md.
- **Unreferenced file:** A new file was created but not added to the index. Add it to MEMORY.md.
- **File too large:** Split the file into smaller topic files and update the index.
- **Stale activity log:** Update it in your next session. Consider setting a reminder.
