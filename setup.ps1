# Claude Memory System - Setup
# Creates the memory structure in the current directory or a specified project.

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

# Colors
$GREEN = "$([char]27)[0;32m"
$BLUE = "$([char]27)[0;34m"
$YELLOW = "$([char]27)[0;33m"
$BOLD = "$([char]27)[1m"
$RESET = "$([char]27)[0m"

Write-Host "${BOLD}Claude Memory System - Setup${RESET}"

# Ask for project name
$PROJECT_NAME = Read-Host "Project name"
if ([string]::IsNullOrWhiteSpace($PROJECT_NAME)) {
    Write-Error "Project name is required."
    exit 1
}

# Ask for target directory
$TARGET_DIR_INPUT = Read-Host "Target directory [.]"
if ([string]::IsNullOrWhiteSpace($TARGET_DIR_INPUT)) {
    $TARGET_DIR_INPUT = "."
}

# Resolve to absolute path
if (!(Test-Path $TARGET_DIR_INPUT)) {
    Write-Error "Directory '$TARGET_DIR_INPUT' does not exist."
    exit 1
}
$TARGET_DIR = (Get-Item $TARGET_DIR_INPUT).FullName

$MEMORY_DIR = Join-Path $TARGET_DIR ".claude\memory"

Write-Host ""
Write-Host "Setting up memory in: ${BLUE}$MEMORY_DIR${RESET}"
Write-Host ""

# Create directory structure
if (!(Test-Path $MEMORY_DIR)) {
    New-Item -ItemType Directory -Path $MEMORY_DIR -Force | Out-Null
}

# Copy templates
Copy-Item (Join-Path $SCRIPT_DIR "templates\activity-log.md") (Join-Path $MEMORY_DIR "activity-log.md") -Force
Copy-Item (Join-Path $SCRIPT_DIR "templates\project-template.md") (Join-Path $MEMORY_DIR "project-${PROJECT_NAME}.md") -Force
Copy-Item (Join-Path $SCRIPT_DIR "templates\feedback-template.md") (Join-Path $MEMORY_DIR "feedback-preferences.md") -Force

# Generate MEMORY.md from template, substituting project name
$MEMORY_TEMPLATE_PATH = Join-Path $SCRIPT_DIR "templates\MEMORY.md"
$MEMORY_CONTENT = Get-Content $MEMORY_TEMPLATE_PATH -Raw
$MEMORY_CONTENT = $MEMORY_CONTENT -replace "\[PROJECT_NAME\]", $PROJECT_NAME
Set-Content (Join-Path $MEMORY_DIR "MEMORY.md") $MEMORY_CONTENT

# Create CLAUDE.md if it doesn't exist
$CLAUDE_MD = Join-Path $TARGET_DIR ".claude\CLAUDE.md"
if (!(Test-Path $CLAUDE_MD)) {
    $CLAUDE_CONTENT = @"
## Memory System

At the START of every session:
1. Read `.claude/memory/MEMORY.md` to load the master index
2. Load topic files relevant to the current task
3. Check the activity log for recent session context

At the END of every session:
1. Update `.claude/memory/activity-log.md` with: date, work done, decisions made, next steps
2. Update any topic files that changed (new patterns, resolved incidents, etc.)
3. If a new topic file was created, add it to `MEMORY.md` index

Rules:
- Keep `MEMORY.md` under 200 lines (it is an index, not a dump)
- Use relative links between memory files
- Be specific in incident runbooks (include exact error messages)
- Cross-reference between files when relevant
"@
    # Ensure .claude directory exists
    $CLAUDE_DIR = Split-Path -Parent $CLAUDE_MD
    if (!(Test-Path $CLAUDE_DIR)) {
        New-Item -ItemType Directory -Path $CLAUDE_DIR -Force | Out-Null
    }
    Set-Content $CLAUDE_MD $CLAUDE_CONTENT
    Write-Host "  ${GREEN}Created${RESET} .claude/CLAUDE.md"
}

Write-Host "  ${GREEN}Created${RESET} .claude/memory/MEMORY.md"
Write-Host "  ${GREEN}Created${RESET} .claude/memory/activity-log.md"
Write-Host "  ${GREEN}Created${RESET} .claude/memory/project-${PROJECT_NAME}.md"
Write-Host "  ${GREEN}Created${RESET} .claude/memory/feedback-preferences.md"
Write-Host ""
Write-Host "${GREEN}${BOLD}Memory system initialized for '$PROJECT_NAME'.${RESET}"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Open your project in Claude Code"
Write-Host "  2. Claude will read .claude/CLAUDE.md and discover the memory system"
Write-Host "  3. At the end of each session, Claude updates the activity log"
Write-Host ""
Write-Host "Add more memory files as needed:"
Write-Host "  - Integration docs:  cp templates/integration-template.md .claude/memory/integration-<name>.md"
Write-Host "  - Incident runbooks: cp templates/incident-template.md .claude/memory/incident-<name>.md"
Write-Host "  - Research notes:    cp templates/reference-template.md .claude/memory/reference-<name>.md"
