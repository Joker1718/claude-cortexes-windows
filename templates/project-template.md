# Project: [PROJECT_NAME]

> Central knowledge file for this project. Covers stack, architecture, key patterns, and component status.

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Frontend | | | |
| Backend | | | |
| Database | | | |
| Hosting | | | |
| CI/CD | | | |

## Architecture Overview

> Describe the high-level architecture. Include data flow, key services, and how components connect.

```
[Client] --> [API Gateway] --> [App Server] --> [Database]
                                    |
                                    +--> [Cache]
                                    |
                                    +--> [External APIs]
```

## Directory Structure

> Document the key directories and what lives where.

```
src/
  app/          -- Page routes and layouts
  components/   -- Reusable UI components
  lib/          -- Shared utilities and helpers
  api/          -- API route handlers
```

## Key Patterns

> Patterns and conventions specific to this project.

### Naming Conventions
- Components: PascalCase (`UserProfile.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- API routes: kebab-case (`/api/user-profile`)

### Data Fetching
> Describe how data is fetched (server components, client hooks, etc.)

### Error Handling
> Describe the error handling strategy

### Authentication
> Describe the auth flow

## Component Status

> Track what's built, what's in progress, and what's planned.

| Component | Status | Notes |
|---|---|---|
| | | |

Status values: `done` | `in-progress` | `planned` | `blocked`

## Environment Setup

> Steps to get the project running locally.

```bash
# 1. Install dependencies
# 2. Set up environment variables
# 3. Run database migrations
# 4. Start development server
```

## Deployment

> How to deploy, and any gotchas.

## Known Issues

> Current bugs or limitations that haven't been fixed yet.

## External Dependencies

> Third-party services this project depends on, with links to their docs.
