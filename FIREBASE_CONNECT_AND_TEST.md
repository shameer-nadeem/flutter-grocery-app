# ShelfSight Firebase Connect + Testing Guide

This project is Firebase-required for final submission. It does not use local mock repositories in the real app flow.

## 1) Create/prepare Firebase project

In Firebase Console:

1. Create a Firebase project, or open your existing ShelfSight project.
2. Enable **Authentication**:
   - Go to Authentication > Sign-in method.
   - Enable **Email/Password**.
   - Optional: enable **Google** if you want Google Sign-In to work.
3. Enable **Cloud Firestore**:
   - Go to Firestore Database.
   - Create database.
   - Choose a region close to you.
4. Enable **Firebase Storage**:
   - Go to Storage.
   - Create default bucket.

## 2) Install Firebase tools on your laptop

Run these once:

```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
```

If `flutterfire` is not recognized on Windows, add this to your PATH:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

Then close/reopen VS Code or CMD.

## 3) Connect this Flutter project to your Firebase project

From the project root folder, run:

```bash
flutter pub get
flutterfire configure --project=shelfsight-e4f1f --platforms=android,web
```

Use this Android package name when FlutterFire asks for an Android app:

```text
com.shelfsight.app
```

This command should update/generate:

```text
lib/firebase_options.dart
android/app/google-services.json (generated/replaced by FlutterFire)
```

## 4) Deploy demo/grading rules

From the project root:

```bash
firebase use --add
firebase deploy --only firestore:rules,storage
```

Select the same Firebase project you used in `flutterfire configure`.

## 5) Run and seed Firebase dummy data

Run the app:

```bash
flutter clean
flutter pub get
flutter run
```

Then log in with:

```text
Admin: admin@shelfsight.com / admin123
User: user@shelfsight.com / user123
```

The first login creates the Auth account if it does not already exist, writes the profile to `users`, and seeds real dummy scan documents into the Firestore `scans` collection.

## 6) Final testing checklist

### Authentication

- Open app.
- Login using `admin@shelfsight.com / admin123`.
- Logout.
- Login using `user@shelfsight.com / user123`.
- Sign up with a new email and password.
- Check Firebase Console > Authentication > Users.

### Firestore data

- Check Firebase Console > Firestore Database.
- Confirm collections exist:
  - `users`
  - `scans`
- Confirm documents are created after login/sign-up.

### Scan CRUD

- Login as a normal user.
- Pick image from gallery or camera.
- Enter aisle name.
- Save/analyze scan.
- Confirm a new document appears in Firestore `scans`.
- Open scan detail.
- Edit scan title/metrics/recommendation.
- Confirm Firestore document updates.
- Delete scan.
- Confirm Firestore document deletes.

### Admin dashboard

- Login as admin.
- Confirm admin screen shows all users and all scans.
- Open a scan detail.
- Confirm edit/delete works.

### Storage

- Save a scan using a picked camera/gallery image.
- Check Firebase Console > Storage.
- Confirm image file appears under `scans/`.

## 7) Common errors and fixes

### Firebase options are not configured

Run:

```bash
flutterfire configure --project=shelfsight-e4f1f --platforms=android,web
```

### Permission denied in Firestore or Storage

Deploy rules:

```bash
firebase deploy --only firestore:rules,storage
```

Or paste `firestore.rules` and `storage.rules` manually in Firebase Console.

### Google Sign-In does not work

For final grading, Email/Password login is enough. If you still want Google login:

1. Enable Google provider in Firebase Authentication.
2. Add SHA-1 and SHA-256 fingerprints in Firebase project settings.
3. Download/regenerate `google-services.json` or rerun `flutterfire configure`.

### App stuck after old build

Run:

```bash
flutter clean
flutter pub get
flutter run
```
