# Incident: [SHORT_DESCRIPTION]

> Runbook for a specific bug or incident. Document the symptoms, root cause, and fix so the same issue never costs time twice.

## Summary

- **Date:** YYYY-MM-DD
- **Severity:** Critical / High / Medium / Low
- **Time to resolve:** (how long it took)
- **Component affected:** (which part of the system)

## Symptoms

> What did the failure look like? Include exact error messages.

```
Error: [paste exact error message here]
```

- Where it appeared: (browser console, server logs, CI pipeline, etc.)
- When it started: (after a deploy, after a dependency update, randomly, etc.)
- Who reported it: (automated monitoring, user report, developer noticed)

## Root Cause

> What was actually wrong? Be specific.

<!-- Example:
The database connection pool was exhausted because the ORM was opening
a new connection per request instead of reusing the pool. This was caused
by instantiating the database client inside the request handler instead
of at module scope.
-->

## Fix

> Exact steps taken to resolve the issue.

### Code Changes

```diff
- // Bad: new client per request
- const db = new DatabaseClient()
+ // Good: reuse module-level client
+ import { db } from '@/lib/database'
```

### Configuration Changes

> Any environment variable, config file, or infrastructure changes.

### Deployment Steps

> If the fix required a specific deployment procedure.

## Verification

> How to confirm the fix is working.

- [ ] Error no longer appears in logs
- [ ] Affected feature works correctly
- [ ] Load test passes without connection exhaustion

## Prevention

> What was done to prevent this from happening again?

<!-- Example:
- Added a linter rule to flag database client instantiation inside functions
- Added connection pool monitoring to the health check endpoint
- Documented the correct pattern in the project knowledge file
-->

## Related Files

> Link to relevant memory files, code files, or external resources.

- Project file: [project-name.md](project-name.md)
- Related incident: (if any)
