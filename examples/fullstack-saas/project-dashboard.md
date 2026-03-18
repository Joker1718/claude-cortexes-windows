# Project: TaskFlow Dashboard (Frontend)

> Frontend application for the TaskFlow project management SaaS.

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Framework | Next.js | 15.1 | App Router, server components |
| Language | TypeScript | 5.6 | Strict mode enabled |
| Styling | Tailwind CSS | 4.0 | Custom design tokens in `tailwind.config.ts` |
| UI Library | Radix Primitives | latest | Accessible, unstyled base components |
| State | React Query | 5.x | Server state; Zustand for client-only state |
| Real-time | Socket.io Client | 4.x | Connected to the API server's WS endpoint |
| Forms | React Hook Form + Zod | latest | Shared validators with API |

## Architecture Overview

```
App Router (src/app/)
    |
    +-- (auth)/         -- Login, signup, password reset (public)
    +-- (dashboard)/    -- Main app (protected, requires auth)
    |       +-- boards/         -- Kanban board views
    |       +-- projects/       -- Project list and settings
    |       +-- team/           -- Team management
    |       +-- settings/       -- User and org settings
    +-- api/            -- API route handlers (Next.js)
```

## Key Patterns

### Server vs Client Components
- **Server components** (default): Data fetching, layout, static UI
- **Client components** (`"use client"`): Interactive elements only (drag-drop, modals, forms)
- Rule: Keep client component boundaries as small as possible

### Data Fetching Strategy
- Server components use direct Prisma queries (no API call to self)
- Client components use React Query hooks that call `/api/` routes
- Real-time updates via Socket.io push events that invalidate React Query cache

### Drag and Drop
- Using `@dnd-kit/core` for board card reordering
- Optimistic reorder on drop, server sync in background
- Conflict resolution: last-write-wins with toast notification on conflict

### Authentication
- Session-based auth with HTTP-only cookies
- Middleware in `src/middleware.ts` checks session on every request
- Protected routes redirect to `/login` if no valid session

## Component Status

| Component | Status | Notes |
|---|---|---|
| Login / Signup | done | OAuth (Google, GitHub) + email/password |
| Board View (Kanban) | done | Drag-and-drop, real-time sync |
| Board View (Table) | in-progress | Sorting and filtering done, inline edit pending |
| Board View (Calendar) | planned | Depends on date-field feature |
| Project Settings | done | Name, description, member management |
| Team Management | done | Invite, roles (admin/member/viewer) |
| User Settings | in-progress | Profile done, notification preferences pending |
| Search | planned | Full-text search across tasks and comments |
| Notifications Center | planned | In-app notifications with real-time badge |

## Known Issues

- Drag-and-drop occasionally flickers on Safari when board has 50+ cards. Suspected CSS containment issue. Workaround: none yet.
- React Query cache invalidation after WebSocket events sometimes causes a double render. Not user-visible but shows in React DevTools.
