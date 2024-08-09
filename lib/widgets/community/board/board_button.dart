import 'package:flutter/material.dart';

class BoardPageSelectionButton extends StatelessWidget {
  const BoardPageSelectionButton({
    super.key,
    required this.buttonName,
    required this.pageWidget,
  });

  final String buttonName;
  final Widget pageWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Text(
                  buttonName,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageWidget),
              );
            },
          ),
        ),
        Divider(color: Colors.deepPurple.withOpacity(0.1)), // 구분 라인 추가
      ],
    );
  }
}
