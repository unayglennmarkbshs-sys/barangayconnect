# BarangayConnect

Community Services and Information Mobile Application
Flutter (Android APK) + Node.js/Express REST API + MySQL + JWT

Built from: proposal2.pdf and SYSTEM DESIGN DOCUMENT (1).docx

## Project structure

    barangayconnect/
    ├── backend/              Node.js + Express REST API
    │   ├── src/routes/       auth, users, announcements, events, requests,
    │   │                     concerns, notifications, emergency-contacts, reports
    │   ├── src/middleware/   JWT auth + admin guard
    │   ├── database/         schema.sql (9 tables) and seed.sql
    │   ├── scripts_create_admin.js   creates the default admin account
    │   └── .env.example      copy to .env and edit
    └── mobile/               Flutter app (resident + admin in one APK)

## Part 1: Set up the backend

Requirements: Node.js 18+ and MySQL (XAMPP/MariaDB works fine).

    cd backend
    npm install
    cp .env.example .env        (Windows: copy .env.example .env)
    # Edit .env: set DB_PASSWORD and a long random JWT_SECRET

    # Create the database and tables:
    mysql -u root -p < database/schema.sql
    mysql -u root -p < database/seed.sql
    # (With XAMPP you can also import schema.sql/seed.sql via phpMyAdmin)

    # Create the default admin account:
    node scripts_create_admin.js

    # Start the API:
    npm start
    # You should see: BarangayConnect API listening on port 3000

Test it: open http://localhost:3000/ in a browser.
Default admin: admin@barangay.com / admin123 (change the password!).

## Part 2: Set up the Flutter app and build the APK

Requirements: Flutter SDK 3.x, Android SDK (install "Flutter" and "Dart"
plugins if using VS Code / Android Studio).

    cd mobile
    flutter pub get

IMPORTANT: regenerate the full android/ folder (this repo only contains the
AndroidManifest.xml you need):

    flutter create --platforms=android .

    # Overwrite the generated manifest with ours (it already has INTERNET and
    # CAMERA permissions):
    #   keep android/app/src/main/AndroidManifest.xml from this project

Set the API URL in lib/config.dart:

    // Android Emulator (API on the same computer):
    const String kBaseUrl = 'http://10.0.2.2:3000';

    // Real phone on the same Wi-Fi (use your computer's LAN IP - run
    // "ipconfig" on Windows and look for IPv4 Address):
    const String kBaseUrl = 'http://192.168.1.10:3000';

Run in debug mode first:

    flutter run

Then build the APK:

    flutter build apk --release

The APK appears at:
    mobile/build/app/outputs/flutter-apk/app-release.apk

Copy that APK to an Android phone and install it (allow "install from
unknown sources" when prompted).

## Troubleshooting

- App shows "Could not load feed" -> the phone cannot reach the API.
  Same Wi-Fi? Correct IP in lib/config.dart? Windows firewall blocking
  Node.js? Try temporarily disabling the firewall to test.
- `flutter: command not found` -> add Flutter's bin folder to PATH.
- Gradle errors on first build -> accept the Android SDK licenses:
  flutter doctor --android-licenses
- If you changed backend port, update .env PORT and kBaseUrl.

## Notes on scope (from the proposal)

Implemented: registration/login (JWT, role-based), announcements + events
feed, service request submission and tracking with status timeline, concern
reporting with photo attachment, notifications, emergency directory with
call buttons, profile management, admin dashboard with summary counts,
admin user/announcement/request/concern/directory management.

Deliberately NOT implemented (per proposal "Out of Scope"): online payments,
SMS gateway, iOS deployment, biometrics, national database integration.
Notifications are in-app polling (no Firebase setup required); you can add
Firebase Cloud Messaging later for true push notifications.
