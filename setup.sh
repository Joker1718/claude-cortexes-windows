#!/usr/bin/env bash
set -euo pipefail

# Claude Memory System - Setup
# Creates the memory structure in the current directory or a specified project.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors (only when connected to a terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' BLUE='' YELLOW='' BOLD='' RESET=''
fi

echo -e "${BOLD}Claude Memory System - Setup${RESET}"
echo ""

# Ask for project name
read -rp "Project name: " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "Error: Project name is required."
    exit 1
fi

# Ask for target directory
read -rp "Target directory [.]: " TARGET_DIR
TARGET_DIR="${TARGET_DIR:-.}"

# Resolve to absolute path
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd)" || {
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
}

MEMORY_DIR="$TARGET_DIR/.claude/memory"

echo ""
echo -e "Setting up memory in: ${BLUE}$MEMORY_DIR${RESET}"
echo ""

# Create directory structure
mkdir -p "$MEMORY_DIR"

# Copy templates
cp "$SCRIPT_DIR/templates/activity-log.md" "$MEMORY_DIR/activity-log.md"
cp "$SCRIPT_DIR/templates/project-template.md" "$MEMORY_DIR/project-${PROJECT_NAME}.md"
cp "$SCRIPT_DIR/templates/feedback-template.md" "$MEMORY_DIR/feedback-preferences.md"

# Generate MEMORY.md from template, substituting project name
sed "s/\[PROJECT_NAME\]/$PROJECT_NAME/g" "$SCRIPT_DIR/templates/MEMORY.md" > "$MEMORY_DIR/MEMORY.md"

# Create CLAUDE.md if it doesn't exist
CLAUDE_MD="$TARGET_DIR/.claude/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
    cat > "$CLAUDE_MD" << 'CLAUDEEOF'
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
CLAUDEEOF
    echo -e "  ${GREEN}Created${RESET} .claude/CLAUDE.md"
fi

echo -e "  ${GREEN}Created${RESET} .claude/memory/MEMORY.md"
echo -e "  ${GREEN}Created${RESET} .claude/memory/activity-log.md"
echo -e "  ${GREEN}Created${RESET} .claude/memory/project-${PROJECT_NAME}.md"
echo -e "  ${GREEN}Created${RESET} .claude/memory/feedback-preferences.md"
echo ""
echo -e "${GREEN}${BOLD}Memory system initialized for '$PROJECT_NAME'.${RESET}"
echo ""
echo "Next steps:"
echo "  1. Open your project in Claude Code"
echo "  2. Claude will read .claude/CLAUDE.md and discover the memory system"
echo "  3. At the end of each session, Claude updates the activity log"
echo ""
echo "Add more memory files as needed:"
echo "  - Integration docs:  cp templates/integration-template.md .claude/memory/integration-<name>.md"
echo "  - Incident runbooks: cp templates/incident-template.md .claude/memory/incident-<name>.md"
echo "  - Research notes:    cp templates/reference-template.md .claude/memory/reference-<name>.md"
