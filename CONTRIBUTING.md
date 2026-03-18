# Contributing to claude-cortex

Thank you for your interest in contributing. This document explains how to get involved.

## Ways to Contribute

- **Templates**: Create templates for project types not yet covered (game dev, data science, DevOps, etc.)
- **Examples**: Add realistic example memory setups for different domains
- **Scripts**: Improve existing scripts or add new utilities (backup, migration, search)
- **Documentation**: Fix typos, clarify explanations, add diagrams
- **Translations**: Translate docs to other languages
- **Bug Reports**: File issues for scripts that don't work on your platform

## Getting Started

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test any scripts on both macOS and Linux if possible
5. Submit a pull request

## Guidelines

### Templates
- Every template must be immediately usable, not a skeleton with TODO placeholders
- Include inline comments explaining each section's purpose
- Keep the structure consistent with existing templates
- Test that `scripts/validate.sh` passes with your template

### Scripts
- Use `#!/usr/bin/env bash` for portability
- Include `set -euo pipefail` for safety
- Support both macOS (BSD) and Linux (GNU) tool variants
- Add usage instructions in a help flag (`-h` / `--help`)
- Use colors only when stdout is a terminal

### Documentation
- Write in clear, direct language
- Use concrete examples over abstract descriptions
- Keep line length reasonable (no hard wrap required, but keep paragraphs readable)
- Link to related docs where helpful

### Commit Messages
- Use present tense: "Add template" not "Added template"
- First line under 72 characters
- Reference issues where applicable: "Fix validation on Linux (#42)"

## Pull Request Process

1. Ensure your branch is up to date with `main`
2. Verify that `scripts/validate.sh` passes on the templates directory
3. Describe what your PR does and why
4. Link related issues
5. Be responsive to review feedback

## Code of Conduct

Be respectful and constructive. We're all here to build useful tools.

## Questions?

Open an issue with the "question" label. We'll get back to you.
