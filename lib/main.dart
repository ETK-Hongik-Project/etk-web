import 'dart:io'; //

import 'package:camera/camera.dart';
import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/keyboard/keyboard_main_page.dart';

var logger = Logger();
CameraDescription? frontCamera;
// ignore: constant_identifier_names
const String local_ip = "10.0.2.2";
// ignore: constant_identifier_names
const String dev_ip = "43.202.147.116";

String ip = local_ip;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  // 전면 카메라를 찾기
  for (var camera in cameras) {
    if (camera.lensDirection == CameraLensDirection.front) {
      frontCamera = camera;
      break;
    }
  }

  if (frontCamera == null) {
    throw Exception('전면 카메라를 찾을 수 없습니다.');
  }

  // 앱 시작시 캐시에 저장된 이미지와 /app_flutter/image 폴더 제거
  _clearCache();

  runApp(const MyApp());
}

Future<void> _clearCache() async {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurpleAccent,
          ),
          bodyLarge: TextStyle(
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              return KeyboardMainPage();
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }
}
