import 'package:etk_web/api/post.dart';
import 'package:flutter/material.dart';

class PostCreationPage extends StatefulWidget {
  final int boardId;
  const PostCreationPage({super.key, required this.boardId});

  @override
  _PostCreationPageState createState() => _PostCreationPageState();
}

class _PostCreationPageState extends State<PostCreationPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnonymous = false;

  void _submitPost() {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    addPost(
      context,
      widget.boardId,
      _titleController.text,
      _contentController.text,
      _isAnonymous,
    );

    Navigator.of(context).pop(); // Navigate back after submitting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드에 의해 화면 크기가 조정되지 않도록 설정
      appBar: AppBar(
        title: const Text(
          '새 글 작성',
          style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  border: OutlineInputBorder(),
                ),
                maxLines: null, // 최대 줄 수를 제한하지 않음
                expands: true, // TextField가 가능한 공간을 모두 사용하도록 설정
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                ),
                const Text('익명으로 글쓰기'),
              ],
            ),
            ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('글 올리기'),
            ),
          ],
        ),
      ),
    );
  }
}
