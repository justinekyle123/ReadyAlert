# Ready Alert

Ready Alert keeps a school's earthquake readiness roster, tri-alarm broadcasts
and readiness skills. It is local-first: accounts, groups, alerts and each
account's skills live in a local SQLite database (`ready_alert.db`), so the app
works with no network. Firebase can be turned on to make tri-alarm broadcasts
reach other devices.

## Roles

| Role | Can do |
| --- | --- |
| **Host** | Create, assign and edit groups and users; broadcast tri-alarms to every group. |
| **Youth volunteer leader** | Send tri-alarm alerts to the one group they lead. |
| **Member** | Receive their group leader's alerts; mute the siren or stop an alert on their own account. |

Host-only roster rules are enforced in `RosterRepository`, not just hidden in
the UI, so a leader or member cannot create or edit accounts and groups even if
a screen is bypassed.

## Demo accounts

Every seeded account uses the password **`ready123`**. Sign in with the school
ID or the matching email.

| Role | School ID |
| --- | --- |
| Host | `juan.delacruz` |
| Leaders | `maria.santos`, `jose.reyes`, `ana.cruz`, `mark.lim` |
| Members | e.g. `andrea.bautista`, `miguel.castro`, `victor.pascual` |

The full account directory, grouped by role and roster, plus a test checklist
for login, alerts, mute/stop and editing lives in **[USERS.md](USERS.md)**.

## Online alerts with Firebase

The app already depends on `firebase_core` and `cloud_firestore`. Firebase turns
on automatically for the `emergencyapp-9a75f` project: its public Web app config
is the default in `lib/core/firebase/firebase_bootstrap.dart`, and no
`google-services.json` is needed because initialization is Dart-only.

1. In the Firebase console, open the `emergencyapp-9a75f` project and make sure
   **Cloud Firestore** is created.
2. Just run the app — the config is already baked in:

   ```sh
   flutter run -d chrome
   ```

3. To point the app at a different project (or to keep credentials out of the
   source), override any value with `--dart-define`, for example:

   ```sh
   flutter run -d chrome \
     --dart-define=FIREBASE_API_KEY=your-api-key \
     --dart-define=FIREBASE_APP_ID=your-app-id \
     --dart-define=FIREBASE_MESSAGING_SENDER_ID=your-sender-id \
     --dart-define=FIREBASE_PROJECT_ID=your-project-id
   ```

   Optional values: `FIREBASE_AUTH_DOMAIN`, `FIREBASE_STORAGE_BUCKET`,
   `FIREBASE_MEASUREMENT_ID`.

4. For production builds, the same defaults apply, so
   `flutter build web --release` also connects. `Settings → Online alerts` shows
   whether sync is active.

What syncs:

- Every broadcast is written to the Firestore `alerts` collection with its
  level, title, detail, sender, optional group name, `occurredAt` and
  `endedAt`.
- Each signed-in device watches the 50 most recent alerts. New alerts for the
  account's group (or every group for the host) are imported into SQLite; a
  sender ending an alert closes it on every device.
- Member stops are private: they are stored in the local `alert_dismissals`
  table and never end the alert for the rest of the group.
- Accounts, password hashes, groups and skills are **not** uploaded. The roster
  remains on the device.

Firestore is opened for client reads and writes in this demo. Before using real
student data, add Firebase Authentication and security rules that restrict the
`alerts` collection, for example allowing reads for signed-in school members and
writes only for host/leader claims.

## Project checks

```sh
flutter analyze
flutter test
```

## Getting started

This project is a Flutter application. A few resources if this is your first
Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
