# Memory Index
> Concise index for [PROJECT_NAME]. Detailed content lives in topic files. Keep this under 200 lines.

## Quick Context
- **Project:** [PROJECT_NAME]
- **Stack:** (fill in your stack here)
- **Repo:** (fill in your repo URL here)
- **Status:** Active development

---

## CRITICAL RULES (always loaded)
> Rules that must be followed in every session. Keep this section short and high-impact.

### Example: Commit Conventions
> Commits use conventional format: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`

### Example: API Route Safety
> All API routes must validate input. Never trust client-side data.

---

## PROJECT FILES
- [project-[PROJECT_NAME].md](project-[PROJECT_NAME].md) -- Stack, architecture, key patterns, component status

## ACTIVITY LOGS
- [activity-log.md](activity-log.md) -- Session-by-session work tracking

## FEEDBACK & PREFERENCES
- [feedback-preferences.md](feedback-preferences.md) -- Code style, conventions, review patterns

## INTEGRATIONS
<!-- Add integration docs as you connect external services -->
<!-- - [integration-stripe.md](integration-stripe.md) -- Payment processing setup -->
<!-- - [integration-auth0.md](integration-auth0.md) -- Authentication flow -->

## INCIDENTS
<!-- Add incident runbooks as you encounter and fix significant bugs -->
<!-- - [incident-2025-01-15-db-migration.md](incident-2025-01-15-db-migration.md) -- Database migration failure -->

## REFERENCES
<!-- Add research notes, useful tools, papers, patterns -->
<!-- - [reference-caching-strategies.md](reference-caching-strategies.md) -- Redis vs in-memory comparison -->

---

## KEY PATTERNS (cross-project)
> Reusable patterns discovered during development. Add entries as you learn.

<!-- Example:
- Prisma: Use `{ field: { not: true } }` instead of `{ OR: [{f:false},{f:null}] }` for nullable booleans
- API routes: Always use async operations with timeouts, never synchronous calls
- React: Wrap fetch calls with AbortController for cleanup
-->
