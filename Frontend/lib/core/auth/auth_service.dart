import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// AuthService — wraps Firebase Phone Auth so no screen ever
/// touches FirebaseAuth.instance directly.
///
/// Flow:
///   1. MobileLoginScreen  → AuthService.sendOtp(phoneNumber)
///   2. OtpVerificationScreen → AuthService.verifyOtp(verificationId, smsCode)
///   3. SplashScreen       → AuthService.currentUser (null = not logged in)
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _log = Logger();

  // -------------------------------------------------------------------------
  // Current user
  // -------------------------------------------------------------------------

  /// Returns the currently signed-in user, or null if not authenticated.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes — listen in SplashScreen.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------------------------------------------------------
  // Step 1 — send OTP
  // -------------------------------------------------------------------------

  /// Sends a Firebase SMS OTP to [phoneNumber] (E.164 format, e.g. +919876543210).
  ///
  /// [onCodeSent]   — called with verificationId when SMS is dispatched.
  /// [onError]      — called with a human-readable message on any failure.
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String errorMessage) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),

        // Auto-verification on Android (SMS retriever / instant verify)
        verificationCompleted: (PhoneAuthCredential credential) async {
          _log.i('Auto-verification triggered');
          await _auth.signInWithCredential(credential);
          // Auth state stream will notify the UI automatically.
        },

        verificationFailed: (FirebaseAuthException e) {
          _log.e('OTP send failed: ${e.code} — ${e.message}');
          onError(_friendlyError(e.code));
        },

        codeSent: (String verificationId, int? resendToken) {
          _log.i('OTP sent to $phoneNumber');
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval window closed — user must type OTP manually.
          // No action needed; verificationId is already stored by codeSent.
          _log.d('Auto-retrieval timeout for $verificationId');
        },
      );
    } catch (e) {
      _log.e('Unexpected error in sendOtp: $e');
      onError('Something went wrong. Please try again.');
    }
  }

  // -------------------------------------------------------------------------
  // Step 2 — verify OTP
  // -------------------------------------------------------------------------

  /// Verifies [smsCode] against [verificationId] and signs the user in.
  ///
  /// Returns `null` on success (user is now signed in via [currentUser]).
  /// Returns an error message string on failure.
  Future<String?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      _log.i('User signed in: ${_auth.currentUser?.uid}');
      return null; // success
    } on FirebaseAuthException catch (e) {
      _log.w('OTP verification failed: ${e.code}');
      return _friendlyError(e.code);
    } catch (e) {
      _log.e('Unexpected error in verifyOtp: $e');
      return 'Verification failed. Please try again.';
    }
  }

  // -------------------------------------------------------------------------
  // Sign out
  // -------------------------------------------------------------------------

  Future<void> signOut() async {
    await _auth.signOut();
    _log.i('User signed out');
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Maps Firebase error codes to user-facing Hindi/English messages.
  /// Returns a single English string here; callers translate via l10n.
  String _friendlyError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'invalid-verification-code':
        return 'The OTP you entered is incorrect.';
      case 'session-expired':
        return 'The OTP has expired. Please request a new one.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}