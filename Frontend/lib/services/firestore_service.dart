import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addPost(String message) async {
    if (message.trim().isEmpty) return;

    await _db.collection('posts').add({
      'message': message,
      'username': 'Neelam', // temporary username
      'time': Timestamp.now(),
    });
  }
}
