import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

/// FirestoreService — all Firestore reads/writes for the community feed.
///
/// Username is always sourced from the currently authenticated Firebase user.
/// No string is ever hardcoded here.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _log = Logger();

  // ---------------------------------------------------------------------------
  // Posts — write
  // ---------------------------------------------------------------------------

  /// Adds a new post to the 'posts' collection.
  ///
  /// [message]   — text body (may be empty if [imageBytes] is provided).
  /// [imageBytes]— optional image bytes (JPEG/PNG).
  /// [fileName]  — original file name, used to derive the Storage path.
  ///
  /// Throws [StateError] if no user is signed in.
  Future<void> addPost({
    required String message,
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Cannot post: user is not signed in.');

    if (message.trim().isEmpty && imageBytes == null) {
      _log.d('addPost called with empty message and no image — skipping.');
      return;
    }

    String? imageUrl;

    // Upload image to Firebase Storage first (if provided)
    if (imageBytes != null && fileName != null) {
      imageUrl = await _uploadImage(imageBytes, fileName, user.uid);
    }

    // Use displayName if set, fall back to phone number, then UID
    final username = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.phoneNumber ?? user.uid;

    await _db.collection('posts').add({
      'message': message.trim(),
      'username': username,
      'userId': user.uid,
      'imageUrl': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });

    _log.i('Post added by $username (${user.uid})');
  }

  // ---------------------------------------------------------------------------
  // Posts — read (paginated stream)
  // ---------------------------------------------------------------------------

  /// Returns a paginated stream of the latest [limit] posts, newest first.
  Stream<List<Map<String, dynamic>>> postsStream({int limit = 20}) {
    return _db
        .collection('posts')
        .orderBy('time', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // ---------------------------------------------------------------------------
  // Posts — delete (owner only)
  // ---------------------------------------------------------------------------

  /// Deletes a post document. Firestore security rules enforce ownership;
  /// this client-side check is just an extra guard.
  Future<void> deletePost(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Not signed in.');

    final doc = await _db.collection('posts').doc(postId).get();
    if (doc.data()?['userId'] != user.uid) {
      throw StateError('Cannot delete a post you do not own.');
    }

    await _db.collection('posts').doc(postId).delete();
    _log.i('Post $postId deleted by ${user.uid}');
  }

  // ---------------------------------------------------------------------------
  // Image upload
  // ---------------------------------------------------------------------------

  Future<String> _uploadImage(
      Uint8List bytes, String fileName, String userId) async {
    final ext = fileName.split('.').last;
    final path =
        'posts/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref().child(path);
    await ref.putData(bytes, SettableMetadata(contentType: 'image/$ext'));
    return await ref.getDownloadURL();
  }
}