import 'dart:io';

import 'package:camera/camera.dart';
import 'package:etk_web/api/auth/logout.dart';
import 'package:etk_web/api/image.dart';
import 'package:etk_web/main.dart';
import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:etk_web/widgets/community/community_main_page.dart';
import 'package:etk_web/widgets/keyboard/file_list_screen.dart';
import 'package:etk_web/widgets/keyboard/start_button.dart';
import 'package:etk_web/widgets/keyboard/stop_button.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/auth/login.dart';
import '../../keyboard_states.dart';
import '../../utils/hangul/hangul.dart';
import 'bottom_text_field.dart';
import 'camera_preview_widget.dart';
import 'center_content.dart';

int undoCount = 0; // undo 횟수. 글자가 선택되면 다시 0으로 초기화

class KeyboardMainPage extends StatefulWidget {
  final CameraDescription camera = frontCamera!;

  KeyboardMainPage({super.key});

  @override
  KeyboardMainPageState createState() => KeyboardMainPageState();
}

class KeyboardMainPageState extends State<KeyboardMainPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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
  int _currentImageDirIndex = 0;

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
    WidgetsBinding.instance.addObserver(this); // Observer 등록
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
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    super.dispose();
  }

  // update_image 디렉토리의 파일들 삭제
  Future<void> _clearUpdateImageFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/update_image');

    if (await imageDir.exists()) {
      List<FileSystemEntity> imageFiles = imageDir.listSync();
      for (var entity in imageFiles) {
        if (entity is File) {
          await entity.delete(); // 파일 삭제
        }
      }
    }
  }

  // 종료시 update_image 폴더에 있는 이미지를 서버로 전송.
  Future<void> _uploadImagesBeforeExit() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${directory.path}/update_image');

      if (await imageDir.exists()) {
        final List<FileSystemEntity> files = imageDir.listSync();
        List<File> imageFiles = [];
        for (var entity in files) {
          if (entity is File) {
            imageFiles.add(entity);
          }
        }
        if (imageFiles.isNotEmpty) {
          await uploadImage(context, imageFiles);
        } else {
          logger.i("이미지 업로드 실패: 업로드할 이미지가 존재하지 않음.");
        }
      }
    } catch (e) {
      logger.e("이미지 업로드 실패: $e");
    }
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

  bool _isTrackingInProgress =
      false; // Add a flag to monitor the state of tracking
  // 시작 버튼 클릭시 안구 추적 시작
  void startTracking() async {
    setState(() {
      isTracking = true;
      logger.i("시작 버튼 클릭됨. 안구 추적 시작!");
    });

    _track(); // 비동기 추적 시작
  }

  Future<void> _track() async {
    _isTrackingInProgress = true;

    while (isTracking) {
      var start = DateTime.now();
      _animationController.forward(from: 0.0); // 애니메이션 시작

      // 0.5초 대기 후 추적 시작
      await Future.delayed(const Duration(milliseconds: 500));

      int pictureCount = 0;
      const int totalNumOfPicture = 5;

      while (isTracking && pictureCount < totalNumOfPicture) {
        // 사진 촬영 + 사진을 캐시에 저장
        final image = await _controller.takePicture();

        pictureCount++;

        // 1.5초 동안 5장 찍음
        var duration = 1500 ~/ totalNumOfPicture;
        await Future.delayed(Duration(milliseconds: duration));
      }

      var finish = DateTime.now();
      logger.i("$pictureCount장 촬영 소요시간 ${start.difference(finish)}");

      // 촬영이 끝나면 사진 분석 시작
      if (isTracking) {
        int index = await _extractDirection();

        /**index 값에 따라서 keyboard 인식**/
        setState(() {
          _state.handleInput(this, index);
        });

        _createUpdateImage(index);

        undoCount = 0; // 글자를 선택했으므로 undoCount 초기화
        pictureCount = 0;
      }
    }

    _isTrackingInProgress = false;
  }

  /// 1. /cache에 저장된 파일들로 방향 예측
  /// 2. 방향 예측 후 /cache 내부의 모든 파일들을 새로운 폴더로 예측한 label과 함께 이동
  Future<int> _extractDirection() async {
    final tmpDir = await getTemporaryDirectory();
    List<FileSystemEntity> files = tmpDir.listSync();

    Map<int, int> frequencyMap = {-1: 0, 0: 0, 1: 0, 2: 0, 3: 0, 4: 0};

    for (var entity in files) {
      if (entity is File) {
        final result = await model.runModel(entity.path);
        frequencyMap[result] = frequencyMap[result]! + 1;
      }
    }

    int label = -1;
    int maxFrequency = 0;
    frequencyMap.forEach((key, value) {
      if (value > maxFrequency) {
        maxFrequency = value;
        label = key;
      }
    });

    logger.i("Classification Result: $label");

    // Direction 값을 저장할 디렉터리 경로 설정
    final directory = await getApplicationDocumentsDirectory();
    final targetDir =
        Directory('${directory.path}/image/image_${_currentImageDirIndex++}');

    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }

    // label.txt에 모델이 예측한 방향을 적어서 저장
    final labelFile = File('${targetDir.path}/label.txt');
    await labelFile.writeAsString('$label');

    // tmpDir의 파일을 targetDir로 이동
    for (var entity in files) {
      if (entity is File) {
        final newPath = '${targetDir.path}/${entity.uri.pathSegments.last}';
        await entity.copy(newPath);
        await entity.delete(); // 원본 파일 삭제
      }
    }

    logger.i("파일이동: $targetDir");
    return label;
  }

  /// undoCount가 1인 경우 undo한 파일을 새로 선택된 label과 함께 update_image 폴더로 복사
  Future<void> _createUpdateImage(int label) async {
    if (undoCount != 1) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final sourceDir = Directory(
        '${directory.path}/image/image_${_currentImageDirIndex - 2}'); // undo한 단어의 이미지 directory
    final targetDir =
        Directory('${directory.path}/update_image'); // 서버로 전송할 이미지 directory

    if (!(await targetDir.exists())) {
      await targetDir.create(recursive: true);
    }

    // Check if the sourceDir exists and contains .jpg files
    if (await sourceDir.exists()) {
      // List all files in sourceDir
      final List<FileSystemEntity> files = sourceDir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.jpg')) {
          // Extract the original filename without extension
          final filename = file.uri.pathSegments.last.split('.').first;

          // Construct new filename by appending '_label'
          final newFilename = '${filename}_$label.jpg';

          // Move the file to target directory with the new filename
          final newFile = File('${targetDir.path}/$newFilename');

          // Move the file to the target directory (or you can copy if needed)
          await file.rename(newFile.path);
        }
      }
      logger.d("[가중치 업데이트] $sourceDir의 파일을 $targetDir로 이동");
    } else {
      logger.e('Source directory does not exist: $sourceDir');
    }
  }

  void _clearCache() async {
    final tmpDir = await getTemporaryDirectory();
    List<FileSystemEntity> files = tmpDir.listSync();

    for (var entity in files) {
      if (entity is File) {
        await entity.delete(); // 캐시 이미지 파일 삭제
      }
    }
  }

  // 종료 버튼 클릭시 안구 추적 종료
  void stopTracking() async {
    setState(() {
      isTracking = false;
      logger.i("종료 버튼 클릭됨. 안구 추적 종료!");
    });

    // 안구 추적이 완전히 종료되었을 때까지 기다림
    while (_isTrackingInProgress) {
      await Future.delayed(const Duration(milliseconds: 100)); // Polling
    }

    _animationController.stop(); // 애니메이션 중지

    // 캐시 비우기
    _clearCache();
  }

  Future<void> _clearCacheDirectory() async {
    // 캐시 디렉토리의 파일들 삭제
    final tmpDir = await getTemporaryDirectory();
    List<FileSystemEntity> tmpFiles = tmpDir.listSync();

    for (var entity in tmpFiles) {
      if (entity is File) {
        await entity.delete(); // 파일 삭제
      }
    }

    // /data/data/com.example.etk_web/app_flutter/image 폴더 삭제
    final appDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${appDir.path}/image');

    if (await imageDir.exists()) {
      await _deleteDirectory(imageDir); // 폴더 내부 파일 및 서브 폴더까지 모두 삭제
    }
  }

