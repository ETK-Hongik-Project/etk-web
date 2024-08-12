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
    required this.isDeleted,
    required this.replies,
  });

  final int commentId;
  final String content;
  final String commenterName;
  final String createdTime;
  final bool isDeleted;
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
      isDeleted: data['isDeleted'],
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

  return getComments(response);
}

Future<Comment> fetchComment(BuildContext context, int commentId) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/comments/$commentId'),
    headers: {
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);

  return getComment(response);
}

Comment getComment(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    dynamic commentData = jsonResponse['data']; // json 반환값중 'data' 값

    return Comment.from(commentData);
  } else {
    throw Exception('Failed to load comments');
  }
}

List<Comment> getComments(http.Response response) {
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

Future<Comment> deleteComment(BuildContext context, int commentId) async {
  final accessToken = await getAccessToken();

  final response = await http.delete(
    Uri.parse('http://$ip:8080/api/v1/comments/$commentId'),
    headers: {
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);

  if (response.statusCode == 200) {
    // 댓글 삭제 성공
  } else if (response.statusCode == 400) {
    logger.e(
        "Failed to delete comment (not user's commnet) : ${response.statusCode}");
    throw Exception("Failed to delete comment (not user's commnet)");
  } else if (response.statusCode == 404) {
    logger.e(
        "Failed to delete comment (invailid user or comment not existed) : ${response.statusCode}");
    throw Exception(
        'Failed to delete comment (invailid user or comment not existed)');
  } else {
    logger.e('Failed to delete comment : ${response.statusCode}');
    throw Exception('Failed to delete comment');
  }

  return getComment(response);
}

Future<void> addComment(
    BuildContext context, int postId, String content) async {
  final accessToken = await getAccessToken();

  final response = await http.post(
    Uri.parse('http://$ip:8080/api/v1/posts/$postId/comments'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode(
      {
        "content": content,
      },
    ),
  );

  checkTokenValidation(context, response);

  if (response.statusCode == 201) {
    // 댓글 등록 성공
  } else if (response.statusCode == 400) {
    logger.e('Failed to add comment (no content) : ${response.statusCode}');
    throw Exception('Failed to add comment (no content)');
  } else {
    logger.e('Failed to add comment : ${response.statusCode}');
    throw Exception('Failed to add comment');
  }
}

void addReply(BuildContext context, int commentId, String content) async {
  final accessToken = await getAccessToken();

  final response = await http.post(
    Uri.parse('http://$ip:8080/api/v1/comments/$commentId'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode(
      {
        "content": content,
      },
    ),
  );

  checkTokenValidation(context, response);

  if (response.statusCode == 201) {
    // 대댓글 등록 성공
  } else {
    logger.e('Failed to add comment : ${response.statusCode}');
    throw Exception('Failed to add comment');
  }
}
