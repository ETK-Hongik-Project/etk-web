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

  runApp(const MyApp());

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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<bool> _loginFuture = _reissueAndValidateLoginStatus(context); // 캐시된 Future

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
        future: _loginFuture,
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

  Future<bool> _reissueAndValidateLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    // 만약 accessToken이 없다면 false 반환
    if (accessToken == null || refreshToken == null) {
      logger.w("Token was missing");
      return false;
    }

    // accessToken의 유효성 검증
    logger.i("refresh token: $refreshToken");
    final response = await _reissueToken(accessToken, refreshToken);

    logger.w(response.headers["accessToken"]!);
    logger.w(response.headers["refreshToken"]!);

    // reissue 요청시 400 에러 발생 시 로그인 페이지로 이동
    if (response.statusCode == 400) {
      await _handleInvalidToken(context);
      return false;
    }

    // Token 갱신
    // 유효한지 확인 후 토큰을 업데이트
    if (response.headers["accessToken"] != null && response.headers["refreshToken"] != null) {
      prefs.remove("accessToken");
      prefs.remove("refreshToken");

      prefs.setString("accessToken", response.headers["accessToken"]!);
      prefs.setString("refreshToken", response.headers["refreshToken"]!);

      logger.i("Tokens successfully updated.");
    } else {
      logger.e("Failed to update tokens. Server response was invalid.");
    }

    return true;
  }

  Future<http.Response> _reissueToken(String accessToken, String refreshToken) async {
    // 토큰 검증을 위한 API 요청 (유효한지 확인하는 API를 호출해야 함)
    return await http.post(
      Uri.parse('http://$ip:8080/api/v1/auth/reissue'), // 토큰 재 발행 검증 API 엔드포인트
      headers: {
        'accessToken': accessToken,
        'refreshToken': refreshToken
      },
    );
  }

  Future<void> _handleInvalidToken(BuildContext context) async {
    // 잘못된 토큰 처리 (토큰 삭제)
    logger.w("Invalid token");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }
}
