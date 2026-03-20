# Claude Memory System - Initialize memory for a project
# Usage: init.ps1 <project-name> [target-directory]

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$REPO_DIR = Split-Path -Parent $SCRIPT_DIR

# Colors
$GREEN = "$([char]27)[0;32m"
$RED = "$([char]27)[0;31m"
$BLUE = "$([char]27)[0;34m"
$BOLD = "$([char]27)[1m"
$RESET = "$([char]27)[0m"

function Show-Usage {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Host "Usage: .\$scriptName <project-name> [target-directory]"
    Write-Host ""
    Write-Host "Initialize Claude Memory System for a project."
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  project-name       Name of your project (used in file names)"
    Write-Host "  target-directory   Directory to initialize (default: current directory)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\$scriptName my-saas-app"
    Write-Host "  .\$scriptName mobile-app C:\path\to\project"
}

if ($args.Count -gt 0 -and ($args[0] -eq "-h" -or $args[0] -eq "--help")) {
    Show-Usage
    exit 0
}

if ($args.Count -lt 1) {
    Write-Host "${RED}Error: Project name is required.${RESET}"
    Write-Host ""
    Show-Usage
    exit 1
}

$PROJECT_NAME = $args[0]
$TARGET_DIR_INPUT = if ($args.Count -ge 2) { $args[1] } else { "." }

# Resolve to absolute path
if (!(Test-Path $TARGET_DIR_INPUT)) {
    Write-Host "${RED}Error: Directory '$TARGET_DIR_INPUT' does not exist.${RESET}"
    exit 1
}
$TARGET_DIR = (Get-Item $TARGET_DIR_INPUT).FullName

$MEMORY_DIR = Join-Path $TARGET_DIR ".claude\memory"

if (Test-Path $MEMORY_DIR) {
    Write-Host "${RED}Error: Memory directory already exists at $MEMORY_DIR${RESET}"
    Write-Host "Use the existing memory system or remove the directory first."
    exit 1
}

Write-Host "${BOLD}Initializing Claude Memory System${RESET}"
Write-Host "  Project: ${BLUE}$PROJECT_NAME${RESET}"
Write-Host "  Target:  ${BLUE}$TARGET_DIR${RESET}"
Write-Host ""

# Check that templates exist
$TEMPLATES_DIR = Join-Path $REPO_DIR "templates"
if (!(Test-Path $TEMPLATES_DIR)) {
    Write-Host "${RED}Error: Templates directory not found at $TEMPLATES_DIR${RESET}"
    Write-Host "Make sure you're running this script from the claude-cortex repository."
    exit 1
}

# Create directory
New-Item -ItemType Directory -Path $MEMORY_DIR -Force | Out-Null

# Copy and customize MEMORY.md
$MEMORY_TEMPLATE_PATH = Join-Path $TEMPLATES_DIR "MEMORY.md"
$MEMORY_CONTENT = Get-Content $MEMORY_TEMPLATE_PATH -Raw
$MEMORY_CONTENT = $MEMORY_CONTENT -replace "\[PROJECT_NAME\]", $PROJECT_NAME
Set-Content (Join-Path $MEMORY_DIR "MEMORY.md") $MEMORY_CONTENT

# Copy templates
Copy-Item (Join-Path $TEMPLATES_DIR "activity-log.md") (Join-Path $MEMORY_DIR "activity-log.md")
Copy-Item (Join-Path $TEMPLATES_DIR "feedback-template.md") (Join-Path $MEMORY_DIR "feedback-preferences.md")

# Create project file from template
$PROJECT_TEMPLATE_PATH = Join-Path $TEMPLATES_DIR "project-template.md"
$PROJECT_CONTENT = Get-Content $PROJECT_TEMPLATE_PATH -Raw
$PROJECT_CONTENT = $PROJECT_CONTENT -replace "\[PROJECT_NAME\]", $PROJECT_NAME
Set-Content (Join-Path $MEMORY_DIR "project-$PROJECT_NAME.md") $PROJECT_CONTENT

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
    Write-Host "  ${GREEN}+${RESET} .claude/CLAUDE.md"
}

Write-Host "  ${GREEN}+${RESET} .claude/memory/MEMORY.md"
Write-Host "  ${GREEN}+${RESET} .claude/memory/activity-log.md"
Write-Host "  ${GREEN}+${RESET} .claude/memory/project-$PROJECT_NAME.md"
Write-Host "  ${GREEN}+${RESET} .claude/memory/feedback-preferences.md"
Write-Host ""
Write-Host "${GREEN}${BOLD}Done.${RESET} Memory system initialized for '$PROJECT_NAME'."
Write-Host ""
Write-Host "Add more memory files as needed using templates from:"
Write-Host "  $TEMPLATES_DIR"
