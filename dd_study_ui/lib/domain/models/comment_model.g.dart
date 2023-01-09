// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      created: json['created'] as String,
      text: json['text'] as String,
      likes: json['likes'] as int,
    );

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'author': instance.author,
      'created': instance.created,
      'text': instance.text,
      'likes': instance.likes,
    };
