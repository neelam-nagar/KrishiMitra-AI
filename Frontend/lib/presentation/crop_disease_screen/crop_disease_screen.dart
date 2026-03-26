import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CropDiseaseScreen extends StatefulWidget {
  const CropDiseaseScreen({super.key});

  @override
  State<CropDiseaseScreen> createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
  File? _image;
  String result = "";

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> detectDisease() async {
    if (_image == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://127.0.0.1:5001/predict"),
    );

    request.files.add(
      await http.MultipartFile.fromPath('image', _image!.path),
    );

    var response = await request.send();
    var res = await response.stream.bytesToString();
    var data = json.decode(res);

    setState(() {
      result = "Disease: ${data['disease']}\nMedicine: ${data['pesticide']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crop Disease Detection")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No Image Selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Capture Image"),
            ),
            ElevatedButton(
              onPressed: detectDisease,
              child: const Text("Detect Disease"),
            ),
            const SizedBox(height: 20),
            Text(result),
          ],
        ),
      ),
    );
  }
}