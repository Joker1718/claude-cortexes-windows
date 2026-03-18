#!/usr/bin/env bash
set -euo pipefail

# Claude Memory System - Sync memory files across devices
# Supports: Dropbox, iCloud, Git, or a custom directory
# Usage: sync.sh <method> [options]

# Colors (only when connected to a terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' RED='' BLUE='' YELLOW='' BOLD='' RESET=''
fi

MEMORY_DIR=""

usage() {
    echo "Usage: $(basename "$0") <method> [options]"
    echo ""
    echo "Sync Claude Memory files to a shared location for multi-device access."
    echo ""
    echo "Methods:"
    echo "  dropbox <memory-dir>          Sync to ~/Dropbox/claude-memory/"
    echo "  icloud <memory-dir>           Sync to iCloud Drive/claude-memory/"
    echo "  git <memory-dir>              Commit and push memory changes"
    echo "  directory <memory-dir> <dest>  Sync to a custom directory"
    echo ""
    echo "Arguments:"
    echo "  memory-dir   Path to .claude/memory/ directory"
    echo "  dest         Destination directory (for 'directory' method)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") dropbox /path/to/project/.claude/memory"
    echo "  $(basename "$0") git /path/to/project/.claude/memory"
    echo "  $(basename "$0") directory /path/to/project/.claude/memory /shared/drive/memory"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Method and memory directory are required.${RESET}"
    echo ""
    usage
    exit 1
fi

METHOD="$1"
MEMORY_DIR="$2"

if [ ! -d "$MEMORY_DIR" ]; then
    echo -e "${RED}Error: Memory directory not found: $MEMORY_DIR${RESET}"
    exit 1
fi

if [ ! -f "$MEMORY_DIR/MEMORY.md" ]; then
    echo -e "${RED}Error: No MEMORY.md found in $MEMORY_DIR. Is this a valid memory directory?${RESET}"
    exit 1
fi

sync_to_directory() {
    local dest="$1"
    mkdir -p "$dest"

    # Use rsync if available, fall back to cp
    if command -v rsync &>/dev/null; then
        rsync -av --delete "$MEMORY_DIR/" "$dest/"
    else
        # Remove destination contents and copy fresh
        rm -rf "${dest:?}/"*
        cp -R "$MEMORY_DIR/"* "$dest/"
    fi

    echo -e "${GREEN}Synced to: $dest${RESET}"
}

case "$METHOD" in
    dropbox)
        DEST="$HOME/Dropbox/claude-memory"
        if [ ! -d "$HOME/Dropbox" ]; then
            echo -e "${RED}Error: Dropbox directory not found at $HOME/Dropbox${RESET}"
            echo "Make sure Dropbox is installed and syncing."
            exit 1
        fi
        echo -e "${BOLD}Syncing to Dropbox...${RESET}"
        sync_to_directory "$DEST"
        echo -e "${GREEN}${BOLD}Done.${RESET} Files will sync automatically via Dropbox."
        ;;

    icloud)
        # macOS iCloud Drive path
        ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
        if [ ! -d "$ICLOUD_DIR" ]; then
            echo -e "${RED}Error: iCloud Drive not found.${RESET}"
            echo "Make sure iCloud Drive is enabled in System Settings."
            exit 1
        fi
        DEST="$ICLOUD_DIR/claude-memory"
        echo -e "${BOLD}Syncing to iCloud Drive...${RESET}"
        sync_to_directory "$DEST"
        echo -e "${GREEN}${BOLD}Done.${RESET} Files will sync automatically via iCloud."
        ;;

    git)
        echo -e "${BOLD}Committing memory changes...${RESET}"
        cd "$MEMORY_DIR"

        # Check if we're inside a git repo
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo -e "${YELLOW}Memory directory is not in a git repo.${RESET}"
            echo "Initializing a git repository for memory files..."
            git init
            git add .
            git commit -m "Initialize Claude Memory System"
            echo -e "${GREEN}${BOLD}Done.${RESET} Git repo initialized. Add a remote to sync across devices:"
            echo "  cd $MEMORY_DIR && git remote add origin <your-repo-url>"
            exit 0
        fi

        # Stage all memory files
        git add .

        # Check if there are changes to commit
        if git diff --cached --quiet; then
            echo -e "${BLUE}No changes to sync.${RESET}"
            exit 0
        fi

        # Commit with timestamp
        TIMESTAMP=$(date +"%Y-%m-%d %H:%M")
        git commit -m "Memory sync: $TIMESTAMP"

        # Push if remote exists
        if git remote get-url origin &>/dev/null; then
            echo "Pushing to remote..."
            git push
            echo -e "${GREEN}${BOLD}Done.${RESET} Changes committed and pushed."
        else
            echo -e "${GREEN}${BOLD}Done.${RESET} Changes committed locally."
            echo -e "${YELLOW}No remote configured. Add one to sync across devices:${RESET}"
            echo "  git remote add origin <your-repo-url>"
        fi
        ;;

    directory)
        if [ $# -lt 3 ]; then
            echo -e "${RED}Error: Destination directory is required for 'directory' method.${RESET}"
            echo "Usage: $(basename "$0") directory <memory-dir> <destination>"
            exit 1
        fi
        DEST="$3"
        echo -e "${BOLD}Syncing to $DEST...${RESET}"
        sync_to_directory "$DEST"
        echo -e "${GREEN}${BOLD}Done.${RESET}"
        ;;

    *)
        echo -e "${RED}Error: Unknown method '$METHOD'.${RESET}"
        echo "Valid methods: dropbox, icloud, git, directory"
        exit 1
        ;;
esac
