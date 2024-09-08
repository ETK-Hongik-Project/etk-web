import 'dart:io';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

Future<void> uploadImage(BuildContext context, List<File> imageFiles) async {
  final accessToken = await getAccessToken();

  // 서버의 엔드포인트
  final uri = Uri.parse('http://$ip:8080/api/v1/images');

  // Multipart 요청 생성
  var request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $accessToken';

  // 파일을 MultipartRequest에 추가
  for (File file in imageFiles) {
    final mimeType = lookupMimeType(file.path);

    request.files.add(
      http.MultipartFile(
        'file', // 서버에서 받을 필드 이름
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: basename(file.path),
        contentType: MediaType(
          mimeType!.split('/')[0], // 예: 'image'
          mimeType.split('/')[1], // 예: 'jpeg'
        ),
      ),
    );
  }

  // 요청을 보내고 응답 처리
  final response = await request.send();

  // 응답 처리
  if (response.statusCode == 201) {
    logger.i('이미지 업로드 성공');
  } else if (response.statusCode == 404) {
    logger.e('해당 username을 가지는 유저가 존재하지 않음 : ${response.statusCode}');
    throw Exception('Failed to upload image: User not found');
  } else {
    logger.e('Failed to upload image : ${response.statusCode}');
    throw Exception('Failed to upload image');
  }
}
