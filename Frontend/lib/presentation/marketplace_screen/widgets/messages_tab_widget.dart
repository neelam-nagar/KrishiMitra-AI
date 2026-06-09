import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import 'chat_screen.dart';

/// Drop-in replacement for _buildMessagesTab() content
/// Shows all chats for the current user
class MessagesTabWidget extends StatelessWidget {
  const MessagesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (currentUid.isEmpty) {
      return const Center(child: Text('Login karein'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.forum_outlined, size: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'कोई संदेश नहीं',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'किसी उत्पाद पर "संदेश" बटन दबाएं',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          );
        }

        final chats = snapshot.data!.docs;

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          itemCount: chats.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: Colors.grey[200]),
          itemBuilder: (context, index) {
            final data = chats[index].data() as Map<String, dynamic>;
            final isbuyer = data['buyerId'] == currentUid;
            final otherName = isbuyer
                ? (data['sellerName'] ?? 'विक्रेता')
                : (data['buyerName'] ?? 'खरीदार');
            final otherUid = isbuyer
                ? (data['sellerId'] ?? '')
                : (data['buyerId'] ?? '');
            final productName = data['productName'] ?? '';
            final productId = data['productId'] ?? '';
            final lastMsg = data['lastMessage'] ?? '';
            final time = (data['lastMessageTime'] as Timestamp?)?.toDate();
            final timeStr = time != null
                ? '${time.hour}:${time.minute.toString().padLeft(2, '0')}'
                : '';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                otherName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              trailing: Text(
                timeStr,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherUserId: otherUid,
                    otherUserName: otherName,
                    productId: productId,
                    productName: productName,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}