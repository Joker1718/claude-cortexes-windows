# Feedback & Preferences

> Encodes the developer's coding style, conventions, and preferences.
> Claude reads this file to maintain consistency across sessions.
> Update when preferences change or new patterns emerge.

## Code Style

### General
- Indentation: (spaces/tabs, how many)
- Line length: (preferred max)
- Semicolons: (yes/no for JS/TS)
- Quotes: (single/double)
- Trailing commas: (yes/no)

### Naming
- Variables: (camelCase, snake_case, etc.)
- Functions: (camelCase, snake_case, etc.)
- Components: (PascalCase, etc.)
- Files: (kebab-case, camelCase, etc.)
- Database columns: (snake_case, camelCase, etc.)

### Comments
- When to comment: (complex logic, public APIs, non-obvious behavior)
- Style: (JSDoc, inline, block)
- Language: (English, other)

## Commit Conventions
- Format: (conventional commits, free-form, etc.)
- Scope: (required, optional, not used)
- Example: `feat(auth): add OAuth2 login flow`

## Code Review Preferences
- What matters most: (readability, performance, security, test coverage)
- Common feedback patterns: (document recurring review comments here)

## Architecture Preferences
- State management: (preferred approach)
- API design: (REST, GraphQL, tRPC)
- Database: (ORM preference, migration strategy)
- Testing: (unit/integration/e2e balance, frameworks)

## Communication Style
- Response length: (concise, detailed, depends on context)
- Explanation depth: (just the fix, explain the why, teach the concept)
- When to ask vs. decide: (what level of decisions should Claude make independently)

## Anti-Patterns
> Things the developer specifically does NOT want. Document these to prevent repeated corrections.

<!-- Example:
- Do NOT use `any` type in TypeScript unless absolutely necessary
- Do NOT add console.log statements in committed code
- Do NOT use default exports (prefer named exports)
- Do NOT create files over 300 lines without discussing splitting
-->

## Session Behavior
- At session start: (read memory, summarize what's loaded, wait for task)
- At session end: (update activity log, note unfinished work)
- When uncertain: (ask, make a judgment call and note it, present options)
