import 'package:etk_web/api/post.dart';
import 'package:etk_web/widgets/community/post/post_button.dart';
import 'package:etk_web/widgets/community/post/post_page.dart';
import 'package:flutter/material.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({
    super.key,
    required this.name,
    required this.boardId,
    required this.fetchPosts,
  });

  final String name;
  final int boardId;
  final Future<List<Post>> Function(BuildContext, int) fetchPosts;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late final int boardId;
  bool hasMorePosts = true; // 더 많은 게시물이 있는지 여부를 추적하는 상태 변수

  @override
  void initState() {
    super.initState();
    boardId = widget.boardId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              )
            : Text(
                widget.name,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
              iconSize: 32,
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: widget.fetchPosts(context, boardId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No posts available'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          PostPageSelectionButton(
                            title: snapshot.data![index].title,
                            authorName: snapshot.data![index].authorName,
                            createdTime: snapshot.data![index].createdTime,
                            pageWidget: PostPage(
                              boardName: widget.name,
                              title: snapshot.data![index].title,
                              postId: snapshot.data![index].postId,
                              content: snapshot.data![index].content,
                              authorName: snapshot.data![index].authorName,
                              createdTime: snapshot.data![index].createdTime,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
