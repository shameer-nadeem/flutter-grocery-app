# ShelfSight Submission Checklist

This version is prepared for Mobile Computing final submission and keeps the existing Firebase/Firestore connection.

## Rubric coverage

| Requirement | Status in this project |
|---|---|
| Clean Architecture Folder Structure | Implemented using feature folders with `data`, `domain`, and `presentation` layers. |
| Code Quality | Repository pattern, domain entities, providers, reusable widgets, constants, and platform-safe image helpers are used. |
| Responsiveness | Main cards and metrics use responsive grids and scrollable screens to avoid overflow on smaller phones. |
| Completeness | User login/signup, Google login, camera/gallery scan flow, Firestore scan saving, history, detail/edit/delete scan, admin dashboard, all users, all scans, and admin role update are included. |
| Loading Indicators | Auth, image picking, analysis, dashboards, scan history, and admin loading states show progress indicators. |
| Exception Handling | Auth, Firestore streams, image picker, scan save/update/delete, password reset, and admin role update show user-friendly error states/snackbars. |
| Provider | `AuthProvider`, `ShelfAnalysisProvider`, and `ThemeProvider` are registered in `MultiProvider`. |
| App Icon | Android launcher icons and web icons are generated from `assets/icons/app_icon.png`. |

## Firebase collections

- `users`: stores `email`, `name`, `role`, `scanAccuracy`, `shiftsCompleted`, and `updatedAt`.
- `scans`: stores scan image URL/path, user info, product count, shelf metrics, compliance, recommendation, and timestamps.

## Demo accounts

- Admin: `admin@shelfsight.com` / `admin123`
- User: `user@shelfsight.com` / `user123`

These accounts are created in Firebase automatically the first time they are used, if they do not already exist.

## Final run commands

```bash
flutter clean
flutter pub get
flutter run
```

For Android Google sign-in, make sure the Firebase Android app has the correct package name `com.shelfsight.app` and the required SHA fingerprints in Firebase/Google Cloud Console.
