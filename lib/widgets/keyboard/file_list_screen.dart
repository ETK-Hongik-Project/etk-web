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
  final Set<FileSystemEntity> _selectedFiles = {};
  bool _isSelectionMode = false;

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

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFiles.isEmpty) {
      // 선택된 파일이 없으면 선택 모드를 종료
      setState(() {
        _isSelectionMode = false;
      });
      return;
    }

    // 삭제 확인 다이얼로그 표시
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                '삭제 확인',
                style: TextStyle(
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text('${_selectedFiles.length}개의 대화 내역을 삭제하시겠습니까?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('삭제',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmDelete) {
      return;
    }

    for (var file in _selectedFiles) {
      if (file is File) {
        try {
          await file.delete();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting file: $e')),
          );
          return;
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedFiles.length}개 대화 내역이 제거되었습니다.')),
    );

    setState(() {
      _selectedFiles.clear();
      _isSelectionMode = false;
    });
    _loadFiles();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedFiles.clear();
      }
    });
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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(_isSelectionMode ? Icons.delete : Icons.delete_outline,
                  color: _isSelectionMode && _selectedFiles.isNotEmpty
                      ? Colors.red
                      : null),
              onPressed: _isSelectionMode
                  ? _deleteSelectedFiles
                  : _toggleSelectionMode,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          final fileName = (file.path.split('/').last).split('.').first;
          final isSelected = _selectedFiles.contains(file);

          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                fileName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
                  color: isSelected ? Colors.red : null,
                ),
              ),
            ),
            leading: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedFiles.add(file);
                        } else {
                          _selectedFiles.remove(file);
                        }
                      });
                    },
                  )
                : null,
            onTap: () async {
              if (_isSelectionMode) {
                setState(() {
                  if (isSelected) {
                    _selectedFiles.remove(file);
                  } else {
                    _selectedFiles.add(file);
                  }
                });
              } else if (file is File) {
                String contents = await file.readAsString();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.white,
                    title: const Text(
                      '대화 내용',
                      style: TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        contents,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text('확인'),
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
