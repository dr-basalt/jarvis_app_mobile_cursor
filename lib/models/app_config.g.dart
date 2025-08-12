// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppConfigAdapter extends TypeAdapter<AppConfig> {
  @override
  final int typeId = 0;

  @override
  AppConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppConfig(
      openaiApiKey: fields[0] as String?,
      claudeApiKey: fields[1] as String?,
      ollamaUrl: fields[2] as String?,
      n8nWebhookUrl: fields[3] as String,
      defaultProvider: fields[4] as String,
      defaultAgent: fields[5] as String,
      isDarkMode: fields[6] as bool,
      userEmail: fields[7] as String?,
      isAuthenticated: fields[8] as bool,
      authToken: fields[9] as String?,
      refreshToken: fields[10] as String?,
      provider: fields[11] as String?,
      userName: fields[12] as String?,
      userPhotoUrl: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppConfig obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.openaiApiKey)
      ..writeByte(1)
      ..write(obj.claudeApiKey)
      ..writeByte(2)
      ..write(obj.ollamaUrl)
      ..writeByte(3)
      ..write(obj.n8nWebhookUrl)
      ..writeByte(4)
      ..write(obj.defaultProvider)
      ..writeByte(5)
      ..write(obj.defaultAgent)
      ..writeByte(6)
      ..write(obj.isDarkMode)
      ..writeByte(7)
      ..write(obj.userEmail)
      ..writeByte(8)
      ..write(obj.isAuthenticated)
      ..writeByte(9)
      ..write(obj.authToken)
      ..writeByte(10)
      ..write(obj.refreshToken)
      ..writeByte(11)
      ..write(obj.provider)
      ..writeByte(12)
      ..write(obj.userName)
      ..writeByte(13)
      ..write(obj.userPhotoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
