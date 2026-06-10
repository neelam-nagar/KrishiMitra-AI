// KrishMitra AI — Flutter Camera Integration
// crop_disease_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

const String API_URL = 'https://crop-disease-vo0y.onrender.com';

class CropDiseaseScreen extends StatefulWidget {
  @override
  _CropDiseaseScreenState createState() => _CropDiseaseScreenState();
}

class _CropDiseaseScreenState extends State<CropDiseaseScreen> {
  File? _image;
  bool _loading = false;
  Map<String, dynamic>? _result;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        _result = null;
      });
      await _predict();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() {
        _image = File(photo.path);
        _result = null;
      });
      await _predict();
    }
  }

  Future<void> _predict() async {
    if (_image == null) return;

    setState(() => _loading = true);

    try {
      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$API_URL/predict-base64'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      ).timeout(
        Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Server slow hai, dobara try karo!');
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF2E7D32),
        title: Text(
          '🌾 KrishMitra AI',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Fasal Bimari Detector',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF2E7D32), width: 2),
              ),
              child: _image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, size: 64, color: Color(0xFF2E7D32)),
                        SizedBox(height: 8),
                        Text(
                          'Patti ki photo lo',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    ),
            ),

            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('Camera', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    label: Text('Gallery', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF388E3C),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            if (_loading)
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    SizedBox(height: 12),
                    Text('Bimari dhundh raha hoon...'),
                    SizedBox(height: 4),
                    Text(
                      '(Pehli baar 30-60 sec lag sakte hain)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

            if (_result != null) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    bool isHealthy = _result!['is_healthy'] ?? false;
    List pesticides = _result!['pesticides'] ?? [];
    List helplines = _result!['helpline'] ?? [];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHealthy ? Color(0xFFE8F5E9) : Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHealthy ? Color(0xFF2E7D32) : Color(0xFFFF6F00),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHealthy ? '✅ Fasal Swasth Hai!' : '⚠️ Bimari Mili!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isHealthy ? Color(0xFF2E7D32) : Color(0xFFFF6F00),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '🌿 ${_result!['hindi']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text('📊 Confidence: ${_result!['confidence']}%'),
              Text('⚠️ Severity: ${_result!['severity']}'),
            ],
          ),
        ),

        SizedBox(height: 12),

        if (pesticides.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💊 Dawai (Pesticide):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...pesticides.map((p) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ${p['naam']}', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('  Matra: ${p['matra']}'),
                      Text('  Kimat: ${p['kimat']}'),
                    ],
                  ),
                )).toList(),
                SizedBox(height: 8),
                Text('⏰ Spray: ${_result!['spray']}'),
                SizedBox(height: 4),
                Text('⚠️ Savdhani: ${_result!['savdhani']}'),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFF1565C0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📞 Helpline Numbers:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              SizedBox(height: 8),
              ...helplines.map((h) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Color(0xFF1565C0)),
                    SizedBox(width: 8),
                    Text('${h['naam']}: '),
                    Text(
                      '${h['number']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Color(0xFF1565C0)),
                  SizedBox(width: 8),
                  Text('Kisan Call Center (Free 24/7): '),
                  Text(
                    '1800-180-1551',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}