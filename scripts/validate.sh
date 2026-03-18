#!/usr/bin/env bash
set -euo pipefail

# Claude Memory System - Validate memory structure
# Checks for structural issues, broken links, and stale entries.
# Usage: validate.sh <memory-dir>

# Colors (only when connected to a terminal)
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' RED='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

usage() {
    echo "Usage: $(basename "$0") <memory-dir>"
    echo ""
    echo "Validate the structure and health of a Claude Memory directory."
    echo ""
    echo "Checks performed:"
    echo "  - MEMORY.md exists and is under 200 lines"
    echo "  - All linked files exist"
    echo "  - All files in directory are referenced in MEMORY.md"
    echo "  - Activity log has recent entries"
    echo "  - No files exceed recommended size"
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
    echo -e "${RED}Error: Memory directory path is required.${RESET}"
    echo ""
    usage
    exit 1
fi

MEMORY_DIR="$1"
ERRORS=0
WARNINGS=0

pass() { echo -e "  ${GREEN}PASS${RESET}  $1"; }
fail() { echo -e "  ${RED}FAIL${RESET}  $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}WARN${RESET}  $1"; WARNINGS=$((WARNINGS + 1)); }
info() { echo -e "  ${BLUE}INFO${RESET}  $1"; }

echo -e "${BOLD}Claude Memory System - Validation${RESET}"
echo -e "Directory: ${BLUE}$MEMORY_DIR${RESET}"
echo ""

# Check 1: Directory exists
if [ ! -d "$MEMORY_DIR" ]; then
    fail "Memory directory does not exist: $MEMORY_DIR"
    echo ""
    echo -e "${RED}${BOLD}Validation failed.${RESET} Directory not found."
    exit 1
fi

# Check 2: MEMORY.md exists
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
    pass "MEMORY.md exists"
else
    fail "MEMORY.md not found"
fi

# Check 3: MEMORY.md line count
if [ -f "$MEMORY_FILE" ]; then
    LINE_COUNT=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
    if [ "$LINE_COUNT" -le 200 ]; then
        pass "MEMORY.md is $LINE_COUNT lines (max 200)"
    else
        warn "MEMORY.md is $LINE_COUNT lines (recommended max: 200)"
    fi
fi

# Check 4: Activity log exists
ACTIVITY_LOG="$MEMORY_DIR/activity-log.md"
if [ -f "$ACTIVITY_LOG" ]; then
    pass "activity-log.md exists"
else
    warn "activity-log.md not found (recommended for session tracking)"
fi

# Check 5: Activity log freshness
if [ -f "$ACTIVITY_LOG" ]; then
    # Check if file was modified in the last 14 days
    if [ "$(uname)" = "Darwin" ]; then
        # macOS: use stat with -f flag
        LAST_MODIFIED=$(stat -f %m "$ACTIVITY_LOG")
    else
        # Linux: use stat with -c flag
        LAST_MODIFIED=$(stat -c %Y "$ACTIVITY_LOG")
    fi
    CURRENT_TIME=$(date +%s)
    AGE_DAYS=$(( (CURRENT_TIME - LAST_MODIFIED) / 86400 ))

    if [ "$AGE_DAYS" -le 14 ]; then
        pass "Activity log updated $AGE_DAYS days ago"
    else
        warn "Activity log is $AGE_DAYS days old (consider updating)"
    fi
fi

# Check 6: Linked files exist
if [ -f "$MEMORY_FILE" ]; then
    echo ""
    echo -e "${BOLD}Checking linked files...${RESET}"

    # Extract markdown links that point to .md files (relative links)
    # Matches patterns like [text](filename.md)
    # Excludes lines inside HTML comments (<!-- ... -->)
    LINKED_FILES=$(grep -v '^\s*<!--' "$MEMORY_FILE" 2>/dev/null | grep -oE '\]\([^)]+\.md\)' 2>/dev/null | sed 's/\](\(.*\))/\1/' | sort -u || true)

    if [ -n "$LINKED_FILES" ]; then
        while IFS= read -r linked_file; do
            full_path="$MEMORY_DIR/$linked_file"
            if [ -f "$full_path" ]; then
                pass "Linked file exists: $linked_file"
            else
                fail "Linked file missing: $linked_file"
            fi
        done <<< "$LINKED_FILES"
    else
        info "No linked files found in MEMORY.md"
    fi
fi

# Check 7: Unreferenced files
if [ -f "$MEMORY_FILE" ]; then
    echo ""
    echo -e "${BOLD}Checking for unreferenced files...${RESET}"

    for file in "$MEMORY_DIR"/*.md; do
        [ -f "$file" ] || continue
        basename_file=$(basename "$file")

        # Skip MEMORY.md itself
        if [ "$basename_file" = "MEMORY.md" ]; then
            continue
        fi

        if grep -q "$basename_file" "$MEMORY_FILE" 2>/dev/null; then
            pass "Referenced: $basename_file"
        else
            warn "Not referenced in MEMORY.md: $basename_file"
        fi
    done
fi

# Check 8: File sizes
echo ""
echo -e "${BOLD}Checking file sizes...${RESET}"
MAX_LINES=500

for file in "$MEMORY_DIR"/*.md; do
    [ -f "$file" ] || continue
    basename_file=$(basename "$file")
    lines=$(wc -l < "$file" | tr -d ' ')

    if [ "$lines" -gt "$MAX_LINES" ]; then
        warn "$basename_file is $lines lines (consider splitting at $MAX_LINES)"
    else
        pass "$basename_file: $lines lines"
    fi
done

# Summary
echo ""
echo -e "${BOLD}Summary${RESET}"
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}${BOLD}All checks passed.${RESET} Memory structure is healthy."
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}${BOLD}$WARNINGS warning(s).${RESET} No critical issues found."
else
    echo -e "${RED}${BOLD}$ERRORS error(s), $WARNINGS warning(s).${RESET} Fix errors above."
fi

exit "$ERRORS"
