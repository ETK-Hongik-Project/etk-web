import 'package:flutter/material.dart';

class CommentCreationBox extends StatelessWidget {
  final VoidCallback onPressed;

  const CommentCreationBox({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
