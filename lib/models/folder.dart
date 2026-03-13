import 'package:hive/hive.dart';

class Folder {
  final String id;
  final String name;
  final DateTime createdAt;

  Folder({required this.id, required this.name, required this.createdAt});
}

class FolderAdapter extends TypeAdapter<Folder> {
  @override
  final int typeId = 0;

  @override
  Folder read(BinaryReader reader) {
    return Folder(
      id: reader.readString(),
      name: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Folder obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.createdAt.toIso8601String());
  }
}