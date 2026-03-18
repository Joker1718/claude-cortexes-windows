# Activity Log

> Session-by-session record for FitTrack. Most recent first.

---

## 2025-01-17 | Session 8
**Context:** Progress charts feature
**Done:**
- Built weight progression chart using Victory Native (line chart with date axis)
- Implemented data aggregation on the backend: daily max weight per exercise
- Added exercise selector dropdown on the progress screen
- Chart supports pinch-to-zoom and pan gestures via reanimated
**Decisions:**
- Aggregate data server-side to avoid sending raw set data to the chart (bandwidth)
- Show last 90 days by default with option to expand to 6 months or 1 year
**Next:**
- Volume chart (sets x reps x weight per session)
- Personal records UI (detection logic already on backend)
- Fix chart memoization issue (re-renders on scroll)
**Blockers:** None

## 2025-01-15 | Session 7
**Context:** Offline sync implementation
**Done:**
- Built sync queue in Zustand with persistence (MMKV storage)
- Implemented POST /sync endpoint on backend with conflict resolution
- Tested offline workout logging: create workout offline, sync on reconnect
- Added sync status indicator in the app header (synced / syncing / offline)
**Decisions:**
- Sync queue processes sequentially (not parallel) to maintain ordering guarantees
- Temporary IDs use `temp-` prefix + UUIDv4 to avoid collisions
- On conflict, keep server version and show user a merge dialog (not implemented yet)
**Next:**
- Progress charts feature (weight over time, volume over time)
- Merge conflict dialog UI for sync conflicts
**Blockers:** None

## 2025-01-13 | Session 6
**Context:** Active workout screen with timer and set logging
**Done:**
- Built active workout screen with exercise list and set entry
- Implemented rest timer with background task (expo-task-manager)
- Added haptic feedback on set completion and timer end
- Swipe-to-delete on sets, long-press to edit
**Decisions:**
- Rest timer runs as background task for accuracy during screen lock
- Set data is auto-saved to SQLite on every change (no explicit save button)
- Workout is auto-completed after 4 hours of inactivity
**Next:**
- Offline sync protocol (queue actions while offline, sync on reconnect)
- Exercise picker search improvements (fuzzy matching)
**Blockers:** Android background timer occasionally pauses in Doze mode. Tracking as known issue.
