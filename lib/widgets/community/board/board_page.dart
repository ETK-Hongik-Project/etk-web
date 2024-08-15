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
    this.postCreationButton,
    this.searchController,
  });

  final String name;
  final int boardId;
  final Future<List<Post>> Function(BuildContext, int) fetchPosts;
  final Widget? postCreationButton;
  final TextEditingController? searchController;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  bool _isSearching = false;
  late Future<List<Post>> _postsFuture;
  late final int boardId;

  @override
  void initState() {
    super.initState();
    boardId = widget.boardId;
    _postsFuture = widget.fetchPosts(context, boardId);
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = widget.fetchPosts(context, boardId);
    });
  }

  void _onSearch(String keyword) {
    if (keyword.isNotEmpty) {
      setState(() {
        _postsFuture = fetchKeywordedPosts(context, boardId, keyword);
      });
    } else {
      setState(() {
        _postsFuture = widget.fetchPosts(context, boardId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching && widget.searchController != null
            ? TextField(
                controller: widget.searchController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  hintText: '검색어 입력...',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                onSubmitted: _onSearch,
              )
            : Text(
                widget.name,
                style: const TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 24),
              ),
        actions: widget.searchController != null
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon:
                        Icon(_isSearching ? Icons.close : Icons.search_rounded),
                    iconSize: 32,
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          widget.searchController!.clear();
                          _onSearch('');
                        }
                      });
                    },
                  ),
                ),
              ]
            : null, // 검색 컨트롤러가 없으면 actions를 표시하지 않음
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshPosts,
                  child:
                      SelectedPosts(postsFuture: _postsFuture, widget: widget),
                ),
              ),
            ],
          ),
          if (widget.postCreationButton != null) widget.postCreationButton!,
        ],
      ),
    );
  }
}

class SelectedPosts extends StatelessWidget {
  const SelectedPosts({
    super.key,
    required Future<List<Post>> postsFuture,
    required this.widget,
  }) : _postsFuture = postsFuture;

  final Future<List<Post>> _postsFuture;
  final BoardPage widget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
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
    );
  }
}
