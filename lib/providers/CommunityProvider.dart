// ignore_for_file: file_names

import "package:flutter/material.dart";
import "package:seddit/models/Post.dart";
import "package:seddit/models/Community.dart";
import "package:seddit/services/CommunityService.dart";

class CommunityProvider extends ChangeNotifier {
  final CommunityService _communityService;

  CommunityProvider(this._communityService);

  Future<List<Community>> get communities => _communityService.readAll();

  Future<void> createCommunity(String name, String description, String category, List<String> members, List<String> admins) async {
    await _communityService.create(Community(name, description, category, members: members, admins: admins));
    notifyListeners();
  }

  void updateCommunity(Community community) async {
    await _communityService.update(community);
    notifyListeners();
  }

  Future<List<Community>> readAll() async {
    return await _communityService.readAll();
  }

  void deleteCommunity(String id) async {
    await _communityService.delete(id);
    notifyListeners();
  }

  Future<List<Post>> findPostsByCommunity(String name) async {
    List<Post> postsList = await _communityService.findPostsByCommunity(name);
    notifyListeners();
    return postsList;
  }

  void joinCommunity(String id, String userId) async {
    await _communityService.join(id, userId);
    notifyListeners();
  }

  void leaveCommunity(String id, String userId) async {
    await _communityService.leave(id, userId);
    notifyListeners();
  }

  void addAdmin(String id, String userId) async {
    await _communityService.addAdmin(id, userId);
    notifyListeners();
  }

  void removeAdmin(String id, String userId) async {
    await _communityService.removeAdmin(id, userId);
    notifyListeners();
  }

  Future<Community> findCommunityByID(String id) async {
    return await _communityService.findCommunityByID(id);
  }

  Future<Community> findCommunityByName(String name) async {
    return await _communityService.findCommunityByName(name);
  }

  Future<List<Community>> findCommunitiesByCategory(String category) async {
    return await _communityService.findCommunitiesByCategory(category);
  }

  void addPostToCommunity(String communityId, Post post) async {
    await _communityService.addPostToCommunity(communityId, post);
    notifyListeners();
  }

  void removePostFromCommunity(String communityId, String postId) async {
    await _communityService.removePostFromCommunity(communityId, postId);
    notifyListeners();
  }
}
