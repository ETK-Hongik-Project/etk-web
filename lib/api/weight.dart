import 'dart:io';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> uploadWeightFile(BuildContext context, File weightFiles) async {
  final accessToken = await getAccessToken();

  // 서버의 엔드포인트
  final uri = Uri.parse('http://$ip:8080/api/v1/weight');

  // Multipart 요청 생성
  var request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $accessToken';

  // 파일을 MultipartRequest에 추가
  final mimeType = lookupMimeType(weightFiles.path);

  request.files.add(
    http.MultipartFile(
      'file', // 서버에서 받을 필드 이름
      weightFiles.readAsBytes().asStream(),
      weightFiles.lengthSync(),
      filename: basename(weightFiles.path),
      contentType: MediaType(
        mimeType!.split('/')[0], // 예: 'xnnpack_classification_model'
        mimeType.split('/')[1], // 예: 'pte'
      ),
    ),
  );

  // 요청을 보내고 응답 처리
  final response = await request.send();

  // 응답 처리
  if (response.statusCode == 201) {
    logger.i('가중치 파일 업로드 성공');
  } else if (response.statusCode == 404) {
    logger.e('해당 username을 가지는 유저가 존재하지 않음 : ${response.statusCode}');
    throw Exception('Failed to upload weight: User not found');
  } else {
    logger.e('Failed to upload weight file : ${response.statusCode}');
    throw Exception('Failed to upload weight file');
  }
}

Future<void> downloadWeightFile(BuildContext context) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/weight'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  // Ensure the token is valid
  checkTokenValidation(context, response);

  if (response.statusCode == 200) {
    // File content in bytes
    final bytes = response.bodyBytes;

    // You can now save the bytes as a file on the device (e.g., using path_provider or other file saving mechanism)
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/downloaded_weight.pte');

    await file.writeAsBytes(bytes);

    print('File saved at: ${file.path}');
  } else {
    throw Exception('Failed to download file');
  }
}
