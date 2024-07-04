import "dart:convert";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:seddit/models/Post.dart";
import "package:flutter_markdown/flutter_markdown.dart";
import "package:seddit/providers/PostsProvider.dart";
import "package:shake_detector_android/shake_detector_android.dart";
import "package:firebase_auth/firebase_auth.dart"; // Import Firebase Auth
import "package:flutter_secure_storage/flutter_secure_storage.dart";

String cleanContent(String content, bool fromPostPage) {
  String cleanedContent = content;
  // Remove markdown image tags if fromPostPage
  if (!fromPostPage) {
    cleanedContent = cleanedContent.replaceAll(RegExp(r"!\[.*\]\(.*\)"), "");
  }

  if (cleanedContent.length > 43) {
    cleanedContent = "${cleanedContent.substring(0, 40)}...";
  }

  return cleanedContent;
}

class PostCard extends StatelessWidget {
  final Post post;
  final bool fromPostPage;
  final storage = new FlutterSecureStorage();

  PostCard(this.post, {this.fromPostPage = false, super.key});

  @override
  Widget build(BuildContext context){
    Future<String?> readValue(String key) async {
      return await storage.read(key: key);
    }

    ShakeDetectorAndroid.startListening((e) {
      if (readValue("exitOnShake") == "true") {
        // Exit
        if (fromPostPage) {
          Navigator.pop(context);
        } else {
          Navigator.popUntil(context, ModalRoute.withName("/"));
        }
      }
    });

    Map author = json.decode(post.author);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostPage(post: post),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(15.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "by ${author["name"]}",
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              MarkdownBody(
                data: cleanContent(post.content, fromPostPage),
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16.0),
                  blockSpacing: 8.0,
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  code: TextStyle(
                    fontFamily: "monospace",
                    fontSize: 14.0,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostPage extends StatelessWidget {
  final Post post;

  const PostPage({required this.post, super.key});

  void _deletePost(BuildContext context) {
    Provider.of<PostsProvider>(context, listen: false).deletePost(post.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final author = json.decode(post.author);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(post.title),
        actions: [
          if (currentUser!.uid == author["id"])
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Show a confirmation dialog before deleting
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Delete Post"),
                      content: const Text("Are you sure you want to delete this post?"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Delete"),
                          onPressed: () {
                            _deletePost(context);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                "by ${author["name"]}",
                style: TextStyle(
                  fontSize: 16.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              MarkdownBody(
                data: post.content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16.0),
                  blockSpacing: 8.0,
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  code: TextStyle(
                    fontFamily: "monospace",
                    fontSize: 14.0,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
