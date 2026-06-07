import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/language_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _villageController;
  Uint8List? _profileImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _villageController = TextEditingController();
    _loadSavedVillage();
  }

  Future<void> _loadSavedVillage() async {
    final prefs = await SharedPreferences.getInstance();
    final village = prefs.getString('profile_village') ?? '';
    if (mounted) {
      _villageController.text = village;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _profileImageBytes = bytes);
    }
  }

  Future<void> _saveProfile() async {
    final lang = context.read<LanguageProvider>().currentLanguage;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final name = _nameController.text.trim();

      if (name.isNotEmpty && user != null) {
        await user.updateDisplayName(name);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', name);
      await prefs.setString('profile_village', _villageController.text.trim());

      if (!mounted) return;
      Navigator.pop(context, {
        'name': name,
        'location': _villageController.text.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(lang == 'en'
            ? 'Failed to save profile. Please try again.'
            : 'प्रोफ़ाइल सहेजने में विफल। पुनः प्रयास करें।'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final user = FirebaseAuth.instance.currentUser;

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
            // Avatar
            Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  backgroundImage: _profileImageBytes != null
                      ? MemoryImage(_profileImageBytes!)
                      : null,
                  child: _profileImageBytes == null
                      ? Icon(Icons.person_outline,
                          size: 48, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo_camera_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  label: Text(
                    lang == 'en' ? 'Change Photo' : 'फोटो बदलें',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name field
            _buildField(
              label: lang == 'en' ? 'Full Name' : 'पूरा नाम',
              controller: _nameController,
              keyboardType: TextInputType.name,
            ),

            // Phone — read-only from Firebase Auth
            TextFormField(
              initialValue: user?.phoneNumber ?? '',
              readOnly: true,
              decoration: InputDecoration(
                labelText: lang == 'en' ? 'Phone Number' : 'मोबाइल नंबर',
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                suffixIcon: const Icon(Icons.lock_outline, size: 18),
                helperText: lang == 'en'
                    ? 'Phone cannot be changed'
                    : 'मोबाइल नंबर नहीं बदला जा सकता',
              ),
            ),
            const SizedBox(height: 16),

            // Village field
            _buildField(
              label: lang == 'en' ? 'Village / City' : 'गांव / शहर',
              controller: _villageController,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
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
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
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
