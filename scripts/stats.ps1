# Claude Memory System - Memory Statistics
# Shows statistics about a memory directory.
# Usage: stats.ps1 <memory-dir>

# Colors
$GREEN = "$([char]27)[0;32m"
$BLUE = "$([char]27)[0;34m"
$YELLOW = "$([char]27)[0;33m"
$BOLD = "$([char]27)[1m"
$DIM = "$([char]27)[2m"
$RESET = "$([char]27)[0m"

function Show-Usage {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Host "Usage: .\$scriptName <memory-dir>"
    Write-Host ""
    Write-Host "Display statistics about a Claude Memory directory."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\$scriptName .claude/memory"
    Write-Host "  .\$scriptName /path/to/project/.claude/memory"
}

if ($args.Count -gt 0 -and ($args[0] -eq "-h" -or $args[0] -eq "--help")) {
    Show-Usage
    exit 0
}

if ($args.Count -lt 1) {
    Write-Host "Error: Memory directory path is required."
    Write-Host ""
    Show-Usage
    exit 1
}

$MEMORY_DIR_INPUT = $args[0]

if (!(Test-Path $MEMORY_DIR_INPUT)) {
    Write-Host "Error: Directory not found: $MEMORY_DIR_INPUT"
    exit 1
}

$MEMORY_DIR = (Get-Item $MEMORY_DIR_INPUT).FullName

Write-Host "${BOLD}Claude Memory System - Statistics${RESET}"
Write-Host "Directory: ${BLUE}$MEMORY_DIR${RESET}"
Write-Host ""

# Count files by type
$TOTAL_FILES = 0
$PROJECT_FILES = 0
$INTEGRATION_FILES = 0
$INCIDENT_FILES = 0
$REFERENCE_FILES = 0
$FEEDBACK_FILES = 0
$OTHER_FILES = 0

$files = Get-ChildItem -Path $MEMORY_DIR -Filter "*.md"
foreach ($file in $files) {
    $TOTAL_FILES++
    $name = $file.Name

    if ($name -like "project-*") { $PROJECT_FILES++ }
    elseif ($name -like "integration-*") { $INTEGRATION_FILES++ }
    elseif ($name -like "incident-*") { $INCIDENT_FILES++ }
    elseif ($name -like "reference-*") { $REFERENCE_FILES++ }
    elseif ($name -like "feedback-*") { $FEEDBACK_FILES++ }
    elseif ($name -eq "MEMORY.md" -or $name -eq "activity-log.md") { } # Don't count in "other"
    else { $OTHER_FILES++ }
}

# Total lines across all files
$TOTAL_LINES = 0
foreach ($file in $files) {
    $TOTAL_LINES += (Get-Content $file.FullName).Count
}

# MEMORY.md line count
$MEMORY_LINES = 0
$MEMORY_FILE = Join-Path $MEMORY_DIR "MEMORY.md"
if (Test-Path $MEMORY_FILE) {
    $MEMORY_LINES = (Get-Content $MEMORY_FILE).Count
}

# Activity log session count
$SESSION_COUNT = 0
$ACTIVITY_LOG = Join-Path $MEMORY_DIR "activity-log.md"
if (Test-Path $ACTIVITY_LOG) {
    $sessions = Select-String -Path $ACTIVITY_LOG -Pattern "^## [0-9]"
    $SESSION_COUNT = $sessions.Count
}

# Largest file
$LARGEST_FILE = ""
$LARGEST_LINES = 0
foreach ($file in $files) {
    $lines = (Get-Content $file.FullName).Count
    if ($lines -gt $LARGEST_LINES) {
        $LARGEST_LINES = $lines
        $LARGEST_FILE = $file.Name
    }
}

# Last modified file
$NEWEST_FILE = Get-ChildItem -Path $MEMORY_DIR -Filter "*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$NEWEST_BASENAME = if ($NEWEST_FILE) { $NEWEST_FILE.Name } else { "" }

# Print stats
Write-Host "${BOLD}Overview${RESET}"
Write-Host "  Total files:       ${GREEN}$TOTAL_FILES${RESET}"
Write-Host "  Total lines:       ${GREEN}$TOTAL_LINES${RESET}"
Write-Host "  Sessions logged:   ${GREEN}$SESSION_COUNT${RESET}"
Write-Host "  MEMORY.md lines:   ${GREEN}$MEMORY_LINES${RESET} / 200"
Write-Host ""

Write-Host "${BOLD}Files by Type${RESET}"
Write-Host ("  {0,-20} {1}" -f "Project files:", $PROJECT_FILES)
Write-Host ("  {0,-20} {1}" -f "Integration docs:", $INTEGRATION_FILES)
Write-Host ("  {0,-20} {1}" -f "Incident runbooks:", $INCIDENT_FILES)
Write-Host ("  {0,-20} {1}" -f "Reference notes:", $REFERENCE_FILES)
Write-Host ("  {0,-20} {1}" -f "Feedback files:", $FEEDBACK_FILES)
Write-Host ("  {0,-20} {1}" -f "Other:", $OTHER_FILES)
Write-Host ""

Write-Host "${BOLD}Details${RESET}"
if ($LARGEST_FILE) {
    Write-Host "  Largest file:      ${BLUE}$LARGEST_FILE${RESET} ($LARGEST_LINES lines)"
}
if ($NEWEST_BASENAME) {
    Write-Host "  Last modified:     ${BLUE}$NEWEST_BASENAME${RESET}"
}
Write-Host ""

# Bar chart of file sizes
Write-Host "${BOLD}File Sizes${RESET}"
foreach ($file in $files) {
    $lines = (Get-Content $file.FullName).Count

    # Create a simple bar (1 block per 10 lines, max 40 blocks)
    $bar_length = [Math]::Floor($lines / 10)
    if ($bar_length -gt 40) { $bar_length = 40 }
    if ($bar_length -lt 1 -and $lines -gt 0) { $bar_length = 1 }

    $bar = "#" * $bar_length
    Write-Host ("  {0,-30} {1,4}  ${GREEN}{2}${RESET}" -f $file.Name, $lines, $bar)
}
