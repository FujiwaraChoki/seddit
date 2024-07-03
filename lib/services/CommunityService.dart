// ignore_for_file: file_names

import 'package:seddit/models/Community.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    });

    await db.close();
  }

  Future<List<Community>> readAll() async {
    await _openDbIfNeeded();
    var communities = await db.collection("communities").find().toList();
    print(communities.length);

    // Convert the mapped iterable to a List<Community> with explicit type casting
    return communities.map<Community>((community) => Community(
      community["name"] as String,
      community["description"] as String,
      community["category"] as String,
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
          r'$set': {
            "name": community.name,
            "description": community.description,
            "members": community.members,
            "admins": community.admins,
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
    if (db == null) {
      db = await Db.create(
        'mongodb://${dotenv.env['MONGO_HOST']}:${dotenv.env['MONGO_PORT']}/${dotenv.env['MONGO_DB']}',
      );
      await db.open();
    }
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
          r'$set': {
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
          r'$set': {
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
          r'$set': {
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
          r'$set': {
            "admins": _communities[index].admins,
          }
        },
      );

      await db.close();
    }
  }

  Future<Community> findCommunityByID(String id) async {
    await _openDbIfNeeded();
    var community = await db.collection("communities").findOne(where.eq("id", id));

    return Community(
      community["name"] as String,
      community["description"] as String,
      community["category"] as String,
      id: community["id"] as String,
      members: List<String>.from(community["members"] as List),
      admins: List<String>.from(community["admins"] as List),
    );
  }
}