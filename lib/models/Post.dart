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

  // Setters for title and content
  void setTitle(String title) {
    _title = title;
  }

  void setContent(String content) {
    _content = content;
  }

  final String _id;
  String _title;
  String _content;
  final String _community;
  final String _author;
}
