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
  });

  final String name;
  final int boardId;
  final Future<List<Post>> Function(BuildContext, int) fetchPosts;
  final Widget? postCreationButton;

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Post>> _postsFuture; // fetchPosts를 저장하는 변수
  late final int boardId;

  @override
  void initState() {
    super.initState();
    boardId = widget.boardId;
    _postsFuture = widget.fetchPosts(context, boardId); // 초기 fetchPosts 호출
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture =
          widget.fetchPosts(context, boardId); // 새로고침 시 fetchPosts 다시 호출
    });
  }

  void _onSearch(String keyword) {
    if (keyword.isNotEmpty) {
      setState(() {
        _postsFuture = fetchKeywordedPosts(context, boardId, keyword);
      });
    } else {
      // 검색어가 비어있으면 기본 게시물 목록을 다시 로드
      setState(() {
        _postsFuture = widget.fetchPosts(context, boardId);
      });
    }
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
                  hintText: '검색어 입력...',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                onSubmitted: _onSearch, // 검색어 입력 완료 시 검색 수행
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
                    _onSearch(''); // 검색창이 닫힐 때 기본 게시물 목록으로 리셋
                  }
                });
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshPosts, // 새로고침 콜백
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
      future: _postsFuture, // fetchPosts를 사용하는 FutureBuilder
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
