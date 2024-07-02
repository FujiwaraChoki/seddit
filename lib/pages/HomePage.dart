// ignore: file_names
// ignore: avoid_print
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seddit/MenuSidebar.dart';
import 'package:seddit/models/Post.dart';
import 'package:seddit/pages/NewPostPage.dart';
import 'package:seddit/pages/PostCard.dart';
import 'package:seddit/pages/CommunitiesPage.dart';
import 'package:seddit/providers/PostsProvider.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  // Create a TextEditingController
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
      drawer: Sidebar(),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => Communitiespage()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Newpostpage()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage()));
          },
        ),
      ],
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Logo(),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    print("Search content: ${_searchController.text}");
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
        child: _PostsList(),
      ),
    );
  }
}

class Logo extends StatelessWidget {
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
    return text.substring(0, length) + "...";
  } else {
    return text;
  }
}

class _PostsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PostsProvider>(
      builder: (context, postsProvider, child) {
        return FutureBuilder<List<Post>>(
          future: postsProvider.posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // or any loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No posts available'); // or another fallback UI
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

