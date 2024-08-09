import 'dart:convert';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/api/reply.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Comment {
  Comment({
    required this.commentId,
    required this.content,
    required this.commenterName,
    required this.createdTime,
    required this.replies,
  });

  final int commentId;
  final String content;
  final String commenterName;
  final String createdTime;
  final List<Reply> replies;

  factory Comment.from(Map<String, dynamic> data) {
    var repliesFromJson = data['replies'] as List;
    List<Reply> repliesList =
        repliesFromJson.map((reply) => Reply.from(reply)).toList();

    return Comment(
      commentId: data['commentId'],
      content: data['content'],
      commenterName: data['commenterName'],
      createdTime: data['createdTime'],
      replies: repliesList,
    );
  }
}

Future<List<Comment>> fetchAllComments(BuildContext context, int postId) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/posts/$postId/comments'),
    headers: {
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);

  return getPosts(response);
}

List<Comment> getPosts(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    List<dynamic> commentDatas = jsonResponse['data']; // json 반환값중 'data' 값

    return commentDatas
        .map((commentData) => Comment.from(commentData))
        .toList();
  } else {
    throw Exception('Failed to load comments');
  }
}
