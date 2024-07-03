// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:seddit/models/Post.dart';
import 'package:seddit/services/PostsService.dart';

class PostsProvider extends ChangeNotifier {
  PostsProvider(this._postsService);

  Future<List<Post>> get posts => _postsService.readAll();

  Future<void> createPost(String title, String content, String author) async {
    await _postsService.create(Post(title, content, author: author));
    notifyListeners();
  }

  void updatePost(Post post) {
    _postsService.update(post).then((_) {
      notifyListeners();
    });
  }

  final PostsService _postsService;

  List<Post> readAll() {
    _postsService.readAll().then((posts) {
      return posts;
    });

    return [];
  }

  void deletePost(String id) {
    _postsService.delete(id).then((_) {
      notifyListeners();
    });
  }
}
