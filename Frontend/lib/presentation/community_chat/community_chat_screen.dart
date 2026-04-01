import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
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
  final FirestoreService _firestoreService = FirestoreService();

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

  Future<void> _addPost() async {
    print("Post button clicked 🔥");

    final message = _postController.text.trim();

    if (message.isEmpty && _selectedImage == null) {
      print("Nothing to post ❌");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'message': message,
        'username': 'Neelam', // temporary (later from auth)
        'time': FieldValue.serverTimestamp(),
      });

      _postController.clear();
      setState(() {
        _selectedImage = null;
      });
    } catch (e) {
      print("Error posting: $e");
    }
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
  void dispose() {
    _postController.dispose();
    super.dispose();
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
                  onSubmitted: (value) => _addPost(),
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
                    SizedBox(
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _addPost,
                        icon: const Icon(Icons.send),
                        label: Text(isHindi ? 'पोस्ट करें' : 'Post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          minimumSize: const Size(100, 45),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          /// 🧵 Posts feed
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(isHindi ? 'अभी कोई पोस्ट नहीं है' : 'No posts yet'),
                  );
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final doc = posts[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['username'] ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(data['message'] ?? ''),
                          ],
                        ),
                      ),
                    );
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