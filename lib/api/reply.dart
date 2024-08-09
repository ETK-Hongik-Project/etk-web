class Reply {
  Reply({
    required this.commentId,
    required this.content,
    required this.commenterName,
    required this.createdTime,
  });

  final int commentId;
  final String content;
  final String commenterName;
  final String createdTime;

  factory Reply.from(Map<String, dynamic> data) {
    return Reply(
      commentId: data['commentId'],
      content: data['content'],
      commenterName: data['commenterName'],
      createdTime: data['createdTime'],
    );
  }
}
