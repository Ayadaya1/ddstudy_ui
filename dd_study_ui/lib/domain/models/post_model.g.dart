// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as String,
      attaches: (json['attaches'] as List<dynamic>)
          .map((e) => PostContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      text: json['text'] as String?,
      created: json['created'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      comments: json['comments'] as int,
      likes: json['likes'] as int,
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'attaches': instance.attaches,
      'id': instance.id,
      'text': instance.text,
      'created': instance.created,
      'user': instance.user,
      'comments': instance.comments,
      'likes': instance.likes,
    };
