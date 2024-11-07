import 'dart:io';

import 'package:camera/camera.dart';
import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/api/weight.dart';
import 'package:etk_web/utils/classification.dart';
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

String ip = dev_ip;

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _reissueFuture;

  @override
  void initState() {
    super.initState();
    _reissueFuture = _reissueAndValidateLoginStatus();
  }

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
        future: _reissueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data == true) {
            isLoggedIn = true;
            return KeyboardMainPage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }

  Future<bool> _reissueAndValidateLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (accessToken == null || refreshToken == null) {
      logger.w("Token was missing");
      return false;
    }

    return await reissueToken(accessToken, refreshToken);
  }
}
