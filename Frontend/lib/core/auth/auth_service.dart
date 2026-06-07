import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

/// AuthService — Google Sign-In (no billing required, 100% free)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _log = Logger();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with Google. Returns null on success, error message on failure.
  Future<String?> signInWithGoogle() async {
    try {
      // google_sign_in v7 API
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return 'Sign-in cancelled';

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // v7: uses serverAuthCode or idToken only (no accessToken)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _log.i('Google sign-in success: ${_auth.currentUser?.email}');
      return null;
    } catch (e) {
      _log.e('Google sign-in error: $e');
      return 'Sign-in failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await _auth.signOut();
    _log.i('User signed out');
  }
}
