import 'package:uuid/uuid.dart';

class Community {
  Community(this._name, this._description, this._category, {String? id, List<String>? members, List<String>? admins, List<String>? posts}) {
    _id = id ?? Uuid().v4();
  }

  String get id => _id;
  String get name => _name;
  String get description => _description;
  String get category => _category;
  List<String> get members => _members;
  List<String> get admins => _admins;
  List<String> get posts => _posts;
  
  late String _id;
  final String _name;
  final String _description;
  final String _category;
  final List<String> _members = [];
  final List<String> _admins = [];
  final List<String> _posts = [];
}