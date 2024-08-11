import 'package:flutter/material.dart';

class ReplyBox extends StatelessWidget {
  const ReplyBox({
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
