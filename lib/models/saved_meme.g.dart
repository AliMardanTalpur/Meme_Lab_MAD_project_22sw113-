// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_meme.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedMemeAdapter extends TypeAdapter<SavedMeme> {
  @override
  final int typeId = 0;

  @override
  SavedMeme read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedMeme(
      id: fields[0] as int,
      title: fields[1] as String,
      url: fields[2] as String,
      subreddit: fields[3] as String,
      dataUrl: fields[4] as String,
      createdAt: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SavedMeme obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.subreddit)
      ..writeByte(4)
      ..write(obj.dataUrl)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedMemeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
