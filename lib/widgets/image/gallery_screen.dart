import 'dart:io';

import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  final List<File> imageFiles;

  const GalleryScreen({super.key, required this.imageFiles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('저장된 사진'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          return Card(
            child: Image.file(
              imageFiles[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
