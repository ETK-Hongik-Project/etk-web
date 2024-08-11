import 'package:flutter/material.dart';

class CommentBox extends StatelessWidget {
  const CommentBox({
    super.key,
    required this.commentId,
    required this.content,
    required this.commenterName,
    required this.createdTime,
  });

  final int commentId;
  final String content;
  final String commenterName;
  final String createdTime;

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('댓글 삭제'),
          content: const Text('정말로 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '확인',
                style: TextStyle(
                  color: Colors.deepPurple,
                ),
              ),
              onPressed: () {
                // 실제 댓글 삭제 로직 구현 ..
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                child: const Text(
                  '취소',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // 팝업 닫기
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 5),
              Text(
                commenterName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(), // Spacer 위젯 추가
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // 패딩 제거
                  minimumSize: const Size(50, 20), // 최소 크기 설정
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 클릭 영역 축소
                ),
                onPressed: () => print("대댓글 생성"),
                child: const Text('답글'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // 패딩 제거
                  minimumSize: const Size(50, 20), // 최소 크기 설정
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 클릭 영역 축소
                ),
                onPressed: () => _showDeleteConfirmationDialog(context),
                child: const Text('삭제'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              createdTime,
              textAlign: TextAlign.left,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Divider(color: Colors.deepPurple.withOpacity(0.1)),
        ],
      ),
    );
  }
}
