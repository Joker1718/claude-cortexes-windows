# Common Memory Patterns

Reusable patterns for organizing knowledge in different scenarios.

---

## Pattern: Multi-Service Architecture

When your project interacts with many external services (payment, email, auth, analytics), create one integration file per service.

```
MEMORY.md
  +-- integration-stripe.md     (payment)
  +-- integration-resend.md     (email)
  +-- integration-auth0.md      (authentication)
  +-- integration-posthog.md    (analytics)
```

Each file follows the integration template: endpoints, auth method, rate limits, known quirks. This prevents the "how does our Stripe integration work again?" question from costing 20 minutes every time.

---

## Pattern: Monorepo Awareness

For monorepos with multiple packages or apps, create one project file per package and use MEMORY.md to show how they relate.

```
MEMORY.md
  +-- project-web.md            (Next.js frontend)
  +-- project-api.md            (Express backend)
  +-- project-shared.md         (shared types and utilities)
  +-- project-mobile.md         (React Native app)
```

In MEMORY.md, document the dependency graph:
```markdown
## Architecture
- `web` depends on `shared` and calls `api`
- `mobile` depends on `shared` and calls `api`
- `api` depends on `shared`
- `shared` has zero external dependencies
```

---

## Pattern: Decision Log

For projects where architectural decisions need to be tracked and revisited, add a decisions section to the project file or create a dedicated file.

```markdown
## Decisions

### 2025-01-15: Auth strategy
**Context:** Need user authentication for the dashboard
**Options considered:** JWT, session cookies, OAuth-only
**Decision:** Session cookies
**Reason:** App uses SSR extensively. Cookies work transparently with
server-side rendering. JWT would require extra client-side logic.
**Status:** Implemented, working well

### 2025-01-10: Database choice
**Context:** Need persistent storage for user data and tasks
**Options considered:** PostgreSQL, SQLite, MongoDB
**Decision:** PostgreSQL via Prisma ORM
**Reason:** Relational data model fits the domain. Prisma provides
type safety and migration management. Team has PostgreSQL experience.
**Status:** Implemented
```

---

## Pattern: Runbook Chain

When incidents are related or build on each other, link them together.

```markdown
# Incident: Connection pool exhaustion (2025-01-20)
...
## Related
- Preceded by: [incident-2025-01-15-slow-queries.md](incident-2025-01-15-slow-queries.md)
  (Slow queries increased connection hold time, eventually exhausting the pool)
- Follow-up: [incident-2025-01-25-pool-monitoring.md](incident-2025-01-25-pool-monitoring.md)
  (Added monitoring to catch this earlier)
```

This creates a narrative that helps understand not just individual bugs, but systemic issues.

---

## Pattern: Onboarding Memory

When working on a team project, create a memory file specifically for onboarding context. This captures things that are obvious to existing team members but confusing for newcomers (including Claude in a new session).

```markdown
# Onboarding Context

## Why things are the way they are
- We use a custom auth system instead of Auth0 because [reason]
- The `legacy/` directory contains code from v1 that can't be removed yet because [reason]
- API v2 endpoints live alongside v1 endpoints; v1 is deprecated but still used by [client]

## Non-obvious setup steps
- You need a local Redis instance running on port 6379
- The seed script must run before the first login will work
- Hot reload doesn't work for changes in `src/lib/config.ts` (restart required)

## Team conventions not in the linter
- We don't use default exports (named exports only)
- Test files go next to the source file, not in a separate `__tests__` directory
- Environment variables are accessed only through `src/lib/env.ts`, never directly
```

---

## Pattern: Research Sprint

When evaluating tools, libraries, or approaches, create a reference file that captures the evaluation.

```markdown
# Reference: State Management Evaluation (2025-01)

## Context
Need client-side state management for the dashboard. Currently using React context
which is causing unnecessary re-renders.

## Candidates Evaluated

### Zustand
- Minimal API, ~1KB
- No provider wrapper needed
- Supports middleware (persist, devtools)
- Verdict: Best fit for our needs

### Jotai
- Atomic model, good for fine-grained reactivity
- More complex mental model
- Verdict: Overkill for our use case

### Redux Toolkit
- Industry standard, excellent devtools
- More boilerplate than needed for our scale
- Verdict: Too heavy for this project

## Decision
Chose Zustand. Implemented in session 5 (see activity log).
```

---

## Pattern: Seasonal Cleanup

At the end of each quarter (or whenever memory feels cluttered), do a cleanup pass:

1. **Archive old activity log entries.** Move entries older than 3 months to `activity-log-archive.md`. Keep only the last 3 months in the main log.

2. **Review incident runbooks.** If a bug was fixed and the fix has been stable for 3+ months, move the runbook to an archive section. Keep it accessible but out of the active index.

3. **Update project files.** Remove references to completed features, archived code, or deprecated patterns.

4. **Prune MEMORY.md.** Remove links to archived files. Keep the index focused on current, active knowledge.

5. **Run validation.** Use `scripts/validate.sh` (or `scripts/validate.ps1` on Windows) to catch any broken links or orphaned files after cleanup.

---

## Pattern: Cross-Project Learning

When you discover a pattern in Project A that applies to Project B, add it to the "Key Patterns" section of both project MEMORY.md files. If the pattern is truly universal, put it in a global memory file.

```
~/.claude/memory/                      (global, all projects)
    MEMORY.md
    patterns-database.md               (database patterns that apply everywhere)
    patterns-api.md                    (API design patterns)

~/projects/app-a/.claude/memory/       (project-specific)
    MEMORY.md                          (references global patterns + local ones)

~/projects/app-b/.claude/memory/       (project-specific)
    MEMORY.md                          (references global patterns + local ones)
```

In each project's MEMORY.md:
```markdown
## Global Patterns
See ~/.claude/memory/ for cross-project patterns (database, API, testing).
```
