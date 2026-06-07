import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Neelam Nagar');
  final _phoneController = TextEditingController(text: '+91 XXXXXXXX');
  final _villageController = TextEditingController(text: 'Baran');

  Uint8List? _profileImageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        elevation: 1,
        title: Text(
          lang == 'en' ? 'Edit Profile' : 'प्रोफ़ाइल संपादित करें',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                  backgroundImage:
                      _profileImageBytes != null
                          ? MemoryImage(_profileImageBytes!)
                          : null,
                  child: _profileImageBytes == null
                      ? Icon(
                          Icons.person_outline,
                          size: 48,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    Icons.photo_camera_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    lang == 'en' ? 'Change Photo' : 'फोटो बदलें',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildField(
              label: lang == 'en' ? 'Full Name' : 'पूरा नाम',
              controller: _nameController,
            ),
            _buildField(
              label: lang == 'en' ? 'Phone Number' : 'मोबाइल नंबर',
              controller: _phoneController,
            ),
            _buildField(
              label: lang == 'en' ? 'Village / City' : 'गांव / शहर',
              controller: _villageController,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'phone': _phoneController.text,
                    'village': _villageController.text,
                  });
                },
                child: Text(
                  lang == 'en' ? 'Save Changes' : 'परिवर्तन सहेजें',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: label == 'Phone Number' || label == 'मोबाइल नंबर'
            ? TextInputType.phone
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
