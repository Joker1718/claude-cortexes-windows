#!/usr/bin/env bash
set -euo pipefail

# Claude Memory System - Memory Statistics
# Shows statistics about a memory directory.
# Usage: stats.sh <memory-dir>

# Colors (only when connected to a terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[0;33m'
    BOLD='\033[1m'
    DIM='\033[2m'
    RESET='\033[0m'
else
    GREEN='' BLUE='' YELLOW='' BOLD='' DIM='' RESET=''
fi

usage() {
    echo "Usage: $(basename "$0") <memory-dir>"
    echo ""
    echo "Display statistics about a Claude Memory directory."
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") .claude/memory"
    echo "  $(basename "$0") /path/to/project/.claude/memory"
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ $# -lt 1 ]; then
    echo "Error: Memory directory path is required."
    echo ""
    usage
    exit 1
fi

MEMORY_DIR="$1"

if [ ! -d "$MEMORY_DIR" ]; then
    echo "Error: Directory not found: $MEMORY_DIR"
    exit 1
fi

echo -e "${BOLD}Claude Memory System - Statistics${RESET}"
echo -e "Directory: ${BLUE}$MEMORY_DIR${RESET}"
echo ""

# Count files by type
TOTAL_FILES=0
PROJECT_FILES=0
INTEGRATION_FILES=0
INCIDENT_FILES=0
REFERENCE_FILES=0
FEEDBACK_FILES=0
OTHER_FILES=0

for file in "$MEMORY_DIR"/*.md; do
    [ -f "$file" ] || continue
    basename_file=$(basename "$file")
    TOTAL_FILES=$((TOTAL_FILES + 1))

    case "$basename_file" in
        project-*)      PROJECT_FILES=$((PROJECT_FILES + 1)) ;;
        integration-*)  INTEGRATION_FILES=$((INTEGRATION_FILES + 1)) ;;
        incident-*)     INCIDENT_FILES=$((INCIDENT_FILES + 1)) ;;
        reference-*)    REFERENCE_FILES=$((REFERENCE_FILES + 1)) ;;
        feedback-*)     FEEDBACK_FILES=$((FEEDBACK_FILES + 1)) ;;
        MEMORY.md|activity-log.md) ;; # Don't count in "other"
        *)              OTHER_FILES=$((OTHER_FILES + 1)) ;;
    esac
done

# Total lines across all files
TOTAL_LINES=0
for file in "$MEMORY_DIR"/*.md; do
    [ -f "$file" ] || continue
    lines=$(wc -l < "$file" | tr -d ' ')
    TOTAL_LINES=$((TOTAL_LINES + lines))
done

# MEMORY.md line count
MEMORY_LINES=0
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
    MEMORY_LINES=$(wc -l < "$MEMORY_DIR/MEMORY.md" | tr -d ' ')
fi

# Activity log session count (count lines starting with "## " that contain "Session")
SESSION_COUNT=0
if [ -f "$MEMORY_DIR/activity-log.md" ]; then
    SESSION_COUNT=$(grep -c "^## [0-9]" "$MEMORY_DIR/activity-log.md" 2>/dev/null || true)
fi

# Largest file
LARGEST_FILE=""
LARGEST_LINES=0
for file in "$MEMORY_DIR"/*.md; do
    [ -f "$file" ] || continue
    lines=$(wc -l < "$file" | tr -d ' ')
    if [ "$lines" -gt "$LARGEST_LINES" ]; then
        LARGEST_LINES=$lines
        LARGEST_FILE=$(basename "$file")
    fi
done

# Last modified file
if [ "$(uname)" = "Darwin" ]; then
    NEWEST_FILE=$(ls -t "$MEMORY_DIR"/*.md 2>/dev/null | head -1)
else
    NEWEST_FILE=$(ls -t "$MEMORY_DIR"/*.md 2>/dev/null | head -1)
fi
NEWEST_BASENAME=""
if [ -n "$NEWEST_FILE" ]; then
    NEWEST_BASENAME=$(basename "$NEWEST_FILE")
fi

# Print stats
echo -e "${BOLD}Overview${RESET}"
echo -e "  Total files:       ${GREEN}$TOTAL_FILES${RESET}"
echo -e "  Total lines:       ${GREEN}$TOTAL_LINES${RESET}"
echo -e "  Sessions logged:   ${GREEN}$SESSION_COUNT${RESET}"
echo -e "  MEMORY.md lines:   ${GREEN}$MEMORY_LINES${RESET} / 200"
echo ""

echo -e "${BOLD}Files by Type${RESET}"
printf "  %-20s %s\n" "Project files:" "$PROJECT_FILES"
printf "  %-20s %s\n" "Integration docs:" "$INTEGRATION_FILES"
printf "  %-20s %s\n" "Incident runbooks:" "$INCIDENT_FILES"
printf "  %-20s %s\n" "Reference notes:" "$REFERENCE_FILES"
printf "  %-20s %s\n" "Feedback files:" "$FEEDBACK_FILES"
printf "  %-20s %s\n" "Other:" "$OTHER_FILES"
echo ""

echo -e "${BOLD}Details${RESET}"
if [ -n "$LARGEST_FILE" ]; then
    echo -e "  Largest file:      ${BLUE}$LARGEST_FILE${RESET} ($LARGEST_LINES lines)"
fi
if [ -n "$NEWEST_BASENAME" ]; then
    echo -e "  Last modified:     ${BLUE}$NEWEST_BASENAME${RESET}"
fi
echo ""

# Bar chart of file sizes
echo -e "${BOLD}File Sizes${RESET}"
for file in "$MEMORY_DIR"/*.md; do
    [ -f "$file" ] || continue
    basename_file=$(basename "$file")
    lines=$(wc -l < "$file" | tr -d ' ')

    # Create a simple bar (1 block per 10 lines, max 40 blocks)
    bar_length=$((lines / 10))
    if [ "$bar_length" -gt 40 ]; then
        bar_length=40
    fi
    if [ "$bar_length" -lt 1 ] && [ "$lines" -gt 0 ]; then
        bar_length=1
    fi

    bar=""
    for ((i = 0; i < bar_length; i++)); do
        bar="${bar}#"
    done

    printf "  %-30s %4d  ${GREEN}%s${RESET}\n" "$basename_file" "$lines" "$bar"
done
