import 'package:etk_web/api/comment.dart';
import 'package:etk_web/api/reply.dart';
import 'package:etk_web/widgets/community/post/comment_box.dart';
import 'package:etk_web/widgets/community/post/reply_box.dart';
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
  late final String boardName;
  late final String title;
  late final int postId;
  late final String content;
  late final String authorName;
  late final String createdTime;

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    title = widget.title;
    content = widget.content;
    authorName = widget.authorName;
    createdTime = widget.createdTime;
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
