import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import 'post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController _commentController = TextEditingController();
  bool showCommentBox = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// USER NAME + DELETE
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.post.userName,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.post.canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(isHindi ? 'पोस्ट हटाएं' : 'Delete Post'),
                          content: Text(
                            isHindi
                                ? 'क्या आप वाकई इस पोस्ट को हटाना चाहते हैं? यह क्रिया वापस नहीं होगी।'
                                : 'Are you sure you want to delete this post? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onDelete?.call();
                              },
                              child: Text(isHindi ? 'हटाएं' : 'Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),

            const SizedBox(height: 6),

            /// POST TEXT
            Text(widget.post.text),

            /// IMAGE (optional)
            if (widget.post.imagePath != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.post.imagePath!.startsWith('http') ||
                        widget.post.imagePath!.startsWith('blob')
                    ? Image.network(widget.post.imagePath!)
                    : Image.file(File(widget.post.imagePath!)),
              ),
            ],

            const SizedBox(height: 12),

            /// ACTION ROW
            Row(
              children: [
                /// LIKE
                IconButton(
                  icon: Icon(
                    widget.post.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.post.isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.post.toggleLike();
                    });
                  },
                ),
                Text('${widget.post.likeCount}'),

                const SizedBox(width: 16),

                /// COMMENT
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    setState(() {
                      showCommentBox = !showCommentBox;
                    });
                  },
                ),
                Text('${widget.post.comments.length}'),

                const Spacer(),

                /// SHARE
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    Share.share(
                      widget.post.text,
                    );
                  },
                ),
              ],
            ),

            /// COMMENT INPUT
            if (showCommentBox) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: isHindi ? 'कमेंट लिखें...' : 'Write a comment...',
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.trim().isEmpty) return;
                      setState(() {
                        widget.post
                            .addComment(_commentController.text.trim());
                        _commentController.clear();
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// COMMENT LIST
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.post.comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${widget.post.comments[index]}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}