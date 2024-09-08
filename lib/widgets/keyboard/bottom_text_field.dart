import 'dart:io';

import 'package:etk_web/keyboard_states.dart';
import 'package:etk_web/widgets/keyboard/keyboard_main_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/hangul/hangul.dart';

class BottomTextField extends StatelessWidget {
  final TextEditingController textController;
  final HangulInput hangulInput;
  final String displayText;
  final void Function() previousState;
  final Logger logger;
  final void Function(KeyboardState) changeState;
  final void Function() resetDisplayText;

  const BottomTextField({
    super.key,
    required this.textController,
    required this.hangulInput,
    required this.displayText,
    required this.previousState,
    required this.logger,
    required this.changeState,
    required this.resetDisplayText,
  });

  void _saveToFile(String text) async {
    var now = DateTime.now();
    var year = now.year;
    var month = now.month < 10 ? '0${now.month}' : '${now.month}';
    var day = now.day < 10 ? '0${now.day}' : '${now.day}';
    var hour = now.hour < 10 ? '0${now.hour}' : '${now.hour}';
    var minute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    var second = now.second < 10 ? '0${now.second}' : '${now.second}';
    var millisecond = now.millisecond;
    var time = "$year-$month-$day $hour:$minute:$second:$millisecond";

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$time의 대화.txt');
    await file.writeAsString(text);
    logger.i('Content: $text File saved at ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    const int maxDisplayLength = 12; // 화면에 표시할 최대 글자 수
    String textToDisplay;

    if (displayText.length > maxDisplayLength) {
      textToDisplay =
          '...${displayText.substring(displayText.length - maxDisplayLength)}';
    } else {
      textToDisplay = displayText;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  textToDisplay.isNotEmpty ? textToDisplay : '글자가 출력됩니다.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  color: Colors.deepPurpleAccent,
                  onPressed: () {
                    if (hangulInput.text.isNotEmpty) {
                      previousState(); // 이전 state로 변경
                      hangulInput.backspace(); // 입력한 텍스트 지우기
                      logger.i(
                        "'${textController.text.substring(textController.text.length - 1)}' 제거",
                      );
                      textController.text = hangulInput.text;
                      undoCount++;
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => {
                    _saveToFile(displayText),
                    // S0 state로 변경
                    changeState(S0State('')),
                    // 입력한 텍스트 리셋
                    resetDisplayText(),
                    hangulInput.clear(),
                  },
                  color: Colors.deepPurpleAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
