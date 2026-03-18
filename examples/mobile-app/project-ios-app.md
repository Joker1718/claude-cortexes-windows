# Project: FitTrack Mobile App

> React Native (Expo) mobile application for workout tracking and progress visualization.

## Stack

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Framework | React Native (Expo) | SDK 52 | Managed workflow with custom dev client |
| Language | TypeScript | 5.6 | Strict mode |
| Navigation | React Navigation | 7.x | Native stack + bottom tabs |
| State | Zustand | 5.x | Client state + offline queue |
| Server State | React Query | 5.x | With persistence plugin for offline |
| Local DB | expo-sqlite | latest | Offline workout data |
| Animations | react-native-reanimated | 3.x | Gesture-driven animations |
| Charts | Victory Native | 41.x | Workout progress charts |
| Auth | Expo AuthSession | latest | OAuth2 + token refresh |

## Navigation Structure

```
Root Navigator (Stack)
    |
    +-- Auth Stack (unauthenticated)
    |     +-- Welcome Screen
    |     +-- Login Screen
    |     +-- Signup Screen
    |
    +-- Main Tabs (authenticated)
    |     +-- Home Tab (Dashboard)
    |     +-- Workouts Tab
    |     |     +-- Workout List
    |     |     +-- Workout Detail
    |     |     +-- Active Workout (modal)
    |     +-- Progress Tab
    |     |     +-- Charts
    |     |     +-- Personal Records
    |     +-- Profile Tab
    |           +-- Settings
    |           +-- Data Export
    |
    +-- Modal Stack (overlays)
          +-- Exercise Picker
          +-- Timer
          +-- Rest Period
```

## Key Patterns

### Offline-First Architecture
1. User performs action (e.g., logs a workout)
2. Data saved immediately to SQLite
3. Action added to sync queue (Zustand store, persisted)
4. When online, sync queue processes in order
5. Server responds with canonical IDs and timestamps
6. Local DB updated with server response

### Sync Conflict Resolution
- Server timestamp wins for data conflicts
- Deleted-on-server items are marked as deleted locally (soft delete)
- New items created offline get temporary UUIDs, replaced with server IDs after sync

### Exercise Timer
- Background timer using `expo-task-manager` for accuracy during screen lock
- Haptic feedback at set completion (`expo-haptics`)
- Audio cue option for rest period end (`expo-av`)

## Screen Status

| Screen | Status | Notes |
|---|---|---|
| Welcome / Onboarding | done | 3-step onboarding with animations |
| Login / Signup | done | Email + Google OAuth |
| Dashboard | done | Today's workout, weekly summary, streak counter |
| Workout List | done | Grouped by date, pull-to-refresh |
| Workout Detail | done | Exercise list, sets, notes |
| Active Workout | done | Timer, set logging, rest periods |
| Exercise Picker | done | Search, categories, recent exercises |
| Progress Charts | in-progress | Weight chart done, volume chart pending |
| Personal Records | in-progress | Detection logic done, UI pending |
| Profile / Settings | done | Units, notifications, data export |
| Data Export | planned | Export to CSV / JSON |

## Known Issues

- On Android 14+, the background timer occasionally pauses during Doze mode. Workaround: request battery optimization exemption in settings.
- Victory Native charts re-render on every state change. Need to memoize chart data to prevent jank during scrolling.
- Keyboard avoidance on the active workout screen pushes the timer off-screen on small devices (iPhone SE). Needs layout adjustment.
