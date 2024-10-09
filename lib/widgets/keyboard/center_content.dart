import 'package:flutter/material.dart';

import 'positioned_button.dart';

class CenterContent extends StatelessWidget {
  final List<String> labels;
  final Function(int) onButtonPressed;
  final bool showNextButton;

  const CenterContent({
    super.key,
    required this.labels,
    required this.onButtonPressed,
    this.showNextButton = true,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];

    if (showNextButton) {
      buttons.add(PositionedButton(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        label: "다음",
        index: 4,
        onPressed: () => onButtonPressed(4),
      ));
    }

    if (labels.isNotEmpty) {
      buttons.add(
        PositionedButton(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 20.0),
          index: 0,
          label: labels[0],
          onPressed: () => onButtonPressed(0),
        ),
      );
    }
    if (labels.length > 1) {
      buttons.add(
        PositionedButton(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 20.0),
          index: 1,
          label: labels[1],
          onPressed: () => onButtonPressed(1),
        ),
      );
    }
    if (labels.length > 2) {
      buttons.add(
        PositionedButton(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 5.0),
          index: 2,
          label: labels[2],
          onPressed: () => onButtonPressed(2),
        ),
      );
    }
    if (labels.length > 3) {
      buttons.add(
        PositionedButton(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 5.0),
          index: 3,
          label: labels[3],
          onPressed: () => onButtonPressed(3),
        ),
      );
    }

    return Stack(children: buttons);
  }
}
