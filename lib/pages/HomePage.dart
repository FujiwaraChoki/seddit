// ignore: file_names
// ignore: avoid_print
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seddit/MenuSidebar.dart';
import 'package:seddit/models/Post.dart';
import 'package:seddit/pages/NewPostPage.dart';
import 'package:seddit/pages/PostCard.dart';
import 'package:seddit/pages/CommunitiesPage.dart';
import 'package:seddit/providers/PostsProvider.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Create a TextEditingController
  final TextEditingController _searchController = TextEditingController();
  Future<List<Post>>? _filteredPosts;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPosts = Provider.of<PostsProvider>(context, listen: false)
          .posts
          .then((posts) => posts.where((post) => post.title.toLowerCase().contains(query)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      drawer: const Sidebar(),
      persistentFooterButtons: [
        IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.people),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunitiesPage()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Newpostpage()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            // Redirect to /profile route with option to return
            Navigator.pushNamed(context, "/profile");
          },
        ),
      ],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Logo(),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    print("Search content: ${_searchController.text}");
                    _onSearchChanged();
                  },
                  icon: const Icon(Icons.search),
                ),
                SizedBox(
                  width: 200, // You can adjust the width as needed
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search posts",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: _PostsList(filteredPosts: _filteredPosts),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage("assets/images/logo.png"),
      height: 50,
    );
  }
}

String cutText(String text, int length) {
  if (text.length > length) {
    return "${text.substring(0, length)}...";
  } else {
    return text;
  }
}

class _PostsList extends StatelessWidget {
  final Future<List<Post>>? filteredPosts;

  const _PostsList({this.filteredPosts});

  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        final postsFuture = filteredPosts ?? postsProvider.posts;

        return FutureBuilder<List<Post>>(
          future: postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // or any loading indicator
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text("No posts available"); // or another fallback UI
            } else {
              var posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var post = posts[index];
                  return SizedBox(
                    height: 200,
                    child: PostCard(post),
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
