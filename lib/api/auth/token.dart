import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

Future<String> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve the accessToken from SharedPreferences
  final accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    throw Exception('Access token is missing');
  }

  return accessToken;
}

Future<String> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();

  // Retrieve the accessToken from SharedPreferences
  final refreshToken = prefs.getString('refreshToken');

  if (refreshToken == null) {
    throw Exception('Refresh token is missing');
  }

  return refreshToken;
}

// 토큰이 잘못된 경우 (401 에러 발생 시) LoginPage로 이동
Future<void> checkTokenValidation(BuildContext context, http.Response response) async {
  if (response.statusCode == 401) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}

Future<bool> reissueToken(String accessToken, String refreshToken) async {
  final response = await http.post(
    Uri.parse('http://$ip:8080/api/v1/auth/reissue'), // 토큰 재 발행 검증 API 엔드포인트
    headers: {
      'accessToken': accessToken,
      'refreshToken': refreshToken
    },
  );

  if (response.statusCode == 200) {
    // 로그인 성공
    final accessToken = response.headers['authorization'];
    final refreshToken = response.headers['refreshtoken'];

    if (accessToken != null && refreshToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      logger.i("reissue success");
      return true;
    }
  } else if(response.statusCode == 400){
    logger.e("reissue failed: invalid(or expired) refresh token");
    return false;
  }

  logger.e(response.statusCode);
  return false;
}