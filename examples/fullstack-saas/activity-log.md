# Activity Log

> Session-by-session record for TaskFlow. Most recent first.

---

## 2025-01-18 | Session 12
**Context:** Implement table view for boards
**Done:**
- Built table view component with sortable columns (title, assignee, due date, priority, status)
- Added column filtering with multi-select dropdowns
- Connected to existing React Query hooks (same data as Kanban view)
- Added view toggle button in board header (Kanban / Table)
**Decisions:**
- Used Tanstack Table for sorting and filtering (better performance than custom implementation for large datasets)
- Table view is read-only for now; inline editing will come in a future session
**Next:**
- Add inline editing for task title and assignee in table view
- Add bulk actions (select multiple rows, change status/assignee)
- Start on calendar view once date fields are added to tasks
**Blockers:** None

## 2025-01-16 | Session 11
**Context:** Fix WebSocket reconnection issues reported by QA
**Done:**
- Diagnosed WebSocket disconnect during laptop sleep/wake cycle
- Implemented exponential backoff reconnection with jitter
- Added connection status indicator in the top bar (green dot = connected, yellow = reconnecting)
- Added offline queue: actions taken while disconnected replay on reconnect
**Decisions:**
- Max reconnection attempts: 10, then show "connection lost" banner with manual retry button
- Offline queue is stored in memory only (no localStorage), acceptable for short disconnects
**Next:**
- Table view for boards (next feature)
- Consider localStorage for offline queue if users report data loss during longer disconnects
**Blockers:** None

## 2025-01-14 | Session 10
**Context:** Set up CI/CD pipeline and staging environment
**Done:**
- Configured GitHub Actions: lint, type-check, test, build on every PR
- Set up staging environment on Railway (separate database and Redis instances)
- Added preview deployments for PRs via Vercel
- Wrote seed script for staging database with realistic sample data
**Decisions:**
- Staging uses a separate Stripe test environment (not connected to production billing)
- Preview deployments share the staging database (acceptable for now, isolate later if needed)
**Next:**
- Fix WebSocket reconnection issues (QA found disconnect bug)
- Set up error monitoring (Sentry) for staging and production
**Blockers:** None

## 2025-01-12 | Session 9
**Context:** Implement real-time collaboration on boards
**Done:**
- Set up Socket.io server alongside Next.js API
- Implemented board room concept (users join a room per board)
- Added real-time task creation, updates, moves, and deletions
- Built presence indicator showing who else is viewing the board
**Decisions:**
- WebSocket events carry minimal payloads (entity ID + change type only)
- Clients invalidate React Query cache on events to fetch fresh data
- Chose this over sending full entity data to avoid stale-data bugs
**Next:**
- CI/CD pipeline and staging environment setup
- Optimistic conflict resolution for simultaneous edits
**Blockers:** None
