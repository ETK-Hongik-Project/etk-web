import 'dart:io';

import 'package:etk_web/api/image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../main.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _clearCache() async {
    // 캐시 디렉토리의 파일들 삭제
    final directory = await getApplicationDocumentsDirectory();

    var directoryPath = '${directory.path}/update_image';
    final sourceDir = Directory(directoryPath);
    List<FileSystemEntity> tmpFiles = sourceDir.listSync();

    for (var entity in tmpFiles) {
      if (entity is File) {
        await entity.delete(); // 파일 삭제
      }
    }
  }

  /**
   * /update_image 의 모든 이미지 파일을 서버로 업로드
   */
  Future<void> _uploadAllImages() async {
    // 이미지가 저장된 디렉토리 경로
    final directory = await getApplicationDocumentsDirectory();

    var directoryPath = '${directory.path}/update_image';
    final sourceDir = Directory(directoryPath);

    if (await directory.exists()) {
      // 디렉토리 내 파일 목록을 가져옴
      final List<FileSystemEntity> files = sourceDir.listSync();

      // 이미지 파일 필터링 (jpg, png, jpeg 확장자)
      final List<File> imageFiles = files
          .whereType<File>()
          .where((file) =>
          file.path.endsWith('.jpg') ||
          file.path.endsWith('.jpeg') ||
          file.path.endsWith('.png'))
          .toList();

      if (imageFiles.isNotEmpty) {
        // 서버로 이미지 파일 전송
        await uploadImage(context, imageFiles);
      } else {
        logger.w('가중치 업데이트를 위해 전송할 이미지 파일이 없습니다.');
      }
    } else {
      logger.e('디렉토리가 존재하지 않습니다.');
      throw Exception("Directory doesn't exists: $directoryPath/update_image");
    }

    //  sourceDir 비우기
    _clearCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(_imageFile!)
                : const Text('가중치 이미지 업로드'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadAllImages,
              child: const Text('업로드'),
            ),
          ],
        ),
      ),
    );
  }
}
