# SWMS Mobile - Project Status

**Last updated:** 2026-11-04  
**Overall status:** Mobile MVP implemented; platform/API configuration and Android release verification remain.

## Implemented

- Flutter app shell with GetX navigation, feature-first organization, and shared Atomic Design UI pieces.
- Onboarding, sign-in, registration, session restoration through `GET /auth/me`, secure Sanctum token storage, profile view, and logout.
- Registration timeout/server-failure recovery with one login verification attempt; if still uncertain, the UI warns users not to register again and offers a login path.
- Refined onboarding, authentication, and dashboard styling with a calmer green tint system, clearer hierarchy, and status filters suited to mobile.
- Dashboard with status filters, paginated report list, report navigation, profile entry, and report creation action.
- KPI totals derived from four existing paginated API requests: all, pending, in progress, and completed.
- Report creation with required-field validation, optional GPS coordinates/reverse geocoding, manual address entry, optional Google Maps point selection, and image validation/upload (JPG/JPEG/PNG/WEBP, 5 MB maximum).
- Report detail/history with status, admin notes, location, and submitted description.
- Edit and Delete controls are wired to the expected future routes but do not claim success when those routes are absent.
- Android internet/location permissions and Maps key placeholder; iOS location/photo usage descriptions and optional Maps initialization.
- `.env.example` contains configuration key names only. Production API URL stays in the ignored `.env`.

## API gaps for a future backend update

1. `/api/v1/reports/{report}` has no owner-authorized mobile `PATCH` route.
2. `/api/v1/reports/{report}` has no owner-authorized mobile `DELETE` route. An admin web route/service is not a mobile API contract.
3. `image_path` is a storage path, not a public or authorized image URL.
4. Google Maps requires a restricted client key. Android reads it from `.env`; iOS requires the `GOOGLE_MAPS_API_KEY` Xcode build setting. GPS and manual address entry remain available without this key.

Details and proposed endpoint requirements are in [API_DOCUMENTATION.md](API_DOCUMENTATION.md).

## Verification

- `flutter pub get`: passed.
- `dart format lib test`: passed after the latest UI/auth changes.
- `flutter analyze`: passed with no issues after the latest changes.
- `flutter test`: all tests passed, including registration timeout recovery and uncertain-result messaging.
- Registration timeout recovery and uncertain-result messaging have dedicated repository tests.
- `flutter build web`: passed.
- Android runtime/hot restart: not verified; user will handle interactive debugging.
- Graphify JSON/report/HTML: existing outputs predate the latest auth/UI refinements and have not been refreshed.

No backend source or backend documentation was changed.

## Next steps

1. Verify Android runtime on an available target when ready.
2. Configure a restricted Maps client key for each required platform before using the map picker.
3. Add focused tests for authentication/API error flows, report form validation/location fallback, and navigation.
4. Ask backend to provide the mobile update/delete routes and an image delivery contract.
5. Refresh Graphify outputs to include the latest auth/UI refinements.
