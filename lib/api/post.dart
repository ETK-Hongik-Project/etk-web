import 'dart:convert';

import 'package:etk_web/api/auth/token.dart';
import 'package:etk_web/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  Post({
    required this.title,
    required this.postId,
    required this.content,
    required this.authorName,
    required this.createdTime,
  });

  final String title;
  final int postId;
  final String content;
  final String authorName;
  final String createdTime;

  factory Post.from(Map<String, dynamic> data) {
    return Post(
      title: data['title'],
      postId: data['postId'],
      content: data['content'],
      authorName: data['authorName'],
      createdTime: data['createdTime'],
    );
  }
}

Future<List<Post>> fetchAllPosts(BuildContext context, int boardId) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/boards/$boardId/posts'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );
  checkTokenValidation(context, response);

  return getPosts(response);
}

Future<List<Post>> fetchMyPosts(BuildContext context) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/posts'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);
  return getPosts(response);
}

Future<List<Post>> fetchCommentedPosts(BuildContext context) async {
  final accessToken = await getAccessToken();

  final response = await http.get(
    Uri.parse('http://$ip:8080/api/v1/commented-posts'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
  );

  checkTokenValidation(context, response);
  return getPosts(response);
}

List<Post> getPosts(http.Response response) {
  if (response.statusCode == 200) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> jsonResponse = json.decode(responseBody);
    List<dynamic> postDatas = jsonResponse['data']; // json 반환값중 'data' 값

    return postDatas.map((postData) => Post.from(postData)).toList();
  } else {
    throw Exception('Failed to load posts');
  }
}

void addPost(
  BuildContext context,
  int boardId,
  String title,
  String content,
  bool isAnonymous,
) async {
  final accessToken = await getAccessToken();

  final response = await http.post(
    Uri.parse('http://$ip:8080/api/v1/boards/$boardId/posts'),
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $accessToken",
    },
    body: jsonEncode({
      "title": title,
      "content": content,
      "isAnonymous": isAnonymous,
    }),
  );

  checkTokenValidation(context, response);

  if (response.statusCode == 201) {
    // 등록 성공
  } else {
    logger.e('Failed to create post : ${response.statusCode}');
    throw Exception('Failed to create post');
  }
}
