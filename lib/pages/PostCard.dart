// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seddit/models/Post.dart';
import 'package:seddit/providers/PostsProvider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shake/shake.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool fromNav;

  const PostCard(this.post, {this.fromNav = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ShakeDetector detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        Provider.of<PostsProvider>(context, listen: false).deletePost(post.id);
        if (fromNav) {
          Navigator.pop(context);
        }
      },
    );
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostCard(post, fromNav: true),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(30.0),
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
                'by ${post.author}',
                style: TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16.0),
              MarkdownBody(
                data: post.content,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 16.0),
                  blockSpacing: 8.0,
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
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

  const PostPage({required this.post, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(post.title),
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
                'by ${post.author}',
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
                  p: TextStyle(fontSize: 16.0),
                  blockSpacing: 8.0,
                  codeblockDecoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  code: TextStyle(
                    fontFamily: 'monospace',
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
