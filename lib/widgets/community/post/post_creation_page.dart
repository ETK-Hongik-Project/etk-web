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
        elevation: 0,
        title: const Text(
          '새 글 작성',
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.deepPurpleAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                filled: true,
                fillColor: Colors.deepPurple[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '내용',
                  labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                  filled: true,
                  fillColor: Colors.deepPurple[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
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
                  activeColor: Colors.deepPurpleAccent,
                  onChanged: (value) {
                    setState(() {
                      _isAnonymous = value ?? false;
                    });
                  },
                ),
                const Text(
                  '익명으로 글쓰기',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  '글 쓰기',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
