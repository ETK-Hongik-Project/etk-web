import 'dart:io';

import 'package:camera/camera.dart';
import 'package:etk_web/api/weight.dart';
import 'package:etk_web/utils/classification.dart';
import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

ClassificationModel model = ClassificationModel();
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

  // 가중치 서버에서 다운로드
  try {
    await downloadWeightFile();
  } catch (e) {
    logger.e("Error downloading weight file: $e");
  }

  // 가중치를 모델 적용
  final fileDir = await getApplicationSupportDirectory();
  final modelPath = "${fileDir.path}/xnnpack_classification_model.pte";

  // Check if the model file exists
  final modelFile = File(modelPath);

  if (await modelFile.exists()) {
    logger.i("update model");
    model.updateModel(modelPath);
  } else {
    logger.w("Model update unavailable: The file does not exist.");
  }

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

  Future<bool> _checkAndValidateLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    // 만약 accessToken이 없다면 false 반환
    if (accessToken == null) {
      return false;
    }

    // accessToken의 유효성 검증
    final response = await _validateToken(accessToken);

    // 토큰이 유효하지 않으면 false 반환하고 로그인 페이지로 이동
    if (response.statusCode == 401) {
      await _handleInvalidToken(context);
      return false;
    }

    // 토큰이 유효하면 true 반환
    return true;
  }

  Future<http.Response> _validateToken(String accessToken) async {
    // 토큰 검증을 위한 API 요청 (유효한지 확인하는 API를 호출해야 함)
    return await http.get(
      Uri.parse('http://$ip:8080/api/v1/token/validate'), // 유효성 검증 API 엔드포인트
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  Future<void> _handleInvalidToken(BuildContext context) async {
    // 잘못된 토큰 처리 (토큰 삭제 및 로그인 페이지로 이동)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
