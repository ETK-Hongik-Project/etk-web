import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
Future<void> checkTokenValidation(
    BuildContext context, http.Response response) async {
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