// 폴더 내부의 파일들과 서브 디렉토리까지 모두 재귀적으로 삭제하는 함수
  Future<void> _deleteDirectory(Directory dir) async {
    if (await dir.exists()) {
      try {
        // 파일 및 서브 디렉토리 모두 삭제
        dir.deleteSync(recursive: true);
      } catch (e) {
        logger.e("Error deleting directory: $e");
      }
    }
  }

  // 종료시 종료 여부 묻는 팝업 발생
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                "앱 종료",
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "앱을 종료하시겠습니까?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _clearCacheDirectory(); // 앱 종료 시 캐시에 저장된 이미지와 /app_flutter/image 폴더 제거
                    if (isLoggedIn) {
                      await _uploadImagesBeforeExit(); // 모델 학습할 이미지 서버로 전송
                    }
                    await _clearUpdateImageFiles(); // 전송한 이미지들 삭제
                    Navigator.of(context).pop(true); // "예" 선택 시 종료
                  },
                  child: const Text(
                    "예",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // "아니오" 선택 시 종료하지 않음
                  },
                  child: const Text(
                    "아니오",
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Dialog가 취소되었을 때 false 반환
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '시선 추적 키보드',
            style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded),
              onSelected: (String result) {
                switch (result) {
                  case 'file_list':
                    _navigateToFileListScreen(context);
                    break;
                  case 'community':
                    _navigateToCommunityMainPage(context);
                    break;
                  case 'logout':
                    logout(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'file_list',
                  child: Row(
                    children: [
                      Icon(Icons.comment),
                      SizedBox(width: 6),
                      Text('대화 기록'),
                    ],
                  ),
                ),
                if (isLoggedIn)
                  const PopupMenuItem<String>(
                    value: 'community',
                    child: Row(
                      children: [
                        Icon(Icons.people_alt),
                        SizedBox(width: 6),
                        Text('커뮤니티'),
                      ],
                    ),
                  ),
                if (isLoggedIn)
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 6),
                        Text('로그아웃'),
                      ],
                    ),
                  ),
              ],
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
                        _createUpdateImage(index);
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
      ),
    );
  }

  void _navigateToFileListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FileListScreen(),
      ),
    );
  }

  void _navigateToCommunityMainPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityMainPage(),
      ),
    );
  }
}
