import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// StorageService — wraps Firebase Storage operations.
///
/// All uploads are scoped to the authenticated user's UID so
/// Firestore/Storage security rules can enforce ownership.
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ---------------------------------------------------------------------------
  // Profile photo upload
  // ---------------------------------------------------------------------------

  /// Opens the device gallery, lets the user pick an image, uploads it to
  /// Firebase Storage under `profile/{uid}/avatar.jpg`, and returns the
  /// public download URL.
  ///
  /// Returns an empty string if the user cancelled.
  /// Throws on upload failure.
  Future<String> uploadProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Not signed in');

    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return '';

    final bytes = await file.readAsBytes();
    return _uploadBytes(
      bytes: bytes,
      path: 'profile/${user.uid}/avatar.jpg',
      contentType: 'image/jpeg',
    );
  }

  // ---------------------------------------------------------------------------
  // Marketplace product image upload
  // ---------------------------------------------------------------------------

  /// Uploads [bytes] as a marketplace product image.
  /// Returns the public download URL.
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Not signed in');

    final ext = fileName.split('.').last.toLowerCase();
    final path =
        'products/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    return _uploadBytes(
      bytes: bytes,
      path: path,
      contentType: 'image/$ext',
    );
  }

  // ---------------------------------------------------------------------------
  // Community post image upload
  // ---------------------------------------------------------------------------

  /// Uploads [bytes] as a community post image.
  /// Returns the public download URL.
  Future<String> uploadPostImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Not signed in');

    final ext = fileName.split('.').last.toLowerCase();
    final path =
        'posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    return _uploadBytes(
      bytes: bytes,
      path: path,
      contentType: 'image/$ext',
    );
  }

  // ---------------------------------------------------------------------------
  // Private helper
  // ---------------------------------------------------------------------------

  Future<String> _uploadBytes({
    required Uint8List bytes,
    required String path,
    required String contentType,
  }) async {
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }
}
