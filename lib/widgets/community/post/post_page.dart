import 'package:etk_web/api/comment.dart';
import 'package:etk_web/api/reply.dart';
import 'package:etk_web/widgets/community/comment/comment_box.dart';
import 'package:etk_web/widgets/community/comment/comment_creation_box.dart';
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

  List<Comment> comments = [];
  bool isLoading = false;

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

  void _addComment(BuildContext context, int postId, String content) {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력해주세요')),
      );
      return;
    }
    addComment(context, postId, content);
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(19, 167, 157, 157),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CommentCreationBox(
                  onPressed: () async {
                    try {
                      await addComment(
                          context, postId, _commentController.text);
                      _commentController.clear(); // 댓글 입력 필드 초기화
                      _loadComments(); // 댓글 목록 새로고침
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
            const SizedBox(height: 8),
            Divider(color: Colors.deepPurple.withOpacity(0.2)),
            Expanded(
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
                              commenterName:
                                  snapshot.data![index].commenterName,
                              createdTime: snapshot.data![index].createdTime,
                            ),
                            Column(
                              children: [
                                for (Reply reply
                                    in snapshot.data![index].replies)
                                  ReplyBox(
                                    commentId: reply.commentId,
                                    content: reply.content,
                                    commenterName: reply.commenterName,
                                    createdTime: reply.createdTime,
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
            ),
          ],
        ),
      ),
    );
  }
}
