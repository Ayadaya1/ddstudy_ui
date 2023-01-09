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
      subscriberCount: json['subscriberCount'] as int,
      subscriptionCount: json['subscriptionCount'] as int,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'avatar': instance.avatar,
      'name': instance.name,
      'email': instance.email,
      'birthDate': instance.birthDate,
      'subscriberCount': instance.subscriberCount,
      'subscriptionCount': instance.subscriptionCount,
    };
