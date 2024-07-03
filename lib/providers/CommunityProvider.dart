// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:seddit/models/Post.dart';
import 'package:seddit/models/Community.dart';
import 'package:seddit/services/CommunityService.dart';

class CommunityProvider extends ChangeNotifier {
  CommunityProvider(this._communityService);

  Future<List<Community>> get communities => _communityService.readAll();

  Future<void> createCommunity(String name, String description, String category, List<String> members, List<String> admins) async {
    await _communityService.create(Community(name, description, category, members: members, admins: admins));
    notifyListeners();
  }

  void updateCommunity(Community community) {
    _communityService.update(community).then((_) {
      notifyListeners();
    });
  }

  final CommunityService _communityService;

  List<Community> readAll() {
    _communityService.readAll().then((communities) {
      return communities;
    });

    return [];
  }

  void deleteCommunity(String id) {
    _communityService.delete(id).then((_) {
      notifyListeners();
    });
  }

  void joinCommunity(String id, String userId) {
    _communityService.join(id, userId).then((_) {
      notifyListeners();
    });
  }

  void leaveCommunity(String id, String userId) {
    _communityService.leave(id, userId).then((_) {
      notifyListeners();
    });
  }

  void addAdmin(String id, String userId) {
    _communityService.addAdmin(id, userId).then((_) {
      notifyListeners();
    });
  }

  void removeAdmin(String id, String userId) {
    _communityService.removeAdmin(id, userId).then((_) {
      notifyListeners();
    });
  }

  void findCommunity(String id) {
    _communityService.findCommunityByID(id).then((community) {
      return community;
    });
  }

  void findCommunityByName(String name) {
    _communityService.findCommunityByName(name).then((community) {
      return community;
    });
  }

  void findCommunitiesByCategory(String category) {
    _communityService.findCommunitiesByCategory(category).then((communities) {
      return communities;
    });
  }

  void addPostToCommunity(String communityId, Post post) {
    _communityService.addPostToCommunity(communityId, post).then((_) {
      notifyListeners();
    });
  }

  void removePostFromCommunity(String communityId, String postId) {
    _communityService.removePostFromCommunity(communityId, postId).then((_) {
      notifyListeners();
    });
  }
}
