import 'package:etk_web/widgets/community/post/post_creation_page.dart';
import 'package:flutter/material.dart';

class PostCreationButton extends StatelessWidget {
  final int boardId;

  const PostCreationButton({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostCreationPage(boardId: boardId),
            ),
          );
        },
        label: const Text('글쓰기'),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}
