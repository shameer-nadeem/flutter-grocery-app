# ShelfSight Final Submission

ShelfSight is a Firebase-backed retail shelf analysis app built with feature-wise Clean Architecture.

## What is completed

- Firebase initialization for Android and Web through `firebase_options.dart` / FlutterFire CLI.
- Firebase Authentication for email/password and Google sign-in.
- Firestore `users` collection for user/admin profiles.
- Firestore `scans` collection for shelf scan reports.
- Firebase Storage upload for device/gallery shelf images.
- Demo data seeding into Firebase after sign-in/sign-up using `assets/seed/shelfsight_seed_data.json`.
- Full scan CRUD:
  - Create: camera/gallery scan flow saves a new Firestore scan.
  - Read: home, dashboard, scan history, admin dashboard and detail screens stream Firestore data.
  - Update: edit scan title, metrics and recommendation from scan detail.
  - Delete: delete a scan from scan detail.
- Admin flow:
  - Admin dashboard shows all users and all scans.
  - Admin can change a registered user role between `user` and `admin` from Firestore-backed user records.
  - User flow shows only scans for the signed-in user.
- Provider state management.
- Loading and exception handling in auth, image picker, scan, Firestore stream, and admin role update flows.
- Responsive card grids for dashboard/admin/result metrics.
- Custom Android launcher icons and web app icons generated from `assets/icons/app_icon.png`.
- Platform-safe image rendering for Firebase URLs, packaged assets and local image paths.

## Demo login credentials

These demo accounts are auto-created in Firebase the first time you use them, then demo data is seeded into Firestore:

- Admin: `admin@shelfsight.com` / `admin123`
- User: `user@shelfsight.com` / `user123`

You can also sign up with a new user account from the app. New users are saved in Firebase and receive seeded scan data.

## Firestore collections used

### `users`

Each user document stores:

- `email`
- `name`
- `role`
- `scanAccuracy`
- `shiftsCompleted`
- `updatedAt`

### `scans`

Each scan document stores:

- `scanId`
- `userId`
- `userName`
- `userEmail`
- `title`
- `createdAt`
- `updatedAt`
- `imageUrl`
- `productCount`
- `sosPercentage`
- `osaPercentage`
- `compliancePercentage`
- `recommendation`

## Clean Architecture structure

Main source code is under `lib/features`:

```text
features/
  auth/
    data/
      datasources/
      models/
      repositories/
    domain/
      entities/
      repositories/
    presentation/
      providers/
      screens/
  scans/
    data/
      datasources/
      models/
      repositories/
    domain/
      entities/
      repositories/
    presentation/
      providers/
      screens/
  admin/
    data/
    domain/
    presentation/
  home/
    data/
    domain/
    presentation/
  profile/
    data/
    domain/
    presentation/
  splash/
    data/
    domain/
    presentation/
  support/
    data/
    domain/
    presentation/
```

Shared UI widgets are under `lib/presentation/widgets` and shared constants/utilities are under `lib/core`.

## How to connect and run

Follow `FIREBASE_CONNECT_AND_TEST.md` from the project root. Minimum run commands after Firebase is configured:

```bash
flutter clean
flutter pub get
flutter run
```

For Android, `android/app/google-services.json` must match your Firebase project. Firebase Auth, Firestore and Storage must be enabled in the Firebase console.

## Rubric checklist

See `SUBMISSION_CHECKLIST.md` for a one-page mapping of Clean Architecture, code quality, responsiveness, completeness, loading/error handling, Provider, and app icon coverage.

## Important grading note

The app no longer falls back to local mock repositories in the final flow. If Firebase is missing or configured incorrectly, the app shows a Firebase setup error screen instead of silently using local data. This is intentional so the final submission proves the backend is Firebase-connected.
