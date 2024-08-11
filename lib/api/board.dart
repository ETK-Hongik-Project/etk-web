import 'dart:convert';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Board {
  Board({
    required this.name,
    required this.boardId,
  });

  final String name;
  final int boardId;

  factory Board.from(Map<String, dynamic> data) {
    return Board(
      name: data['name'],
      boardId: data['boardId'],
    );
  }
}

Future<List<Board>> fetchAllBoards(BuildContext context) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/boards'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);

  return getBoards(response);
}

Future<List<Board>> fetchBoardsByKeyword(
    BuildContext context, String keyword) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/boards?keyword=$keyword'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);
  return getBoards(response);
}

Future<Board> fetchBoardByBoardId(BuildContext context, String boardId) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/boards/$boardId'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    dynamic boardData = jsonResponse['data']; // json 반환값중 'data' 값

    return Board.from(boardData);
  } else {
    throw Exception('Failed to load board');
  }
}

List<Board> getBoards(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    List<dynamic> boardDatas = jsonResponse['data']; // json 반환값중 'data' 값

    return boardDatas.map((boardData) => Board.from(boardData)).toList();
  } else {
    throw Exception('Failed to load boards');
  }
}
