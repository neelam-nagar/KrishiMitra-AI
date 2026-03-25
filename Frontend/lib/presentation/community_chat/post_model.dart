class PostModel {
  final String id;
  final String userName;
  final String text;

  /// optional image (local path / web blob url)
  final String? imagePath;

  /// comments list
  final List<String> comments;

  /// single-user like toggle
  bool isLiked;

  /// ownership (used to allow delete on frontend)
  final bool isOwner;

  bool get canDelete => isOwner;

  PostModel({
    required this.id,
    required this.userName,
    required this.text,
    this.imagePath,
    this.isOwner = true,
    List<String>? comments,
    this.isLiked = false,
  }) : comments = comments ?? [];

  /// like count (1 = liked, 0 = not liked)
  int get likeCount => isLiked ? 1 : 0;

  /// toggle like / unlike (one user → toggle)
  void toggleLike() {
    isLiked = !isLiked;
  }

  /// add comment
  void addComment(String comment) {
    if (comment.trim().isEmpty) return;
    comments.add(comment.trim());
  }

  bool allowDelete(String currentUserName) {
    return isOwner || currentUserName == userName;
  }
}