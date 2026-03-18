#!/usr/bin/env bash
set -euo pipefail

# Claude Memory System - Initialize memory for a project
# Usage: init.sh <project-name> [target-directory]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Colors (only when connected to a terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' RED='' BLUE='' BOLD='' RESET=''
fi

usage() {
    echo "Usage: $(basename "$0") <project-name> [target-directory]"
    echo ""
    echo "Initialize Claude Memory System for a project."
    echo ""
    echo "Arguments:"
    echo "  project-name       Name of your project (used in file names)"
    echo "  target-directory   Directory to initialize (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") my-saas-app"
    echo "  $(basename "$0") mobile-app /path/to/project"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Project name is required.${RESET}"
    echo ""
    usage
    exit 1
fi

PROJECT_NAME="$1"
TARGET_DIR="${2:-.}"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo -e "${RED}Error: Directory '$TARGET_DIR' does not exist.${RESET}"
    exit 1
}

MEMORY_DIR="$TARGET_DIR/.claude/memory"

if [ -d "$MEMORY_DIR" ]; then
    echo -e "${RED}Error: Memory directory already exists at $MEMORY_DIR${RESET}"
    echo "Use the existing memory system or remove the directory first."
    exit 1
fi

echo -e "${BOLD}Initializing Claude Memory System${RESET}"
echo -e "  Project: ${BLUE}$PROJECT_NAME${RESET}"
echo -e "  Target:  ${BLUE}$TARGET_DIR${RESET}"
echo ""

# Check that templates exist
if [ ! -d "$REPO_DIR/templates" ]; then
    echo -e "${RED}Error: Templates directory not found at $REPO_DIR/templates${RESET}"
    echo "Make sure you're running this script from the claude-cortex repository."
    exit 1
fi

# Create directory
mkdir -p "$MEMORY_DIR"

# Copy and customize MEMORY.md
sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "$REPO_DIR/templates/MEMORY.md" > "$MEMORY_DIR/MEMORY.md"

# Copy templates
cp "$REPO_DIR/templates/activity-log.md" "$MEMORY_DIR/activity-log.md"
cp "$REPO_DIR/templates/feedback-template.md" "$MEMORY_DIR/feedback-preferences.md"

# Create project file from template
sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "$REPO_DIR/templates/project-template.md" > "$MEMORY_DIR/project-$PROJECT_NAME.md"

# Create CLAUDE.md if it doesn't exist
CLAUDE_MD="$TARGET_DIR/.claude/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
    cat > "$CLAUDE_MD" << 'EOF'
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
EOF
    echo -e "  ${GREEN}+${RESET} .claude/CLAUDE.md"
fi

echo -e "  ${GREEN}+${RESET} .claude/memory/MEMORY.md"
echo -e "  ${GREEN}+${RESET} .claude/memory/activity-log.md"
echo -e "  ${GREEN}+${RESET} .claude/memory/project-$PROJECT_NAME.md"
echo -e "  ${GREEN}+${RESET} .claude/memory/feedback-preferences.md"
echo ""
echo -e "${GREEN}${BOLD}Done.${RESET} Memory system initialized for '$PROJECT_NAME'."
echo ""
echo "Add more memory files as needed using templates from:"
echo "  $REPO_DIR/templates/"
