// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      text: json['text'] as String,
      authorId: json['authorId'] as String?,
      likes: json['likes'] as int,
      comments: json['comments'] as int,
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'authorId': instance.authorId,
      'likes': instance.likes,
      'comments': instance.comments,
    };
