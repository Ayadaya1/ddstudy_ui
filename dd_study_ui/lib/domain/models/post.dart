

import 'package:dd_study_ui/domain/db_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post implements DbModel
{
  @override 
  final String id;
  final String text;
  final String? authorId;

  Post(
    {
      required this.id,
      required this.text,
      this.authorId,
    }
  );

  factory Post.fromJson(Map<String,dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);

  @override 
  Map<String,dynamic> toMap() => _$PostToJson(this);

  factory Post.fromMap(Map<String, dynamic> map) => _$PostFromJson(map);

  Post copyWith({
    String? id,
    String? description,
    String? authorId,
  }) {
    return Post(
      id: id ?? this.id,
      text: description ?? this.text,
      authorId: authorId ?? this.authorId,
    );
}
}