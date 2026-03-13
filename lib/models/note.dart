import 'package:hive/hive.dart';

class Note {
  final String id;
  final String folderId;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  String? imagePath;
  String fontStyle;

  Note({
    required this.id,
    required this.folderId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.fontStyle = 'Inter',
  });
}

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 1;

  @override
  Note read(BinaryReader reader) {
    return Note(
      id: reader.readString(),
      folderId: reader.readString(),
      title: reader.readString(),
      content: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      imagePath: reader.readString(),
      fontStyle: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.folderId);
    writer.writeString(obj.title);
    writer.writeString(obj.content);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.writeString(obj.imagePath ?? '');
    writer.writeString(obj.fontStyle);
  }
}