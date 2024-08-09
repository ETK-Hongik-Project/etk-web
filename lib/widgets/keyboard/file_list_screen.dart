import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileListScreen extends StatefulWidget {
  const FileListScreen({super.key});

  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    setState(() {
      _files = directory
          .listSync()
          .where((file) => file.path.endsWith('.txt'))
          .toList();
    });
  }

  Future<void> _deleteFile(File file) async {
    try {
      await file.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.path.split('/').last} 제거됨')),
      );
      _loadFiles(); // Refresh the file list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '대화 기록',
          style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                (file.path.split('/').last).split('.').first,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete,
              ),
              onPressed: () async {
                if (file is File) {
                  _deleteFile(file);
                }
              },
            ),
            onTap: () async {
              // 파일 내용을 읽어오는 예제
              if (file is File) {
                String contents = await file.readAsString();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('File Contents'),
                    content: Text(contents),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FileListScreen(),
  ));
}
