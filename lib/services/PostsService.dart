// ignore_for_file: file_names

import "package:seddit/models/Post.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

class PostsService {
  var db;

  Future<void> create(Post post) async {
    await _openDbIfNeeded();
    _posts.insert(0, post);

    await db.collection("posts").insertOne({
      "_id": post.id,
      "id": post.id,
      "title": post.title,
      "content": post.content,
      "community": post.community,
      "author": post.author,
    });

    // find community and add to posts array
    await db.collection("communities").update(
      where.eq("name", post.community),
      modify.push("posts", post.id),
    );

    await db.close();
  }

  Future<List<Post>> readAll() async {
    await _openDbIfNeeded();
    var posts = await db.collection("posts").find().toList();
    print(posts.length);

    // Convert the mapped iterable to a List<Post> with explicit type casting
    return posts.map<Post>((post) => Post(
      post["title"] as String,
      post["content"] as String,
      post["community"] as String,
      author: post["author"] as String,
      id: post["id"] as String,
    )).toList();
  }

  Future<void> update(Post post) async {
    await _openDbIfNeeded();
    
    await db.collection("posts").update(
      where.eq("id", post.id),
      modify.set("title", post.title),
    );

    await db.collection("posts").update(
      where.eq("id", post.id),
      modify.set("content", post.content),
    );
  }

  Future<void> delete(String id) async {
    await _openDbIfNeeded();
    _posts.removeWhere((element) => element.id == id);

    await db.collection("posts").remove(where.eq("id", id));
    await db.close();
  }

  Future<void> _openDbIfNeeded() async {
    db ??= await Db.create(dotenv.env["MONGODB_URI"]!);
    if (!db.isConnected) {
      await db.open();
    }
  }

  // ignore: prefer_final_fields
  List<Post> _posts = [];
}
