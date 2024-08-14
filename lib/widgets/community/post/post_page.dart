import 'package:etk_web/api/comment.dart';
import 'package:etk_web/api/reply.dart';
import 'package:etk_web/widgets/community/comment/comment_box.dart';
import 'package:etk_web/widgets/community/comment/comment_send_widget.dart';
import 'package:etk_web/widgets/community/comment/reply_box.dart';
import 'package:flutter/material.dart';

class PostPage extends StatefulWidget {
  const PostPage({
    super.key,
    required this.boardName,
    required this.title,
    required this.postId,
    required this.content,
    required this.authorName,
    required this.createdTime,
  });

  final String boardName;
  final String title;
  final int postId;
  final String content;
  final String authorName;
  final String createdTime;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  late final String boardName;
  late final String title;
  late final int postId;
  late final String content;
  late final String authorName;
  late final String createdTime;

  final String commentHintText = '댓글을 입력하세요...';
  final String replyHintText = '답글을 입력하세요...';

  List<Comment> comments = [];
  bool isLoading = false;
  bool isReplying = false;
  int? selectedCommentId; // 답글을 달고자 하는 댓글 ID 저장

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    title = widget.title;
    content = widget.content;
    authorName = widget.authorName;
    createdTime = widget.createdTime;
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });
    try {
      comments = await fetchAllComments(context, postId);
    } catch (e) {
      // 에러 처리
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onReply(int commentId) {
    setState(() {
      isReplying = true;
      selectedCommentId = commentId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.boardName,
          style: const TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 38,
                  color: Colors.deepPurple,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      createdTime,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.deepPurple.withOpacity(0.2)),
            const SizedBox(height: 4),
            if (!isReplying)
              AllComments(
                postId: postId,
                onReply: _onReply, // 답글 버튼 클릭 시 처리할 함수 전달
              )
            else
              SpecificComment(
                commentId: selectedCommentId!,
              ),
            const SizedBox(width: 8),
            CommentSendWidget(
              commentController: _commentController,
              hintText: isReplying ? replyHintText : commentHintText,
              onPressed: () async {
                try {
                  if (!isReplying) {
                    await addComment(context, postId, _commentController.text);
                  } else {
                    await addReply(
                        context, selectedCommentId!, _commentController.text);
                  }
                  _commentController.clear(); // 댓글 입력 필드 초기화
                  _loadComments(); // 댓글 목록 새로고침
                  setState(() {
                    isReplying = false;
                    selectedCommentId = null;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('내용을 입력해주세요')),
                  );
                  return;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 모든 댓글 조회
class AllComments extends StatelessWidget {
  const AllComments({
    super.key,
    required this.postId,
    required this.onReply,
  });

  final int postId;
  final Function(int) onReply; // onReply 콜백 함수 추가

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Comment>>(
        future: fetchAllComments(context, postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CommentBox(
                      commentId: snapshot.data![index].commentId,
                      content: snapshot.data![index].content,
                      commenterName: snapshot.data![index].commenterName,
                      createdTime: snapshot.data![index].createdTime,
                      isDeleted: snapshot.data![index].isDeleted,
                      onReply: () => onReply(snapshot.data![index].commentId),
                    ),
                    Column(
                      children: [
                        for (Reply reply in snapshot.data![index].replies)
                          ReplyBox(
                            commentId: reply.commentId,
                            content: reply.content,
                            commenterName: reply.commenterName,
                            createdTime: reply.createdTime,
                            isDeleted: reply.isDeleted,
                          ),
                      ],
                    )
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

// 특정 댓글 조회
class SpecificComment extends StatelessWidget {
  const SpecificComment({
    super.key,
    required this.commentId,
  });

  final int commentId;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<Comment>(
        future: fetchComment(context, commentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('댓글을 찾을 수 없습니다.'));
          } else {
            final comment = snapshot.data!;
            return ListView(
              children: [
                CommentBox(
                  commentId: comment.commentId,
                  content: comment.content,
                  commenterName: comment.commenterName,
                  createdTime: comment.createdTime,
                  isDeleted: comment.isDeleted,
                  // onReply: () {}, // 특정 댓글에서는 답글 버튼이 비활성화되거나 다른 동작을 지정할 수 있음
                ),
                Column(
                  children: [
                    for (Reply reply in comment.replies)
                      ReplyBox(
                        commentId: reply.commentId,
                        content: reply.content,
                        commenterName: reply.commenterName,
                        createdTime: reply.createdTime,
                        isDeleted: reply.isDeleted,
                      ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
