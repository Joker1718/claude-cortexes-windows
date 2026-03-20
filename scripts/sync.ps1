# Claude Memory System - Sync memory files across devices
# Supports: Dropbox, iCloud, Git, or a custom directory
# Usage: sync.ps1 <method> [options]

# Colors
$GREEN = "$([char]27)[0;32m"
$RED = "$([char]27)[0;31m"
$BLUE = "$([char]27)[0;34m"
$YELLOW = "$([char]27)[0;33m"
$BOLD = "$([char]27)[1m"
$RESET = "$([char]27)[0m"

function Show-Usage {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Host "Usage: .\$scriptName <method> [options]"
    Write-Host ""
    Write-Host "Sync Claude Memory files to a shared location for multi-device access."
    Write-Host ""
    Write-Host "Methods:"
    Write-Host "  dropbox <memory-dir>          Sync to ~\Dropbox\claude-memory\"
    Write-Host "  icloud <memory-dir>           Sync to iCloud Drive\claude-memory\"
    Write-Host "  git <memory-dir>              Commit and push memory changes"
    Write-Host "  directory <memory-dir> <dest>  Sync to a custom directory"
    Write-Host ""
    Write-Host "Arguments:"
    Write-Host "  memory-dir   Path to .claude\memory\ directory"
    Write-Host "  dest         Destination directory (for 'directory' method)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\$scriptName dropbox C:\path\to\project\.claude\memory"
    Write-Host "  .\$scriptName git C:\path\to\project\.claude\memory"
    Write-Host "  .\$scriptName directory C:\path\to\project\.claude\memory D:\shared\drive\memory"
}

if ($args.Count -gt 0 -and ($args[0] -eq "-h" -or $args[0] -eq "--help")) {
    Show-Usage
    exit 0
}

if ($args.Count -lt 2) {
    Write-Host "${RED}Error: Method and memory directory are required.${RESET}"
    Write-Host ""
    Show-Usage
    exit 1
}

$METHOD = $args[0]
$MEMORY_DIR_INPUT = $args[1]

if (!(Test-Path $MEMORY_DIR_INPUT)) {
    Write-Host "${RED}Error: Memory directory not found: $MEMORY_DIR_INPUT${RESET}"
    exit 1
}

$MEMORY_DIR = (Get-Item $MEMORY_DIR_INPUT).FullName

if (!(Test-Path (Join-Path $MEMORY_DIR "MEMORY.md"))) {
    Write-Host "${RED}Error: No MEMORY.md found in $MEMORY_DIR. Is this a valid memory directory?${RESET}"
    exit 1
}

function Sync-ToDirectory($dest) {
    if (!(Test-Path $dest)) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }

    # Robocopy is a robust sync tool on Windows
    # /MIR mirrors a directory (BE CAREFUL: it deletes files in destination that aren't in source)
    # /R:3 /W:5 retry 3 times with 5 second wait
    # /NFL /NDL /NJH /NJS quiet down the output
    robocopy $MEMORY_DIR $dest /MIR /R:3 /W:5 /NFL /NDL /NJH /NJS | Out-Null

    Write-Host "${GREEN}Synced to: $dest${RESET}"
}

switch ($METHOD) {
    "dropbox" {
        $HOME_DIR = [System.Environment]::GetFolderPath("UserProfile")
        $DEST = Join-Path $HOME_DIR "Dropbox\claude-memory"
        if (!(Test-Path (Join-Path $HOME_DIR "Dropbox"))) {
            Write-Host "${RED}Error: Dropbox directory not found at $(Join-Path $HOME_DIR 'Dropbox')${RESET}"
            Write-Host "Make sure Dropbox is installed and syncing."
            exit 1
        }
        Write-Host "${BOLD}Syncing to Dropbox...${RESET}"
        Sync-ToDirectory $DEST
        Write-Host "${GREEN}${BOLD}Done.${RESET} Files will sync automatically via Dropbox."
    }

    "icloud" {
        $HOME_DIR = [System.Environment]::GetFolderPath("UserProfile")
        # Windows iCloud path is typically under UserProfile\iCloudDrive
        $ICLOUD_DIR = Join-Path $HOME_DIR "iCloudDrive"
        if (!(Test-Path $ICLOUD_DIR)) {
            Write-Host "${RED}Error: iCloud Drive not found at $ICLOUD_DIR.${RESET}"
            Write-Host "Make sure iCloud for Windows is installed and syncing."
            exit 1
        }
        $DEST = Join-Path $ICLOUD_DIR "claude-memory"
        Write-Host "${BOLD}Syncing to iCloud Drive...${RESET}"
        Sync-ToDirectory $DEST
        Write-Host "${GREEN}${BOLD}Done.${RESET} Files will sync automatically via iCloud."
    }

    "git" {
        Write-Host "${BOLD}Committing memory changes...${RESET}"
        Push-Location $MEMORY_DIR

        # Check if we're inside a git repo
        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "${YELLOW}Memory directory is not in a git repo.${RESET}"
            Write-Host "Initializing a git repository for memory files..."
            git init
            git add .
            git commit -m "Initialize Claude Memory System"
            Write-Host "${GREEN}${BOLD}Done.${RESET} Git repo initialized. Add a remote to sync across devices:"
            Write-Host "  cd $MEMORY_DIR; git remote add origin <your-repo-url>"
            Pop-Location
            exit 0
        }

        # Stage all memory files
        git add .

        # Check if there are changes to commit
        git diff --cached --quiet
        if ($LASTEXITCODE -eq 0) {
            Write-Host "${BLUE}No changes to sync.${RESET}"
            Pop-Location
            exit 0
        }

        # Commit with timestamp
        $TIMESTAMP = Get-Date -Format "yyyy-MM-dd HH:mm"
        git commit -m "Memory sync: $TIMESTAMP"

        # Push if remote exists
        git remote get-url origin 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Pushing to remote..."
            git push
            Write-Host "${GREEN}${BOLD}Done.${RESET} Changes committed and pushed."
        } else {
            Write-Host "${GREEN}${BOLD}Done.${RESET} Changes committed locally."
            Write-Host "${YELLOW}No remote configured. Add one to sync across devices:${RESET}"
            Write-Host "  git remote add origin <your-repo-url>"
        }
        Pop-Location
    }

    "directory" {
        if ($args.Count -lt 3) {
            Write-Host "${RED}Error: Destination directory is required for 'directory' method.${RESET}"
            Write-Host "Usage: .\$($MyInvocation.MyCommand.Name) directory <memory-dir> <destination>"
            exit 1
        }
        $DEST = $args[2]
        Write-Host "${BOLD}Syncing to $DEST...${RESET}"
        Sync-ToDirectory $DEST
        Write-Host "${GREEN}${BOLD}Done.${RESET}"
    }

    Default {
        Write-Host "${RED}Error: Unknown method '$METHOD'.${RESET}"
        Write-Host "Valid methods: dropbox, icloud, git, directory"
        exit 1
    }
}
