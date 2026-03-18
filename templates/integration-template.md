# Integration: [SERVICE_NAME]

> Documentation for the [SERVICE_NAME] integration. Covers setup, endpoints, authentication, and known issues.

## Overview

- **Purpose:** Why this integration exists
- **Service:** [SERVICE_NAME] (link to their docs)
- **Status:** Active / Deprecated / In Progress
- **Added:** YYYY-MM-DD

## Authentication

- **Method:** (API key, OAuth2, JWT, Basic Auth)
- **Token location:** (environment variable name, e.g., `SERVICE_API_KEY`)
- **Token rotation:** (how often, manual or automatic)
- **Scopes/permissions required:** (list required scopes)

## Endpoints Used

| Endpoint | Method | Purpose | Rate Limit |
|---|---|---|---|
| `/api/v1/resource` | GET | Fetch resources | 100/min |
| `/api/v1/resource` | POST | Create resource | 50/min |

## Data Flow

```
Our App --> [SERVICE_NAME] API
    |
    Request: POST /api/v1/resource
    Headers: Authorization: Bearer $TOKEN
    Body: { "field": "value" }
    |
    Response: 200 { "id": "...", "status": "created" }
```

## Configuration

> Environment variables and configuration needed for this integration.

```
SERVICE_API_KEY=your-api-key-here
SERVICE_BASE_URL=https://api.example.com/v1
SERVICE_WEBHOOK_SECRET=your-webhook-secret
```

## Error Handling

| Status Code | Meaning | Our Response |
|---|---|---|
| 401 | Invalid/expired token | Refresh token, retry once |
| 429 | Rate limited | Exponential backoff, max 3 retries |
| 500 | Service down | Log error, return graceful fallback |

## Webhooks

> If the integration sends webhooks to our app.

- **Endpoint:** `/api/webhooks/service-name`
- **Verification:** (how to verify webhook authenticity)
- **Events handled:** (list of event types we process)

## Known Issues & Gotchas

> Document quirks, bugs, and non-obvious behavior.

<!-- Example:
- The API returns timestamps in UTC but without the Z suffix
- Pagination is 1-indexed, not 0-indexed
- Webhook delivery is not guaranteed; implement idempotency
- The sandbox environment has different rate limits than production
-->

## Testing

> How to test this integration locally.

<!-- Example:
- Use the sandbox/staging environment for development
- Mock responses are available in `__mocks__/service-name.ts`
- Webhook testing: use ngrok or a similar tunnel
-->

## Changelog

| Date | Change |
|---|---|
| YYYY-MM-DD | Initial integration |
