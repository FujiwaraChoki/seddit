// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seddit/models/Community.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:seddit/providers/PostsProvider.dart';
import 'package:seddit/providers/CommunityProvider.dart';

class Newpostpage extends StatefulWidget {
  const Newpostpage({super.key});

  @override
  _NewpostpageState createState() => _NewpostpageState();
}

class _NewpostpageState extends State<Newpostpage> {
  String _title = "";
  String _content = "";
  String _base64Image = "";
  late String _selectedCommunity;
  final TextEditingController _contentController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _insertText(String text) {
    final textSelection = _contentController.selection;
    final newText = _contentController.text.replaceRange(
      textSelection.start,
      textSelection.end,
      text,
    );

    setState(() {
      _content = newText;
      _contentController.text = newText;
      _contentController.selection = textSelection.copyWith(
        baseOffset: textSelection.start + text.length,
        extentOffset: textSelection.start + text.length,
      );
    });
  }

  Future<void> _createPost(BuildContext context) async {
    var user = FirebaseAuth.instance.currentUser;
    var author = {
      "id": user!.uid,
      "name": user.displayName,
      "email": user.email,
    };
    if (_base64Image != "") {
      _content += "![Image](data:image/png;base64,$_base64Image)";
    }

    // Show posting dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Posting..."),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );

    // Create the post
    await Provider.of<PostsProvider>(context, listen: false)
        .createPost(_title, _content, json.encode(author), _selectedCommunity!);

    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Post"),
        actions: [
          ElevatedButton(
            onPressed: () => _createPost(context),
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
            ),
            child: const Text("Post"),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<CommunityProvider>(
              builder: (context, communityProvider, child) {
                return FutureBuilder<List<Community>>(
                  future: communityProvider.communities,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text("Error loading communities");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text("No communities available");
                    } else {
                      return DropdownButton<String>(
                        value: _selectedCommunity,
                        hint: const Text("Select Community"),
                        items: snapshot.data!.map((community) {
                          return DropdownMenuItem<String>(
                            value: community.name,
                            child: Text(community.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCommunity = value!;
                          });
                        },
                      );
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: "Title"),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: "Content"),
              maxLines: 5,
              onChanged: (value) {
                setState(() {
                  _content = value;
                });
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () {
                    _insertText("\n- Item 1\n- Item 2\n- Item 3\n");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {
                    _insertText("[Link Text](http://example.com)");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
