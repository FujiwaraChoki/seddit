// ignore: file_names
import "package:uuid/uuid.dart";

class Post {
  Post(this._title, this._content, this._community, {
    String author = "Anon", String? id
  }) : _author = author, _id = id ?? const Uuid().v4();

  String get id => _id;
  String get title => _title;
  String get content => _content;
  String get community => _community;
  String get author => _author;

  final String _id;
  final String _title;
  final String _content;
  final String _community;
  final String _author;
}
