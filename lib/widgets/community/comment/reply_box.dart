import 'package:etk_web/api/comment.dart';
import 'package:flutter/material.dart';

class ReplyBox extends StatefulWidget {
  const ReplyBox({
    super.key,
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

  @override
  _ReplyBoxState createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<ReplyBox> {
  late String content;
  late String commenterName;
  late String createdTime;
  late bool isDeleted;

  @override
  void initState() {
    super.initState();
    content = widget.content;
    commenterName = widget.commenterName;
    createdTime = widget.createdTime;
    isDeleted = widget.isDeleted;
  }

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
              onPressed: () async {
                try {
                  // 댓글 삭제 요청
                  var deletedComment =
                      await deleteComment(context, widget.commentId);
                  if (mounted) {
                    setState(() {
                      content = deletedComment.content;
                      commenterName = deletedComment.commenterName;
                      createdTime = deletedComment.createdTime;
                      isDeleted = deletedComment.isDeleted;
                    });
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  Navigator.of(context).pop();

                  // Exception이 발생한 경우 '본인의 글만 삭제할 수 있습니다' AlertDialog 표시
                  if (e.toString().contains("not user's comment")) {
                    _showErrorDialog(context, '본인의 답글만 삭제할 수 있습니다');
                  } else {
                    _showErrorDialog(context, '댓글 삭제에 실패했습니다.');
                  }
                }
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

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right_rounded),
                  const Icon(
                    Icons.person,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    commenterName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 20),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: isDeleted
                        ? null
                        : () => _showDeleteConfirmationDialog(context),
                    child: const Text('삭제'),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(createdTime,
                    textAlign: TextAlign.left,
                    style: const TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
        Divider(color: Colors.deepPurple.withOpacity(0.1)),
      ],
    );
  }
}
