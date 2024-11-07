import 'dart:convert';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> uploadJson(BuildContext context, String json) async {
  final accessToken = await getAccessToken();

  // 서버의 엔드포인트
  final uri = Uri.parse('http://$ip:8080/api/v1/json');

  // 요청 헤더와 body에 JSON 데이터 추가
  final response = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'data': json}),
  );

  // 응답 처리
  if (response.statusCode == 201) {
    logger.i('JSON 업로드 성공');
  } else if (response.statusCode == 404) {
    logger.e('해당 username을 가지는 유저가 존재하지 않음 : ${response.statusCode}');
    throw Exception('Failed to upload JSON: User not found');
  } else {
    logger.e('Failed to upload JSON : ${response.statusCode}');
    throw Exception('Failed to upload JSON');
  }
}
