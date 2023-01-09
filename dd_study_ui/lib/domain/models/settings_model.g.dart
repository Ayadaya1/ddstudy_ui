// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettingsModel _$PrivacySettingsModelFromJson(
        Map<String, dynamic> json) =>
    PrivacySettingsModel(
      avatarAccess: json['avatarAccess'] as int,
      postAccess: json['postAccess'] as int,
      messageAccess: json['messageAccess'] as int,
      commentAccess: json['commentAccess'] as int,
    );

Map<String, dynamic> _$PrivacySettingsModelToJson(
        PrivacySettingsModel instance) =>
    <String, dynamic>{
      'avatarAccess': instance.avatarAccess,
      'postAccess': instance.postAccess,
      'messageAccess': instance.messageAccess,
      'commentAccess': instance.commentAccess,
    };
