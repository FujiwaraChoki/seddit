import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seddit/models/Post.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:seddit/providers/PostsProvider.dart';
import 'package:shake_detector_android/shake_detector_android.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

String cleanContent(String content, bool fromPostPage) {
  String cleanedContent = content;
  
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
  final storage = FlutterSecureStorage();

  PostCard(this.post, {this.fromPostPage = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void startShakeDetection() async {
      final exitOnShake = await storage.read(key: "exitOnShake");
      ShakeDetectorAndroid.startListening((e) {
        if (exitOnShake == "true") {
          if (fromPostPage) {
            Navigator.pop(context);
          } else {
            Navigator.popUntil(context, ModalRoute.withName("/"));
          }
        }
      });
    }

    startShakeDetection();

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

  void _editPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(post: post),
      ),
    );
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
        title: Text("${post.title} - s/${post.community}"),
        actions: [
          if (currentUser!.uid == author["id"]) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editPost(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
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
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class EditPostPage extends StatefulWidget {
  final Post post;

  const EditPostPage({required this.post, super.key});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: cleanContent(widget.post.content, true));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _savePost() {
    final newPost = Post(
      id: widget.post.id,
      _titleController.text,
      _contentController.text,
      widget.post.community,
      author: widget.post.author,
    );

    Provider.of<PostsProvider>(context, listen: false).updatePost(newPost);
    widget.post.setTitle(_titleController.text);
    widget.post.setContent(_contentController.text);

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      setState(() {
        final newContent = "${_contentController.text}\n![Image](data:image/png;base64,$base64Image)";
        _contentController.text = newContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Content",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16.0),
            AssetsSection(post: widget.post, fromEditPage: true, pickImage: _pickImage),
          ],
        ),
      ),
    );
  }
}

class AssetsSection extends StatelessWidget {
  final Post post;
  final bool fromEditPage;
  final Future<void> Function()? pickImage;

  const AssetsSection({
    required this.post,
    required this.fromEditPage,
    this.pickImage,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrls = RegExp(r"!\[.*\]\((.*)\)").allMatches(post.content).map((match) => match.group(1)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrls.isNotEmpty || fromEditPage) ...[
          const SizedBox(height: 16.0),
          const Text(
            "Assets",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          if (fromEditPage && pickImage != null)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: pickImage,
            ),
          for (var url in imageUrls)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Image.memory(base64Decode(url!.replaceAll("data:image/png;base64,", "")), fit: BoxFit.cover),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
