import 'package:flutter/material.dart';

class CommentSendWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final TextEditingController commentController;
  final String hintText;

  const CommentSendWidget({
    super.key,
    required this.onPressed,
    required this.commentController,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color.fromARGB(19, 167, 157, 157),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          height: 28,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.deepPurpleAccent,
              padding: EdgeInsets.zero,
            ),
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
