# Architecture

How the claude-cortex works and why it is designed this way.

## Design Principles

### 1. Files Over Databases
Memory is stored as plain Markdown files. No database, no server, no API keys. This means:
- Zero setup friction (just copy files)
- Version control friendly (Git tracks every change)
- Portable across any device or platform
- Readable and editable by humans without special tools
- Survives tool changes (Markdown will outlast any specific software)

### 2. Index Plus Topics
The system uses a two-level hierarchy:
- **`MEMORY.md`** is a concise index (max 200 lines) that points to topic files
- **Topic files** contain the detailed knowledge for a specific area

This separation exists because Claude's context window is finite. Loading a single massive file wastes context on irrelevant information. With the index approach, Claude reads the index first, then loads only the files relevant to the current task.

### 3. Convention Over Configuration
File naming conventions encode the type of knowledge:
- `project-*.md` for project knowledge
- `integration-*.md` for external service docs
- `incident-*.md` for bug fix runbooks
- `reference-*.md` for research and discoveries
- `feedback-*.md` for preferences and patterns

This makes it possible to write scripts that understand the memory structure (validation, statistics) without any configuration file.

### 4. Append-Friendly
The activity log is designed for append-only updates. New entries go at the top. Old entries stay. This makes updates fast and conflict-free, which matters for multi-device sync.

## Data Flow

### Session Start
```
1. Claude reads .claude/CLAUDE.md
   (Contains instructions to use the memory system)

2. Claude reads .claude/memory/MEMORY.md
   (Loads the master index, now aware of all available knowledge)

3. Based on the user's first message, Claude identifies relevant topic files

4. Claude reads those specific topic files
   (Now has full context for the task at hand)
```

### During Session
```
5. User and Claude work on tasks

6. If new knowledge is generated (patterns, fixes, decisions):
   - Claude notes what needs to be recorded
   - Updates happen at session end (not mid-task, to avoid interrupting flow)
```

### Session End
```
7. Claude updates .claude/memory/activity-log.md
   - What was done
   - Decisions made and why
   - What should happen next session
   - Any blockers

8. Claude updates relevant topic files
   - New patterns added to project files
   - New incidents documented in runbook files
   - New integrations documented in integration files

9. If a new topic file was created, Claude adds it to MEMORY.md index
```

## File Size Guidelines

| File | Recommended Max | Reason |
|---|---|---|
| MEMORY.md | 200 lines | Loaded every session; must be fast to parse |
| Activity log | 500 lines | Only recent entries are relevant; archive old ones |
| Project files | 300 lines | Split large projects into sub-files |
| Integration docs | 200 lines | One file per service keeps things focused |
| Incident runbooks | 150 lines | Short and actionable |
| Reference notes | 200 lines | Summary + key takeaways, not full reproduction |

When a file exceeds these limits, split it. For example, a large project file might split into `project-frontend.md` and `project-backend.md`.

## Multi-Device Sync

Memory files sync using whatever file-sync mechanism you already use:

### Dropbox / iCloud / Google Drive
The `scripts\sync.ps1` script copies memory files to a sync folder. Changes propagate automatically through the cloud service. The script uses robocopy for efficient incremental sync.

### Git
Memory files can live inside your project's Git repo (in `.claude/memory/`). They sync when you push and pull. This is the simplest approach if your project already uses Git.

### Dedicated Memory Repo
For cross-project memory (patterns that apply everywhere), create a separate Git repository for memory files. Each project's MEMORY.md can reference the shared repo.

## Conflict Resolution

File sync can cause conflicts when the same file is edited on two devices. The memory system is designed to minimize this:

- **Activity log:** Append-only with timestamps. Conflicts are rare and easy to merge (keep both entries).
- **Project files:** Typically edited on one device at a time. If conflicts occur, the most recent version is usually correct.
- **MEMORY.md:** Changes are infrequent (only when adding new topic files). Merge both additions.

For Git-based sync, standard merge conflict resolution applies. For cloud sync (Dropbox/iCloud), the service handles versioning and conflict files.

## Security Considerations

Memory files may contain project-specific knowledge. Consider:

- **`.gitignore`:** If memory files contain sensitive information, add `.claude/memory/` to `.gitignore` and sync them separately.
- **No secrets in memory:** Never store API keys, passwords, or tokens in memory files. Reference environment variable names instead.
- **Shared repos:** If the memory repo is shared with a team, ensure all members are comfortable with the knowledge being stored.

## Scaling

The system is designed for individual developers or small teams managing 1-10 projects with 5-50 memory files total. At this scale:

- File I/O is instantaneous
- Claude can read the full index plus 2-3 topic files within a reasonable context budget
- Validation and statistics scripts run in under a second

For larger scales (many projects, hundreds of files), consider:
- Organizing memory files into subdirectories per project
- Using the search capabilities of your text editor or IDE
- Building a simple search script that greps across memory files
