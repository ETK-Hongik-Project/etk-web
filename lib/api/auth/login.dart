import 'dart:convert';

import 'package:etk_web/main.dart';
import 'package:etk_web/widgets/keyboard/keyboard_main_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/auth/login_page.dart';

Future<void> login(
    BuildContext context, String username, String password) async {
  final response = await http.post(
    Uri.parse('http://$ip:8080/api/v1/auth/login'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "username": username,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    // 로그인 성공
    final accessToken = response.headers['authorization'];
    final refreshToken = response.headers['refreshtoken'];

    if (accessToken != null && refreshToken != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', accessToken);
      await prefs.setString('refreshToken', refreshToken);
      logger.i("${DateTime.now()}\nlogin");

      isLoggedIn = true;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => KeyboardMainPage()),
      );
    }
  } else {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    var error = jsonResponse["message"];
    if (response.statusCode == 400) {
      // 아이디, 비밀번호 입력하지 않음
      logger.e("Failed to create an account ($error)");
      throw Exception("$error");
    } else if (response.statusCode == 404) {
      // 잘못된 아이디 혹은 비밀번호
      logger.e('Failed to create an account ($error)');
      throw Exception("$error");
    }
  }
}
