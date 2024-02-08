// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_drive_windows_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleDriveWindowsMetadata _$GoogleDriveMetadataFromJson(
        Map<String, dynamic> json) =>
    GoogleDriveWindowsMetadata(
      modifiedTime: json['modifiedTime'] == null
          ? null
          : DateTime.parse(json['modifiedTime'] as String),
      version: json['version'] as String?,
      size: json['size'] as int,
    );

Map<String, dynamic> _$GoogleDriveMetadataToJson(
        GoogleDriveWindowsMetadata instance) =>
    <String, dynamic>{
      'modifiedTime': instance.modifiedTime?.toIso8601String(),
      'version': instance.version,
      'size': instance.size,
    };
