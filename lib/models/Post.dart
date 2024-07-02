// ignore: file_names
import "package:uuid/uuid.dart";

class Post {
  Post(this._title, this._content, {
    String author = "Anon", String? id
  }) : _author = author, _id = id ?? Uuid().v4();

  String get id => _id;
  String get title => _title;
  String get content => _content;
  String get author => _author;

  final String _id;
  final String _title;
  final String _content;
  final String _author;
}
