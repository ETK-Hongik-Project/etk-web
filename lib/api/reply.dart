class Reply {
  Reply({
    required this.commentId,
    required this.content,
    required this.commenterName,
    required this.createdTime,
    required this.isDeleted,
  });

  final int commentId;
  final String content;
  final String commenterName;
  final String createdTime;
  final bool isDeleted;

  factory Reply.from(Map<String, dynamic> data) {
    return Reply(
      commentId: data['commentId'],
      content: data['content'],
      commenterName: data['commenterName'],
      createdTime: data['createdTime'],
      isDeleted: data['isDeleted'],
    );
  }
}
