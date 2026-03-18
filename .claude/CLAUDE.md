# claude-cortex - Meta Instructions

This repository IS the claude-cortex. When working on this codebase, follow these guidelines.

## About This Project
A structured, file-based persistent memory framework for Claude Code. It provides templates, scripts, and documentation for giving Claude long-term memory across sessions.

## Repository Structure
- `templates/` -- Markdown templates for different types of knowledge files
- `examples/` -- Complete example memory setups for reference
- `scripts/` -- Bash utilities for initialization, sync, validation, and statistics
- `docs/` -- User-facing documentation
- `setup.sh` -- One-command setup for new users

## Development Guidelines

### Scripts
- All scripts use `#!/usr/bin/env bash` and `set -euo pipefail`
- Scripts must work on both macOS and Linux
- Colors only when stdout is a terminal (check `[ -t 1 ]`)
- Every script has `-h` / `--help` support

### Templates
- Templates must be immediately usable, not skeletons with TODO placeholders
- Include inline comments explaining each section's purpose
- Use consistent Markdown formatting across all templates

### Documentation
- Write in clear, direct language
- Use concrete examples over abstract descriptions
- No personal data, IP addresses, real usernames, or API keys in any file

### Testing Changes
- Run `scripts/validate.sh examples/fullstack-saas` to verify the example memory setup
- Run `scripts/validate.sh examples/mobile-app` to verify the second example
- Run `scripts/stats.sh examples/fullstack-saas` to verify statistics output
- Test `setup.sh` in a temporary directory

## Quality Standards
- Every file must be polished and production-ready
- README must be competitive with popular open-source projects
- Examples must feel realistic and useful
- Scripts must handle errors gracefully with clear messages
