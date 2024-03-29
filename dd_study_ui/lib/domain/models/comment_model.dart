// Generated by https://quicktype.io

import 'package:dd_study_ui/domain/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable()
class CommentModel {
  final User author;
  final String created;
  final String text;
  final int likes;
  final String id;

  CommentModel({
    required this.author,
    required this.created,
    required this.text,
    required this.likes,
    required this.id
  });

  factory CommentModel.fromJson(Map<String,dynamic> json) => _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);
}
