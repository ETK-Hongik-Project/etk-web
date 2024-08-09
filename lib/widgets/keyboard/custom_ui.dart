import 'dart:io';

import 'package:camera/camera.dart';
import 'package:etk_web/api/auth/logout.dart';
import 'package:etk_web/main.dart';
import 'package:etk_web/widgets/community/community_main_page.dart';
import 'package:etk_web/widgets/image/gallery_screen.dart';
import 'package:etk_web/widgets/keyboard/file_list_screen.dart';
import 'package:etk_web/widgets/keyboard/start_button.dart';
import 'package:etk_web/widgets/keyboard/stop_button.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../../keyboard_states.dart';
import '../../utils/hangul/hangul.dart';
import 'bottom_text_field.dart';
import 'camera_preview_widget.dart';
import 'center_content.dart';

class CustomUI extends StatefulWidget {
  final CameraDescription camera = frontCamera!;

  CustomUI({super.key});

  @override
  CustomUIState createState() => CustomUIState();
}

class CustomUIState extends State<CustomUI> with TickerProviderStateMixin {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final _hangulInput = HangulInput('');
  final TextEditingController _textController = TextEditingController();
  final logger = Logger();
  bool _isConsonantPage = false;
  bool _isVowelPage = false;
  KeyboardState _state = S0State('');
  int _currentPageIndex = 0;
  String _displayText = '';
  bool isTracking = false;
  late AnimationController _animationController;

  final List<String> selectionPage = ['자음', '모음'];

  // 문자 세트 정의
  final List<List<String>> consonantPages = [
    ['ㅇ', 'ㄴ', 'ㄱ', 'ㄹ'],
    ['ㅅ', 'ㄷ', 'ㅈ', 'ㅁ'],
    ['ㅎ', 'ㅂ', 'ㅊ', 'ㅌ'],
    ['ㅍ', 'ㅋ']
  ];

  final List<List<String>> vowelPages = [
    ['ㅏ', 'ㅣ', 'ㅡ', 'ㅓ'],
    ['ㅗ', 'ㅜ', 'ㅕ', 'ㅐ'],
    ['ㅔ', 'ㅛ', 'ㅑ', 'ㅠ'],
    // ['ㅢ', 'ㅘ', 'ㅙ'] //2중 모음 모든 케이스 못다룸.
  ];

  late List<String> _currentLabels;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low, // 240p
    );
    _currentLabels = consonantPages[0];
    _initializeControllerFuture = _controller.initialize();
    _textController.addListener(_updateDisplayText);
    // 애니메이션 컨트롤러 초기화
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500), // 시간 수정하기
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    debugPrint(_textController.text);
    _textController.removeListener(_updateDisplayText);
    _textController.dispose();
    super.dispose();
  }

  void _updateDisplayText() {
    setState(() {
      _displayText = _textController.text;
    });
  }

  void previousState() {
    setState(() {
      _state.undo(this);
    });
  }

  void changeState(KeyboardState state) {
    setState(() {
      resetIdx();
      _state = state;
      updateLabels(_currentPageIndex, _state.board);
    });
  }

  int getIdx() {
    return _currentPageIndex;
  }

  int getConsonantPageLen() {
    return consonantPages.length;
  }

  int getVowelPageLen() {
    return vowelPages.length;
  }

  void inputText(String text) {
    _hangulInput.pushCharacter(text);
    _textController.text = _hangulInput.text;
  }

  void incrementIdx() {
    setState(() {
      _currentPageIndex = ++_currentPageIndex %
          (_isConsonantPage ? consonantPages.length : vowelPages.length);
    });
  }

  void resetIdx() {
    setState(() {
      _currentPageIndex = 0;
    });
  }

  void resetDisplayText() {
    setState(() {
      _textController.clear();
      _updateDisplayText();
    });
  }

  void updateLabels(int index, String board) {
    /*
    board : ["consonant", "vowel", "select"]
    */
    setState(() {
      switch (board) {
        case "consonant":
          _currentLabels = consonantPages[index];
          _isConsonantPage = true;
          _isVowelPage = false;
          break;
        case "vowel":
          _currentLabels = vowelPages[index];
          _isConsonantPage = false;
          _isVowelPage = true;
          break;
        case "select":
          _currentLabels = selectionPage;
          _isConsonantPage = false;
          _isVowelPage = false;
          break;
      }
    });
  }

  // 시작 버튼 클릭시 안구 추적 시작
  void startTracking() {
    setState(() {
      isTracking = true;
      logger.i("시작 버튼 클릭됨. 안구 추적 시작!");
    });

    var start = DateTime.now();
    _animationController.forward(from: 0.0); // 애니메이션 시작

    // 0.5초 대기 후 추적 시작
    Future.delayed(const Duration(milliseconds: 500), () async {
      int pictureCount = 0;
      const int totalNumOfPicture = 5;

      while (isTracking && pictureCount < totalNumOfPicture) {
        // 사진 촬영 + 사진을 캐시에 저장
        final image = await _controller.takePicture();
        logger.i("사진 촬영됨: ${image.path}");

        pictureCount++;

        // 1.5초 동안 5장 찍음
        var duration = 1500 ~/ totalNumOfPicture;
        await Future.delayed(Duration(milliseconds: duration));
      }
      var finish = DateTime.now();

      logger.i("소요시간 ${start.difference(finish)}");

      // // 촬영이 끝나면 사진 분석 시작
      // if (isTracking) {
      //   for (int i = 0; i < frameCount; i++) {
      //     final String path =
      //         '${(await getTemporaryDirectory()).path}/frame_$i.jpg';
      //     String direction = await _analyzeImage(path);
      //     logger.i("시선 방향: $direction");
      //     _handleDirection(direction);
      //   }
      //
      // // picture count reset -> 촬영 반복
      // pictureCount = 0;
      //
      // }
    });
  }

  // 종료 버튼 클릭시 안구 추적 종료
  void stopTracking() {
    setState(() {
      isTracking = false;
      logger.i("종료 버튼 클릭됨. 안구 추적 종료!");
    });

    _animationController.stop(); // 애니메이션 중지
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '시선 추적 키보드',
          style: TextStyle(
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        // 캐시에 저장된 이미지들 확인하는 버튼 (추후 제거할 것!)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () async {
              final directory = await getTemporaryDirectory();
              final files = directory.listSync().whereType<File>().toList();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryScreen(imageFiles: files),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8,
            ),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FileListScreen()),
                  );
                },
                icon: const Icon(
                  Icons.comment,
                  size: 28,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 16, left: 8),
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommunityMainPage()),
                  );
                },
                icon: const Icon(
                  Icons.people_alt,
                  size: 28,
                )),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  CenterContent(
                    labels: _currentLabels,
                    onButtonPressed: (index) {
                      _state.handleInput(this, index);
                    },
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: CameraPreviewWidget(
                      controller: _controller,
                      future: _initializeControllerFuture,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: isTracking
                        ? StopButton(
                            onPressed: stopTracking,
                            animationController: _animationController,
                          )
                        : StartButton(onPressed: startTracking),
                  ),
                ],
              ),
            ),
            BottomTextField(
              textController: _textController,
              hangulInput: _hangulInput,
              displayText: _displayText,
              previousState: previousState,
              logger: logger,
              changeState: changeState,
              resetDisplayText: resetDisplayText,
            ),
          ],
        ),
      ),
    );
  }
}
