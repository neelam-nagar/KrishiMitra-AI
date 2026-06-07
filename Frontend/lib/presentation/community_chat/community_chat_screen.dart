import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';
import 'post_model.dart';
import 'post_card.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({super.key});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  bool get isHindi {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return lang == 'hi';
  }
  final TextEditingController _postController = TextEditingController();

  final List<PostModel> _posts = [];
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  /// 📷 Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// ➕ Add post
  void _addPost() {
    if (_postController.text.trim().isEmpty && _selectedImage == null) return;

    setState(() {
      _posts.insert(
        0,
        PostModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userName: 'Neelam',
          text: _postController.text.trim(),
          imagePath: _selectedImage?.path,
          isOwner: true,
        ),
      );
      _postController.clear();
      _selectedImage = null;
    });
  }

  /// 📸 Image picker bottom sheet
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(isHindi ? 'कैमरा' : 'Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(isHindi ? 'गैलरी' : 'Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'समुदाय' : 'Community'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          /// 📝 Create post box
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _postController,
                  decoration: InputDecoration(
                    hintText: isHindi
                        ? 'सवाल पूछें या जानकारी साझा करें...'
                        : 'Ask a question or share info...',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image),
                      onPressed: _showImagePicker,
                    ),
                    if (_selectedImage != null)
                      Text(isHindi ? 'तस्वीर चुनी गई' : 'Image selected'),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _addPost,
                      icon: const Icon(Icons.send),
                      label: Text(isHindi ? 'पोस्ट करें' : 'Post'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🧵 Posts feed
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
                  post: post,
                  onDelete: () {
                    setState(() {
                      _posts.removeAt(index);
                    });
                  },
                );
              },
            ),
          ),
        ],
      )
      ,
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.community,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
              break;

            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
              break;

            case CustomBottomBarItem.community:
              // already here
              break;

            case CustomBottomBarItem.chatbot:
              Navigator.pushReplacementNamed(context, AppRoutes.aiChatbot);
              break;

            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
              break;
          }
        },
      )
    );
  }
}