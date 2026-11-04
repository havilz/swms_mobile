# SWMS Mobile - Implementation Tasks

## Product and architecture decisions

- **UI methodology:** Atomic Design - compose reusable atoms into molecules, organisms, templates, and complete pages. This is the UI/component hierarchy, not a replacement for separating presentation, state, and data responsibilities.
- **Application structure:** feature-first Flutter organization, with shared design-system components and shared infrastructure.
- **State management and navigation:** GetX (`GetxController`, route bindings, and GetX navigation). Keep API and business rules out of presentation widgets.
- **Production API:** read `PRODUCTION_API_URL` from `.env`; it already includes `/api/v1`. Never commit `.env` or put backend-private credentials in the mobile application.
- **API contract:** see [API_DOCUMENTATION.md](API_DOCUMENTATION.md).
- **Project progress:** see [project_status.md](project_status.md).

## Feature scope

1. **Onboarding and authentication**
   - Provide welcome/onboarding, sign-in, and registration pages.
   - Use `POST /auth/login`, `POST /auth/register`, `GET /auth/me`, and `POST /auth/logout`.
   - Persist the Sanctum token in platform secure storage, never plain-text preferences or logs.
2. **Home/dashboard**
   - Show KPI cards and the signed-in user's reports, with status badges.
   - Tapping a report/status opens its detail/history page.
   - Put a profile entry/badge in the top-right and a floating action button for creating a report.
   - The API paginates reports and filters by one status; the dashboard derives counts from four small paginated requests (all, pending, in progress, completed).
3. **Profile**
   - Show the authenticated user's profile from `GET /auth/me` and provide logout.
   - Profile editing is out of current API scope; do not imply that fields can be saved until a backend endpoint exists.
4. **Report creation**
   - Collect title, description, address, coordinates, and an optional image.
   - Let the user get their current GPS location and choose/refine a location on a Google Maps-backed map; resolve coordinates to an address when available and keep a manual address fallback.
   - Handle location permission denial, unavailable GPS/network, and map/geocoding failures without blocking manual entry.
   - Select an image and enforce the backend contract: JPG/JPEG/PNG/WEBP, maximum 5 MB.
   - Submit `POST /reports` as `multipart/form-data` when an image is attached. Do not send `status`, `user_id`, or `admin_notes`.
5. **Report detail/history**
   - Show report details, current status, and `admin_notes` from `GET /reports/{report}`.
   - Include Edit and Delete actions in the UI. The current mobile API lacks owner-authorized update/delete endpoints, so preserve server errors and never show a false success; coordinate endpoint delivery with backend before these actions can work.
6. **Configuration and platform setup**
   - Load `.env` as a Flutter asset; use `.env.example` as the safe key-name template.
   - Restrict `GOOGLE_MAPS_API_KEY` to this app/platform. Android reads it from `.env` during Gradle configuration; iOS requires the `GOOGLE_MAPS_API_KEY` Xcode build setting.

## Ordered implementation plan

### Phase 0 - Foundation and secure configuration

- [x] Confirm and document the feature-first folder structure and Atomic Design component boundaries.
- [x] Add GetX and establish app routes, bindings, and shared feature-controller conventions.
- [x] Load and validate `PRODUCTION_API_URL` from `.env`; add a safe example, ignore environment files, and fail clearly when required configuration is missing.
- [ ] Create a shared API client with JSON headers, Sanctum Bearer token injection, multipart upload support, timeouts, and consistent mapping for `401`, `403`, `422`, and `429`.
- [x] Add secure token storage and session restoration/logout behavior.
- [ ] Add focused tests for configuration, API error mapping, and token handling.

### Phase 1 - Onboarding, sign-in, and profile

- [x] Build reusable form controls, status badges, KPI values, and feedback/loading states.
- [x] Implement onboarding, registration, and sign-in screens with client/server validation.
- [x] Restore the session with `GET /auth/me`; clear invalid tokens on `401` and keep other API failures visible.
- [x] Implement read-only profile and logout.
- [ ] Add widget/controller tests for success, validation, loading, and API error states.

### Phase 2 - Dashboard and report navigation

- [x] Build reusable report-status badges and KPI values.
- [x] Implement the dashboard report list with pagination and status filters.
- [x] Derive counts from the existing list endpoint using four requests (all, pending, in progress, completed).
- [x] Add top-right profile navigation and the report-creation floating action button.
- [x] Navigate from each report to its detail page.

### Phase 3 - Report creation and location

- [x] Build the report form with required-field validation.
- [x] Add GPS capture, reverse geocoding, Google Maps point selection, and manual-address fallback.
- [x] Handle permission denial, location service failure, and geocoding failure.
- [ ] Configure and restrict the Maps platform key. Android reads `GOOGLE_MAPS_API_KEY` from `.env`; iOS requires an Xcode build setting. Map selection stays unavailable until a key is supplied.
- [x] Add image selection, preview, supported-format/5 MB validation, and multipart submission.
- [ ] Add tests for form validation, permissions/fallback behavior, coordinates, and upload failures/success.

### Phase 4 - Detail/history and API gaps

- [x] Implement report detail/history with status, admin notes, location, and submitted report data.
- [ ] Backend must add owner-authorized `PATCH /reports/{report}` and `DELETE /reports/{report}` mobile endpoints before Edit/Delete can succeed. UI actions are present and show API failures explicitly.
- [ ] Coordinate a supported public or authorized image URL/delivery contract; current `image_path` is only a storage path, not a usable absolute URL.
- [x] Document the current mobile API gaps in `API_DOCUMENTATION.md`; update implementation and tests when backend changes land.

### Phase 5 - Quality and release readiness

- [ ] Add unit, widget, and integration coverage for authentication, dashboard, report submission, detail/history, and navigation.
- [x] Add Indonesian loading, empty, validation, and API error states; manually review responsive scroll layouts.
- [ ] Run `flutter analyze`, relevant `flutter test` targets, and Android builds; verify no backend-private secrets are bundled or committed.
- [ ] Update [project_status.md](project_status.md) and refresh the Graphify map after each implementation batch.

## Acceptance criteria

- Every requested page is reachable through the documented flow and uses GetX routes/state rather than ad-hoc widget state.
- UI pieces follow atoms -> molecules -> organisms -> templates -> pages and are reused where appropriate.
- API requests use the `.env`-configured base URL, correct authentication, request formats, validation, and explicit error states.
- Report location can be obtained from GPS or selected on a map, with address fallback; permissions and unavailable services are handled.
- Image upload follows the documented file format and size limit.
- Status/history displays server-provided status and admin notes. Edit/Delete remain unavailable until the backend contract supports them.
- No production secret is hardcoded, logged, or committed. Tests and static analysis pass for each delivered phase.
