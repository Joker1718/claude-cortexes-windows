# Infrastructure: TaskFlow

> Hosting, database, caching, and CI/CD configuration.

## Hosting

| Service | Provider | Plan | Purpose |
|---|---|---|---|
| Web App | Vercel | Pro | Next.js frontend + API routes |
| Database | Neon | Scale | PostgreSQL 16, serverless |
| Cache / Queue | Upstash | Pro | Redis for caching + BullMQ |
| File Storage | S3-compatible | Standard | Task attachments |
| Email | Resend | Starter | Transactional emails |
| Monitoring | Sentry | Team | Error tracking and performance |

## Environments

| Environment | URL | Branch | Database |
|---|---|---|---|
| Production | app.example.com | `main` | `taskflow-prod` |
| Staging | staging.example.com | `staging` | `taskflow-staging` |
| Preview | pr-*.vercel.app | PR branches | `taskflow-staging` (shared) |
| Local | localhost:3000 | any | `taskflow-dev` (local) |

## CI/CD Pipeline (GitHub Actions)

```
Push / PR
    |
    +-- Lint (ESLint + Prettier check)
    +-- Type Check (tsc --noEmit)
    +-- Unit Tests (Vitest)
    +-- Integration Tests (Vitest + test database)
    +-- Build (next build)
    |
    [All pass?]
        |
        +-- PR: Deploy preview to Vercel
        +-- staging branch: Deploy to staging
        +-- main branch: Deploy to production
```

## Database

- **Provider:** Neon (serverless PostgreSQL)
- **Connection:** Prisma with `@prisma/adapter-neon` for serverless compatibility
- **Pooling:** Neon's built-in connection pooler (PgBouncer mode)
- **Migrations:** Prisma Migrate (`npx prisma migrate dev` locally, `npx prisma migrate deploy` in CI)
- **Backups:** Automatic daily backups (Neon), 7-day retention

### Connection Pattern
```
// Use the pooled connection string for Prisma
DATABASE_URL="postgresql://[user]:[pass]@[host]/[db]?sslmode=require"

// Use the direct connection for migrations
DIRECT_URL="postgresql://user:pass@host/db?sslmode=require"
```

## Redis (Upstash)

- **Purpose:** React Query cache invalidation signals, BullMQ job queue, rate limiting
- **Connection:** REST API (Upstash SDK) for serverless, TCP for BullMQ workers
- **Key naming:** `taskflow:{env}:{resource}:{id}` (e.g., `taskflow:prod:board:abc123`)

## Deployment Checklist

1. Ensure all environment variables are set in the deployment platform
2. Run database migrations: `npx prisma migrate deploy`
3. Verify health check endpoint responds: `GET /api/health`
4. Check Sentry for new errors in the first 15 minutes
5. Verify WebSocket connections are working (check real-time updates)

## Monitoring & Alerts

- **Sentry:** Error tracking, performance monitoring, release tracking
- **Uptime:** External uptime check on `/api/health` (5-minute interval)
- **Alerts:** Slack channel for Sentry errors (critical and high severity)
