class Comment {
  final int id;
  final String body;
  final int postId;

  Comment({
    required this.id,
    required this.body,
    required this.postId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'],
      postId: json['postId'],
    );
  }
}
