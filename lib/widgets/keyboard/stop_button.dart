import 'package:flutter/material.dart';

class StopButton extends StatelessWidget {
  const StopButton({
    super.key,
    required this.onPressed,
    required this.animationController,
  });
  final VoidCallback onPressed;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: 1.0 - animationController.value,
                strokeWidth: 5,
                color: Colors.deepPurple,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => onPressed(),
              color: Colors.deepPurple,
              iconSize: 50,
            ),
          ],
        );
      },
    );
  }
}
