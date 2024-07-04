// ignore_for_file: file_names

import "package:seddit/models/Post.dart";
import "package:mongo_dart/mongo_dart.dart";
import "package:seddit/models/Community.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";

class CommunityService {
  var db;

  Future<void> create(Community community) async {
    await _openDbIfNeeded();
    _communities.insert(0, community);

    await db.collection("communities").insertOne({
      "_id": community.id,
      "id": community.id,
      "name": community.name,
      "category": community.category,
      "description": community.description,
      "members": community.members,
      "admins": community.admins,
      "posts": community.posts ?? [],
    });

    await db.close();
  }

  Future<List<Community>> readAll() async {
    await _openDbIfNeeded();
    var communities = await db.collection("communities").find().toList();

    // Convert the mapped iterable to a List<Community> with explicit type casting
    return communities.map<Community>((community) => Community(
      community["name"] as String,
      community["description"] as String,
      community["category"] as String,
      posts: List<String>.from(community["posts"] ?? []),
      id: community["id"] as String,
      members: List<String>.from(community["members"] as List),
      admins: List<String>.from(community["admins"] as List),
    )).toList();
  }

  Future<void> update(Community community) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == community.id);

    if (index != -1) {
      _communities[index] = community;

      await db.collection("communities").update(
        where.eq("id", community.id),
        {
          r"$set": {
            "name": community.name,
            "description": community.description,
            "members": community.members,
            "admins": community.admins,
            "category": community.category,
            "posts": community.posts ?? [],
          }
        },
      );

      await db.close();
    }
  }

  Future<void> delete(String id) async {
    await _openDbIfNeeded();
    _communities.removeWhere((element) => element.id == id);

    await db.collection("communities").remove(where.eq("id", id));

    await db.close();
  }

  Future<void> _openDbIfNeeded() async {
    db ??= await Db.create(dotenv.env["MONGODB_URI"]!);
    if (!db.isConnected) {
      await db.open();
    }
  }

  Future<List<Post>> findPostsByCommunity(String name) async {
    await _openDbIfNeeded();
    var coll = db.collection("communities");
    print("Finding posts for community: $name");
    var community = await coll.findOne(where.eq("name", name));
    if (community == null) {
      return [];
    }

    var postIds = community["posts"];
    print(
      "Post IDs: $postIds"
    );
    var posts = [];

    for (var postId in postIds) {
      var coll_2 = db.collection("posts");
      var post = await coll_2.findOne(where.eq("id", postId));
      if (post != null) {
        print(post);
        posts.add(post);
      }
    }

    await db.close();

    return posts.map<Post>((post) => Post(
      post["title"] as String,
      post["content"] as String,
      post["community"] as String,
      author: post["author"] as String,
      id: post["id"] as String,
    )).toList();
  }

  List<Community> _communities = [];

  List<Community> get communities => _communities;

  CommunityService() {
    readAll().then((communities) => _communities = communities);
  }

  Future<void> join(String id, String userId) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == id);

    if (index != -1) {
      _communities[index].members.add(userId);

      await db.collection("communities").update(
        where.eq("id", id),
        {
          r"$set": {
            "members": _communities[index].members,
          }
        },
      );

      await db.close();
    }
  }

  Future<void> leave(String id, String userId) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == id);

    if (index != -1) {
      _communities[index].members.remove(userId);

      await db.collection("communities").update(
        where.eq("id", id),
        {
          r"$set": {
            "members": _communities[index].members,
          }
        },
      );

      await db.close();
    }
  }

  Future<void> addAdmin(String id, String userId) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == id);

    if (index != -1) {
      _communities[index].admins.add(userId);

      await db.collection("communities").update(
        where.eq("id", id),
        {
          r"$set": {
            "admins": _communities[index].admins,
          }
        },
      );

      await db.close();
    }
  }

  Future<void> removeAdmin(String id, String userId) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == id);

    if (index != -1) {
      _communities[index].admins.remove(userId);

      await db.collection("communities").update(
        where.eq("id", id),
        {
          r"$set": {
            "admins": _communities[index].admins,
          }
        },
      );

      await db.close();
    }
  }

  Future<Community> findCommunityByID(String name) async {
    await _openDbIfNeeded();
    var coll = db.collection("communities");
    var community = await coll.findOne(where.eq("name", name));

    print(community);

    return Community(
      community["name"] as String,
      community["description"] as String,
      community["category"] as String,
      id: community["id"] as String,
      members: List<String>.from(community["members"] as List),
      admins: List<String>.from(community["admins"] as List),
      posts: List<String>.from(community["posts"] as List),
    );
  }

  Future<Community> findCommunityByName(String name) async {
    await _openDbIfNeeded();
    var coll = db.collection("communities");
    var community = await coll.findOne(where.eq("name", name));

    return Community(
      community["name"] as String,
      community["description"] as String,
      community["category"] as String,
      id: community["id"] as String,
      members: List<String>.from(community["members"] as List),
      admins: List<String>.from(community["admins"] as List),
      posts: List<String>.from(community["posts"] ?? []),
    );
  }

  Future<List<Community>> findCommunitiesByCategory(String category) async {
    await _openDbIfNeeded();
    var coll = db.collection("communities");
    var communities = await coll.find(where.eq("category", category)).toList();

    return communities.map<Community>((community) => Community(
      community["name"] as String,
      community["description"] as String,
      community["category"] as String,
      id: community["id"] as String,
      members: List<String>.from(community["members"] as List),
      admins: List<String>.from(community["admins"] as List),
      posts: List<String>.from(community["posts"] ?? []),
    )).toList();
  }

  Future<void> addPostToCommunity(String id, Post post) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == id);

    if (index != -1) {
      _communities[index].posts.add(post.id);

      await db.collection("communities").update(
        where.eq("id", id),
        {
          r"$set": {
            "posts": _communities[index].posts,
          }
        },
      );

      await db.close();
    }
  }

  Future<void> removePostFromCommunity(String id, String postId) async {
    await _openDbIfNeeded();
    var index = _communities.indexWhere((element) => element.id == id);

    if (index != -1) {
      _communities[index].posts.remove(postId);

      await db.collection("communities").update(
        where.eq("id", id),
        {
          r"$set": {
            "posts": _communities[index].posts,
          }
        },
      );

      await db.close();
    }
  }
}
