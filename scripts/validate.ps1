# Claude Memory System - Validate memory structure
# Checks for structural issues, broken links, and stale entries.
# Usage: validate.ps1 <memory-dir>

# Colors
$GREEN = "$([char]27)[0;32m"
$RED = "$([char]27)[0;31m"
$YELLOW = "$([char]27)[0;33m"
$BLUE = "$([char]27)[0;34m"
$BOLD = "$([char]27)[1m"
$RESET = "$([char]27)[0m"

function Show-Usage {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Host "Usage: .\$scriptName <memory-dir>"
    Write-Host ""
    Write-Host "Validate the structure and health of a Claude Memory directory."
    Write-Host ""
    Write-Host "Checks performed:"
    Write-Host "  - MEMORY.md exists and is under 200 lines"
    Write-Host "  - All linked files exist"
    Write-Host "  - All files in directory are referenced in MEMORY.md"
    Write-Host "  - Activity log has recent entries"
    Write-Host "  - No files exceed recommended size"
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
    Write-Host "${RED}Error: Memory directory path is required.${RESET}" -ForegroundColor Red
    Write-Host ""
    Show-Usage
    exit 1
}

$MEMORY_DIR_INPUT = $args[0]
$ERRORS = 0
$WARNINGS = 0

function Pass-Check($msg) { Write-Host "  ${GREEN}PASS${RESET}  $msg" }
function Fail-Check($msg) { Write-Host "  ${RED}FAIL${RESET}  $msg"; script:ERRORS++ }
function Warn-Check($msg) { Write-Host "  ${YELLOW}WARN${RESET}  $msg"; script:WARNINGS++ }
function Info-Check($msg) { Write-Host "  ${BLUE}INFO${RESET}  $msg" }

if (!(Test-Path $MEMORY_DIR_INPUT)) {
    Write-Host "${RED}FAIL${RESET}  Memory directory does not exist: $MEMORY_DIR_INPUT"
    Write-Host ""
    Write-Host "${RED}${BOLD}Validation failed.${RESET} Directory not found."
    exit 1
}

$MEMORY_DIR = (Get-Item $MEMORY_DIR_INPUT).FullName

Write-Host "${BOLD}Claude Memory System - Validation${RESET}"
Write-Host "Directory: ${BLUE}$MEMORY_DIR${RESET}"
Write-Host ""

# Check 1: Directory exists (already checked above)
Pass-Check "Memory directory exists"

# Check 2: MEMORY.md exists
$MEMORY_FILE = Join-Path $MEMORY_DIR "MEMORY.md"
if (Test-Path $MEMORY_FILE) {
    Pass-Check "MEMORY.md exists"
} else {
    Fail-Check "MEMORY.md not found"
}

# Check 3: MEMORY.md line count
if (Test-Path $MEMORY_FILE) {
    $LINE_COUNT = (Get-Content $MEMORY_FILE).Count
    if ($LINE_COUNT -le 200) {
        Pass-Check "MEMORY.md is $LINE_COUNT lines (max 200)"
    } else {
        Warn-Check "MEMORY.md is $LINE_COUNT lines (recommended max: 200)"
    }
}

# Check 4: Activity log exists
$ACTIVITY_LOG = Join-Path $MEMORY_DIR "activity-log.md"
if (Test-Path $ACTIVITY_LOG) {
    Pass-Check "activity-log.md exists"
} else {
    Warn-Check "activity-log.md not found (recommended for session tracking)"
}

# Check 5: Activity log freshness
if (Test-Path $ACTIVITY_LOG) {
    $lastModified = (Get-Item $ACTIVITY_LOG).LastWriteTime
    $now = Get-Date
    $ageDays = ($now - $lastModified).Days

    if ($ageDays -le 14) {
        Pass-Check "Activity log updated $ageDays days ago"
    } else {
        Warn-Check "Activity log is $ageDays days old (consider updating)"
    }
}

# Check 6: Linked files exist
if (Test-Path $MEMORY_FILE) {
    Write-Host ""
    Write-Host "${BOLD}Checking linked files...${RESET}"

    $content = Get-Content $MEMORY_FILE
    # Simple regex to find [text](filename.md)
    # This is a bit simplified compared to the sed/grep version but should work for most cases
    $matches = [regex]::Matches($content -join "`n", "\]\(([^)]+\.md)\)")
    $linkedFiles = $matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

    if ($linkedFiles) {
        foreach ($linkedFile in $linkedFiles) {
            # Normalize path (handle forward/backward slashes)
            $normalizedPath = $linkedFile.Replace('/', [IO.Path]::DirectorySeparatorChar)
            $fullPath = Join-Path $MEMORY_DIR $normalizedPath
            if (Test-Path $fullPath) {
                Pass-Check "Linked file exists: $linkedFile"
            } else {
                Fail-Check "Linked file missing: $linkedFile"
            }
        }
    } else {
        Info-Check "No linked files found in MEMORY.md"
    }
}

# Check 7: Unreferenced files
if (Test-Path $MEMORY_FILE) {
    Write-Host ""
    Write-Host "${BOLD}Checking for unreferenced files...${RESET}"
    
    $content = Get-Content $MEMORY_FILE -Raw

    $files = Get-ChildItem -Path $MEMORY_DIR -Filter "*.md"
    foreach ($file in $files) {
        if ($file.Name -eq "MEMORY.md") { continue }

        if ($content -like "*$($file.Name)*") {
            Pass-Check "Referenced: $($file.Name)"
        } else {
            Warn-Check "Not referenced in MEMORY.md: $($file.Name)"
        }
    }
}

# Check 8: File sizes
Write-Host ""
Write-Host "${BOLD}Checking file sizes...${RESET}"
$MAX_LINES = 500

$files = Get-ChildItem -Path $MEMORY_DIR -Filter "*.md"
foreach ($file in $files) {
    $lines = (Get-Content $file.FullName).Count
    if ($lines -gt $MAX_LINES) {
        Warn-Check "$($file.Name) is $lines lines (consider splitting at $MAX_LINES)"
    } else {
        Pass-Check "$($file.Name): $lines lines"
    }
}

# Summary
Write-Host ""
Write-Host "${BOLD}Summary${RESET}"
if ($ERRORS -eq 0 -and $WARNINGS -eq 0) {
    Write-Host "${GREEN}${BOLD}All checks passed.${RESET} Memory structure is healthy."
} elseif ($ERRORS -eq 0) {
    Write-Host "${YELLOW}${BOLD}$WARNINGS warning(s).${RESET} No critical issues found."
} else {
    Write-Host "${RED}${BOLD}$ERRORS error(s), $WARNINGS warning(s).${RESET} Fix errors above."
}

exit $ERRORS
