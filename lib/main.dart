import 'dart:io'; //
import 'dart:collection'; // Map<int, int>
import 'package:camera/camera.dart';
import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/classification.dart';
import 'widgets/keyboard/keyboard_main_page.dart';
import 'package:path_provider/path_provider.dart';


var logger = Logger();
CameraDescription? frontCamera;
// ignore: constant_identifier_names
const String local_ip = "10.0.2.2";
// ignore: constant_identifier_names
const String dev_ip = "43.202.147.116";

String ip = dev_ip;

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

  // TODO: 지워야함. 테스트용
  final tmpDir = await getTemporaryDirectory();
  List<FileSystemEntity>  files = tmpDir.listSync();
  ClassificationModel model = ClassificationModel();
  Map<int, int> frequencyMap = {-1:0, 0:0, 1:0, 2:0, 3:0, 4:0};
  for (var entity in files) {
    if (entity is File) {
      final result = await model.runModel(entity.path);
      frequencyMap[result] = frequencyMap[result]! + 1;
    }
  }
  int mostFrequentElem = -1;
  int maxFrequency = 0;
  frequencyMap.forEach((key, value){
    if(value > maxFrequency){
      maxFrequency = value;
      mostFrequentElem = key;
    }
  });

  print("Classification Result: $mostFrequentElem");

  runApp(const MyApp());
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
