import 'package:etk_web/api/board.dart';
import 'package:etk_web/api/post.dart';
import 'package:etk_web/widgets/community/board/board_button.dart';
import 'package:etk_web/widgets/community/board/board_page.dart';
import 'package:flutter/material.dart';

class CommunityMainPage extends StatelessWidget {
  const CommunityMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '커뮤니티',
          style: TextStyle(
              color: Colors.deepPurpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          BoardPageSelectionButton(
            buttonName: "내가 쓴 글",
            pageWidget: BoardPage(
              name: "내가 쓴 글",
              boardId: 0,
              fetchPosts: (context, boardId) => fetchMyPosts(context),
            ),
          ),
          BoardPageSelectionButton(
            buttonName: "댓글 단 글",
            pageWidget: BoardPage(
              name: "댓글 단 글",
              boardId: 0,
              fetchPosts: (context, boardId) => fetchCommentedPosts(context),
            ),
          ),
          const SizedBox(height: 30),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 15),
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text(
                  "게시판",
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          FutureBuilder<List<Board>>(
            future: fetchAllBoards(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No boards available'));
              } else {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          BoardPageSelectionButton(
                            buttonName: snapshot.data![index].name,
                            pageWidget: BoardPage(
                              name: snapshot.data![index].name,
                              boardId: snapshot.data![index].boardId,
                              fetchPosts: fetchAllPosts,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
