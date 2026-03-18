# Memory Index
> Concise index for TaskFlow (project management SaaS). Max 200 lines.

## Quick Context
- **Project:** TaskFlow - Team task management with real-time collaboration
- **Stack:** Next.js 15, TypeScript, Prisma, PostgreSQL, Redis, Tailwind CSS
- **Repo:** github.com/example-org/taskflow
- **Status:** Active development, beta launch targeted for Q2

---

## CRITICAL RULES (always loaded)

### Commit Conventions
> Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
> Always include scope: `feat(board): add drag-and-drop reordering`

### API Route Safety
> All API routes MUST: validate input with Zod, check auth via middleware, return typed responses.
> Never use `execSync` in API routes. Always use async operations with timeouts.

### Database Migrations
> Always run `npx prisma migrate dev` locally before committing migration files.
> Never edit existing migration files. Create a new migration instead.

### Environment Variables
> `.env.local` is gitignored. Copy `.env.example` to `.env.local` for local dev.
> Production secrets are in the deployment platform, never in code.

---

## PROJECT FILES
- [project-dashboard.md](project-dashboard.md) -- Frontend: dashboard, board views, real-time updates
- [project-api.md](project-api.md) -- Backend: API routes, auth, background jobs

## INFRASTRUCTURE
- [infrastructure.md](infrastructure.md) -- Hosting, database, Redis, CI/CD pipeline

## ACTIVITY LOGS
- [activity-log.md](activity-log.md) -- Session-by-session work tracking

## INTEGRATIONS
<!-- - [integration-stripe.md](integration-stripe.md) -- Billing and subscriptions -->
<!-- - [integration-resend.md](integration-resend.md) -- Transactional email -->

## INCIDENTS
<!-- - [incident-2025-01-10-ws-memory.md](incident-2025-01-10-ws-memory.md) -- WebSocket memory leak -->

## KEY PATTERNS (cross-project)
- Prisma: Use `{ field: { not: true } }` for nullable boolean filters (avoids OR with null)
- Next.js: Server components for data fetching, client components only when interactivity needed
- Redis: Use `SCAN` instead of `KEYS` in production (KEYS blocks the event loop)
- Zod: Define schemas in `src/lib/validators/` and import into both API routes and forms
- Error boundaries: Every page-level layout should have an error boundary
- Optimistic updates: Use React Query's `onMutate` for instant UI feedback
