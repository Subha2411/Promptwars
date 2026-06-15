import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for ArenaIQ.
/// Replace these placeholders with your actual Firebase project Web App credentials.
class FirebaseConfig {
  static const String apiKey = 'YOUR_API_KEY';
  static const String authDomain = 'YOUR_AUTH_DOMAIN';
  static const String projectId = 'YOUR_PROJECT_ID';
  static const String storageBucket = 'YOUR_STORAGE_BUCKET';
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';
  static const String appId = 'YOUR_APP_ID';

  /// Returns true if Firebase credentials have been configured.
  static bool get isConfigured =>
      apiKey != 'YOUR_API_KEY' &&
      projectId != 'YOUR_PROJECT_ID';

  /// Generates FirebaseOptions for initialisation.
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: apiKey,
      authDomain: authDomain,
      projectId: projectId,
      storageBucket: storageBucket,
      messagingSenderId: messagingSenderId,
      appId: appId,
    );
  }
}
