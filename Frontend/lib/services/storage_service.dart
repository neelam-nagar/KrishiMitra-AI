import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return '';

  File file = File(pickedFile.path);

  final ref = FirebaseStorage.instance
      .ref()
      .child('products/${DateTime.now().millisecondsSinceEpoch}.jpg');

  await ref.putFile(file);

  return await ref.getDownloadURL();
}