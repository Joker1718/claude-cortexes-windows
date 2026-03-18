# Project: TaskFlow API (Backend)

> Backend API and business logic for the TaskFlow project management SaaS.

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Runtime | Node.js | 22 LTS | Running in Next.js API routes |
| ORM | Prisma | 6.x | PostgreSQL adapter |
| Auth | Custom | - | Session-based, bcrypt + HTTP-only cookies |
| Validation | Zod | 3.x | Shared schemas with frontend |
| Email | Resend SDK | 3.x | Transactional emails |
| Queue | BullMQ | 5.x | Background jobs via Redis |
| WebSocket | Socket.io | 4.x | Real-time board updates |

## API Route Structure

```
src/app/api/
    +-- auth/
    |     +-- login/        POST   -- Email/password login
    |     +-- signup/       POST   -- Create account
    |     +-- logout/       POST   -- Destroy session
    |     +-- oauth/[provider]/    -- OAuth callback handlers
    |
    +-- projects/
    |     +-- route.ts      GET    -- List user's projects
    |     +-- route.ts      POST   -- Create project
    |     +-- [id]/
    |           +-- route.ts      GET/PATCH/DELETE
    |           +-- members/      GET/POST/DELETE
    |
    +-- boards/
    |     +-- [id]/
    |           +-- route.ts      GET/PATCH
    |           +-- tasks/        GET/POST
    |           +-- reorder/      PATCH  -- Bulk reorder tasks
    |
    +-- tasks/
    |     +-- [id]/
    |           +-- route.ts      GET/PATCH/DELETE
    |           +-- comments/     GET/POST
    |           +-- attachments/  GET/POST/DELETE
    |
    +-- webhooks/
          +-- stripe/       POST   -- Billing events
```

## Key Patterns

### Request Validation
Every API route follows this pattern:
1. Parse and validate input with Zod
2. Check authentication (via middleware or session helper)
3. Check authorization (is user allowed to do this?)
4. Execute business logic
5. Return typed response

### Error Handling
- Business errors: Return appropriate HTTP status + JSON error body
- Validation errors: 400 with field-level error details
- Auth errors: 401 (not logged in) or 403 (not permitted)
- Unexpected errors: 500 with generic message, log full error server-side

### Background Jobs
- BullMQ processes jobs via Redis
- Jobs: email sending, file processing, webhook delivery, scheduled notifications
- Each job type has its own processor in `src/jobs/`
- Failed jobs retry 3 times with exponential backoff

### WebSocket Events
- Server emits events when tasks are created, updated, moved, or deleted
- Events are scoped to board rooms (clients join a room per board)
- Event payload is minimal (just the changed entity ID + change type)
- Clients fetch full data via React Query invalidation after receiving events

## Database Schema (Key Models)

```
User          -- id, email, name, hashedPassword, role
Organization  -- id, name, plan, stripeCustomerId
Project       -- id, name, orgId, createdById
Board         -- id, name, projectId
Column        -- id, name, boardId, position
Task          -- id, title, description, columnId, position, assigneeId
Comment       -- id, body, taskId, authorId
```

## Known Issues

- BullMQ dashboard (Bull Board) is only accessible in development. Need to add auth before enabling in production.
- The `reorder` endpoint accepts the full column's task order. For large columns (100+ tasks), this payload gets large. Consider switching to a relative-position approach.
