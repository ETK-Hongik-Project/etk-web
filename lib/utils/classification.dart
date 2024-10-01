import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart';

class ClassificationModel {
  static const platform = MethodChannel('com.model.prediction/predict');
  // FIXME: 얘가 리소스를 얼마나 먹는지는 모르겠는데, 일단은 튜토리얼에서는 ~.close()로 반환하라고 함
  // 내 생각에는 이건 항상 켜져있어야해서 그때그때 받아오는게 더 부하가 있을 듯?
  final faceDetector = FaceDetector(options: FaceDetectorOptions(
    enableContours: true
  ));

  int argmax(List<double> values) {
    if (values.isEmpty) {
      throw Exception("List is Empty");
    }
    double maxValue = values[0];
    int maxIdx = 0;

    for (int i = 1; i < values.length; ++i) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIdx = i;
      }
    }

    return maxIdx;
  }

  Future<int> predict(String imgPath) async {
    final inputImage = InputImage.fromFilePath(imgPath);

    final List<Face> faces = await faceDetector.processImage(inputImage);
    final face = faces[0];
    Rect bbox = face.boundingBox;

    // Crop the Face Image with bounding box
    final originalImage = img.decodeImage(File(imgPath).readAsBytesSync());

    if (originalImage == null) {
      throw Exception('Failed to load image.');
    }

    // 전달할 인자 준비(얼굴 크롭한 이미지, 원본 이미지 해상도, 바운딩박스)
    final croppedFace = img.copyResize(img.copyCrop(
      originalImage,
      x: bbox.left.toInt(),
      y: bbox.top.toInt(),
      width: bbox.width.toInt(),
      height: bbox.height.toInt(),
    ), );
    final Map<String, int> originSize = {"width": originalImage.width, "height": originalImage.height};
    final Map<String, int> boundingBox = {
      "x": bbox.left.toInt(),
      "y": bbox.top.toInt(),
      "width": bbox.width.toInt(),
      "height": bbox.height.toInt()
    };

    // 전달 정보. 원래 이지미지의 크기와, 바운딩 박스
    try{
      // 크롭된 이미지를 바이트 배열로 변환
      Uint8List imageBytes = Uint8List.fromList(img.encodeJpg(croppedFace));

      // 메소드 채널을 통해 네이티브(Java)로 이미지 바이트 배열 전달
      final int result = await platform.invokeMethod('predict', {"imgBytes": imageBytes,
                                                                  "originSize": originSize,
                                                                  "boundingBox": boundingBox});
      return result;
    }on PlatformException catch(e){
      print("Failed to run Model: ${e.message}");
      return -1;
    }
  }

  Future<int> runModel(String imgPath) async {
    try {
      final List<Object?> result =
          await platform.invokeMethod("runModel", {"imagePath": imgPath});
      return argmax(result.cast<double>());
    } on PlatformException catch (e) {
      print("Failed to run Model: '${e.message}'.");
      return -1;
    }
  }

  Future<void> updateModel(String modelPath) async {
    try {
      await platform.invokeMethod("updateModel", {"modelPath": modelPath});
      return;
    } on PlatformException catch (e) {
      print("Failed to Update Model: ${e.message}.");
      return;
    }
  }
}
