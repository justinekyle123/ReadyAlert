import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'cloud_alert_sync.dart';

/// Starts Firebase for the `emergencyapp-9a75f` project.
///
/// The defaults below are the project's public Web app config, so a plain
/// `flutter run` connects to Firestore with no extra flags. A Firebase Web API
/// key identifies the project and is shipped with every web client; access is
/// controlled by Firestore security rules, not by hiding it.
///
/// Any value can still be overridden at build or run time, for example:
///
/// ```sh
/// flutter run -d chrome \
///   --dart-define=FIREBASE_API_KEY=... \
///   --dart-define=FIREBASE_APP_ID=... \
///   --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
///   --dart-define=FIREBASE_PROJECT_ID=...
/// ```
///
/// If the config is blanked out, the app runs local-only and no network call is
/// attempted.
class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static const String _defaultApiKey =
      'AIzaSyDMdYmEX-RA9JClDq1TSo2N3fGT05PmCiE';
  static const String _defaultAppId = '1:614269476749:web:da285cefdc55390b1e67c4';
  static const String _defaultMessagingSenderId = '614269476749';
  static const String _defaultProjectId = 'emergencyapp-9a75f';
  static const String _defaultAuthDomain =
      'emergencyapp-9a75f.firebaseapp.com';
  static const String _defaultStorageBucket =
      'emergencyapp-9a75f.firebasestorage.app';

  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: _defaultApiKey,
  );
  static const String _appId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: _defaultAppId,
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: _defaultMessagingSenderId,
  );
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: _defaultProjectId,
  );
  static const String _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: _defaultAuthDomain,
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: _defaultStorageBucket,
  );
  static const String _measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
  );

  static bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty;

  /// Returns true when Firebase initialized and online alert sync is on.
  static Future<bool> initialize() async {
    if (!isConfigured) {
      debugPrint(
        'Firebase is not configured; Ready Alert stays local-only. '
        'Pass FIREBASE_* dart-defines to enable online alerts.',
      );
      return false;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: _apiKey,
            appId: _appId,
            messagingSenderId: _messagingSenderId,
            projectId: _projectId,
            authDomain: _authDomain.isEmpty
                ? '$_projectId.firebaseapp.com'
                : _authDomain,
            storageBucket: _storageBucket.isEmpty
                ? '$_projectId.firebasestorage.app'
                : _storageBucket,
            measurementId: _measurementId.isEmpty ? null : _measurementId,
          ),
        );
      }
      CloudAlertSync.instance.enable();
      debugPrint('Firebase connected: online tri-alarm sync is active.');
      return true;
    } on Object catch (error, stack) {
      CloudAlertSync.instance.disable();
      debugPrint('Firebase initialization failed: $error\n$stack');
      return false;
    }
  }
}
