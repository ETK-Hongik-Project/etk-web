import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:etk_web/widgets/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final logger = Logger();

  logger.i('accessToken: $accessToken');

  if (accessToken != null) {
    final response = await http.post(
      Uri.parse('http://$ip:8080/api/v1/auth/logout'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'accessToken': accessToken,
      },
    );

    checkTokenValidation(context, response);

    if (response.statusCode == 200) {
      // 로그아웃 성공 시 토큰 삭제 및 로그인 페이지로 이동
      logger.i('logout success!');
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      logger.e('Failed to logout: ${response.statusCode}');
    }
  }
}
