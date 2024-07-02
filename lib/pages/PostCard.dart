// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:seddit/models/Post.dart';
import 'package:seddit/providers/PostsProvider.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool fromNav;

  const PostCard(this.post, {this.fromNav = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostCard(post, fromNav: true),
          ),
        );
      },
      child: SizedBox(
        height: 10,
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
                if (fromNav)
                  FloatingActionButton(
                    // Put on bottom 
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
