import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for ArenaIQ.
/// Replace these placeholders with your actual Firebase project Web App credentials.
class FirebaseConfig {
  static const String apiKey = 'AIzaSyDgX2CKzQxsGvv6xPgo97sQ4cvJB4QmAVc';
  static const String authDomain = 'project-crowd-ass.firebaseapp.com';
  static const String projectId = 'project-crowd-ass';
  static const String storageBucket = 'project-crowd-ass.firebasestorage.app';
  static const String messagingSenderId = '498205245011';
  static const String appId = '1:498205245011:android:29883c93782a036afb90a6';

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
