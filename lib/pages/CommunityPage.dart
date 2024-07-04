import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:seddit/models/Community.dart";
import "package:seddit/models/Post.dart";
import "package:seddit/providers/CommunityProvider.dart";

class CommunityPage extends StatefulWidget {
  final String communityId;

  const CommunityPage({super.key, required this.communityId});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String? filterTitle;
  bool sortAlphabetically = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              _showSortDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder<Community>(
        future: Provider.of<CommunityProvider>(context, listen: false).findCommunityByID(widget.communityId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Community not found"));
          } else {
            final community = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(community.name, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(community.description),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<Post>>(
                      future: _getPosts(community.id),
                      builder: (context, postSnapshot) {
                        if (postSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (postSnapshot.hasError) {
                          return Center(child: Text("Error: ${postSnapshot.error}"));
                        } else if (!postSnapshot.hasData || postSnapshot.data!.isEmpty) {
                          return const Center(child: Text("No posts found"));
                        } else {
                          final posts = postSnapshot.data!;
                          return ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return ListTile(
                                title: Text(post.title),
                                subtitle: Text(post.content),
                                trailing: Text(post.author),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<Post>> _getPosts(String communityId) async {
    List<Post> posts = Provider.of<CommunityProvider>(context, listen: false).findPostsByCommunity(communityId);

    if (filterTitle != null) {
      posts = posts.where((post) => post.title.contains(filterTitle!)).toList();
    }

    if (sortAlphabetically) {
      posts.sort((a, b) => a.title.compareTo(b.title));
    }

    return posts;
  }

  Future<void> _showSortDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sort Posts"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text("Sort Alphabetically"),
              value: sortAlphabetically,
              onChanged: (value) {
                setState(() {
                  sortAlphabetically = value!;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Posts by Title"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(hintText: "Enter title"),
              onChanged: (value) {
                filterTitle = value;
              },
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  filterTitle = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Clear Filter"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                });
              },
              child: const Text("Apply Filter"),
            ),
          ],
        ),
      ),
    );
  }
}
