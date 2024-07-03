import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seddit/providers/PostsProvider.dart';

class Newpostpage extends StatefulWidget {
  @override
  _NewpostpageState createState() => _NewpostpageState();
}

class _NewpostpageState extends State<Newpostpage> {
  String _title = '';
  String _content = '';
  String _base64Image = '';

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

  Future<void> _createPost(BuildContext context) async {
    final box = GetStorage();
    var author = box.read("username") ?? "Anon";
    if (_base64Image != "") {
      _content += "![Image](data:image/png;base64,$_base64Image)";
    }

    // Show posting dialog
    showDialog(
      // The user CANNOT close this dialog by pressing outside it
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Posting...'),
                SizedBox(height: 16),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );

    // Create the post
    await Provider.of<PostsProvider>(context, listen: false).createPost(_title, _content, author);

    // Close the posting dialog
    Navigator.of(context).pop();
    // Navigate back
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.link),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
