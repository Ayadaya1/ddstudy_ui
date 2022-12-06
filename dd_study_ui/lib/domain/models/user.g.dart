// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      avatar: json['avatar'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      birthDate: json['birthDate'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'avatar': instance.avatar,
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'birthDate': instance.birthDate,
    };
