import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../services/firestore_service.dart';
import '../../core/language_provider.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/app_export.dart';

/// Community Chat Screen.
///
/// - Reads posts from Firestore via FirestoreService.postsStream() (paginated, 20 at a time).
/// - Writes posts via FirestoreService.instance.addPost() — username comes from
///   FirebaseAuth.currentUser, never hardcoded.
/// - Image uploads go through FirestoreService, not directly to FirebaseStorage.
class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({super.key});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final Logger _log = Logger();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isPosting = false;

  bool get _isHindi =>
      context.watch<LanguageProvider>().currentLanguage == 'hi';

  // ---------------------------------------------------------------------------
  // Image picker
  // ---------------------------------------------------------------------------

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = file.name;
    });
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(_isHindi ? 'कैमरा' : 'Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(_isHindi ? 'गैलरी' : 'Gallery'),
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

  // ---------------------------------------------------------------------------
  // Post
  // ---------------------------------------------------------------------------

  Future<void> _addPost() async {
    final message = _postController.text.trim();
    if (message.isEmpty && _selectedImageBytes == null) return;

    setState(() => _isPosting = true);

    try {
      await FirestoreService.instance.addPost(
        message: message,
        imageBytes: _selectedImageBytes,
        fileName: _selectedImageName,
      );
      _postController.clear();
      setState(() {
        _selectedImageBytes = null;
        _selectedImageName = null;
      });
    } catch (e) {
      _log.e('Failed to post: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isHindi ? 'पोस्ट नहीं हो सका' : 'Could not post. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Dispose
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isHindi ? 'समुदाय' : 'Community'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Column(
        children: [
          _buildComposer(),
          Expanded(child: _buildFeed()),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentItem: CustomBottomBarItem.community,
        onItemTapped: (item) {
          switch (item) {
            case CustomBottomBarItem.dashboard:
              Navigator.pushReplacementNamed(context, AppRoutes.mainDashboard);
            case CustomBottomBarItem.marketplace:
              Navigator.pushReplacementNamed(context, AppRoutes.marketplace);
            case CustomBottomBarItem.community:
              break;
            case CustomBottomBarItem.chatbot:
              Navigator.pushReplacementNamed(context, AppRoutes.aiChatbot);
            case CustomBottomBarItem.profile:
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Composer widget
  // ---------------------------------------------------------------------------

  Widget _buildComposer() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _postController,
            decoration: InputDecoration(
              hintText: _isHindi
                  ? 'सवाल पूछें या जानकारी साझा करें...'
                  : 'Ask a question or share info...',
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                tooltip: _isHindi ? 'तस्वीर जोड़ें' : 'Add image',
                onPressed: _showImagePickerSheet,
              ),
              if (_selectedImageBytes != null)
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Color(0xFF2E7D32), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _isHindi ? 'तस्वीर चुनी गई' : 'Image selected',
                      style: const TextStyle(fontSize: 12),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      tooltip: _isHindi ? 'हटाएं' : 'Remove',
                      onPressed: () => setState(() {
                        _selectedImageBytes = null;
                        _selectedImageName = null;
                      }),
                    ),
                  ],
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isPosting ? null : _addPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: _isPosting
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.send, size: 16),
                        const SizedBox(width: 6),
                        Text(_isHindi ? 'पोस्ट करें' : 'Post'),
                      ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Feed — paginated Firestore stream
  // ---------------------------------------------------------------------------

  Widget _buildFeed() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.instance.postsStream(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          _log.e('Feed error: ${snapshot.error}');
          return Center(
            child: Text(
              _isHindi ? 'पोस्ट लोड नहीं हो सकीं' : 'Could not load posts',
            ),
          );
        }

        final posts = snapshot.data ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Text(_isHindi ? 'अभी कोई पोस्ट नहीं है' : 'No posts yet'),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index];
            return _PostCard(data: data);
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Post card widget (extracted to keep build() clean)
// ---------------------------------------------------------------------------

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PostCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            if ((data['message'] as String?)?.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(data['message'] as String),
            ],
            if (data['imageUrl'] != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  data['imageUrl'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}