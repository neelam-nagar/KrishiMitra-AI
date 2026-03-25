import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';

class CommentTile extends StatelessWidget {
  /// comment text
  final String comment;

  /// username of commenter
  final String userName;

  /// time label like "2 min ago"
  final String timeAgo;

  /// whether current user can delete this comment
  final bool canDelete;

  /// delete callback
  final VoidCallback? onDelete;

  /// reply callback
  final VoidCallback? onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.userName = 'User',
    this.timeAgo = '',
    this.canDelete = false,
    this.onDelete,
    this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final bool isHindi = lang == 'hi';
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 6, right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER: username + time + delete
          Row(
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (timeAgo.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  '• $timeAgo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              const Spacer(),
              if (canDelete)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(isHindi ? 'कमेंट हटाएं' : 'Delete Comment'),
                        content: Text(
                          isHindi
                              ? 'क्या आप वाकई इस कमेंट को हटाना चाहते हैं?'
                              : 'Are you sure you want to delete this comment?',
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
                              onDelete?.call();
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

          const SizedBox(height: 2),

          /// COMMENT TEXT
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          /// REPLY ACTION
          if (onReply != null)
            GestureDetector(
              onTap: onReply,
              child: Text(
                isHindi ? 'जवाब दें' : 'Reply',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}