# Project: FitTrack Backend API

> Node.js API server for the FitTrack mobile application.

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Runtime | Node.js | 22 LTS | |
| Framework | Fastify | 5.x | Chosen over Express for schema validation and performance |
| ORM | Prisma | 6.x | PostgreSQL |
| Auth | JWT | - | Access tokens (15 min) + refresh tokens (30 days) |
| Validation | Zod | 3.x | Request/response schemas |
| File Storage | S3-compatible | - | Profile photos, exercise images |
| Hosting | Fly.io | - | Auto-scaling, multi-region |

## API Endpoints

```
POST   /auth/register          -- Create account
POST   /auth/login             -- Email/password login
POST   /auth/oauth/google      -- Google OAuth exchange
POST   /auth/refresh           -- Refresh access token
POST   /auth/logout            -- Revoke refresh token

GET    /workouts               -- List user's workouts (paginated)
POST   /workouts               -- Create workout
GET    /workouts/:id           -- Get workout detail
PATCH  /workouts/:id           -- Update workout
DELETE /workouts/:id           -- Delete workout

GET    /exercises              -- List exercises (search, filter by category)
POST   /exercises/custom       -- Create custom exercise

GET    /progress/charts        -- Aggregated data for progress charts
GET    /progress/records       -- Personal records

POST   /sync                   -- Bulk sync endpoint (offline queue)
GET    /sync/changes?since=    -- Get changes since timestamp

GET    /profile                -- Get user profile
PATCH  /profile                -- Update profile
POST   /profile/photo          -- Upload profile photo
DELETE /profile                -- Delete account and all data
```

## Sync Protocol

The sync endpoint handles offline-first data reconciliation.

```
Client POST /sync
Body: {
  "lastSyncTimestamp": "2025-01-15T10:30:00Z",
  "actions": [
    { "type": "create", "entity": "workout", "tempId": "temp-abc", "data": {...} },
    { "type": "update", "entity": "workout", "id": "wk-123", "data": {...} },
    { "type": "delete", "entity": "workout", "id": "wk-456" }
  ]
}

Server Response: {
  "syncTimestamp": "2025-01-15T12:00:00Z",
  "idMappings": { "temp-abc": "wk-789" },
  "conflicts": [],
  "serverChanges": [...]
}
```

### Conflict Rules
- `create`: No conflict possible (new entity)
- `update`: Server compares `updatedAt` timestamps. If server version is newer, return conflict with both versions.
- `delete`: If entity was modified on server after client's last sync, return conflict. Otherwise, delete.

## Database Schema (Key Models)

```
User           -- id, email, name, avatarUrl, units (metric/imperial)
Workout        -- id, userId, name, startedAt, completedAt, notes
WorkoutSet     -- id, workoutId, exerciseId, setNumber, weight, reps, rpe
Exercise       -- id, name, category, isCustom, createdById
PersonalRecord -- id, userId, exerciseId, type (weight/reps/volume), value, achievedAt
SyncLog        -- id, userId, action, entityType, entityId, timestamp
```

## Key Patterns

### Authentication Flow
1. Client sends credentials or OAuth token to `/auth/login` or `/auth/oauth/google`
2. Server returns `{ accessToken, refreshToken }`
3. Access token (JWT, 15 min expiry) sent in `Authorization: Bearer` header
4. Refresh token (opaque, 30 day expiry) stored securely on device
5. On 401, client calls `/auth/refresh` with refresh token to get new access token
6. If refresh fails, redirect to login

### Rate Limiting
- Auth endpoints: 10 requests per minute per IP
- Sync endpoint: 30 requests per minute per user
- General API: 100 requests per minute per user

### Data Deletion
- `DELETE /profile` triggers a cascading soft-delete
- Background job runs after 30 days to permanently purge data
- User can cancel deletion within 30 days by logging in again
