# Memory Index
> Concise index for FitTrack (fitness tracking mobile app). Max 200 lines.

## Quick Context
- **Project:** FitTrack - Workout tracking and progress visualization
- **Stack:** React Native (Expo), TypeScript, Node.js API, PostgreSQL
- **Repo:** github.com/example-org/fittrack
- **Status:** Active development, iOS TestFlight beta live

---

## CRITICAL RULES (always loaded)

### Platform Differences
> Always test on both iOS and Android simulators before marking a feature as done.
> Use Platform.select() for platform-specific styling, never hardcode platform checks in business logic.

### Offline-First
> All core features must work offline. Sync when connectivity returns.
> SQLite (via expo-sqlite) is the local data store. Server is the source of truth for sync conflicts.

### App Store Compliance
> No references to "beta", "test", or "coming soon" in user-visible strings.
> All health data access must include purpose strings in Info.plist / AndroidManifest.

---

## PROJECT FILES
- [project-ios-app.md](project-ios-app.md) -- Mobile app: screens, navigation, offline storage
- [project-backend.md](project-backend.md) -- API server: endpoints, auth, sync protocol

## ACTIVITY LOGS
- [activity-log.md](activity-log.md) -- Session-by-session work tracking

## KEY PATTERNS (cross-project)
- React Native: Use `useSafeAreaInsets()` instead of `SafeAreaView` for more control
- Navigation: Stack navigator for auth flow, bottom tabs for main app, modal stack for overlays
- Animations: Prefer `react-native-reanimated` worklets over Animated API (runs on UI thread)
- Forms: React Hook Form with Zod validation (same as web projects)
- Dates: Use `date-fns` everywhere, store as ISO 8601 strings, display in user's timezone
- Images: Compress to max 1200px width before upload (saves bandwidth on mobile networks)
