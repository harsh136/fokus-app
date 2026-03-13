import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/folder.dart';
import '../models/note.dart';

class AppProvider extends ChangeNotifier {
  late Box<Folder> _folderBox;
  late Box<Note> _noteBox;
  final _uuid = const Uuid();

  List<Folder> get folders => _folderBox.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  List<Note> get notes => _noteBox.values.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  Future<void> init() async {
    _folderBox = await Hive.openBox<Folder>('folders');
    _noteBox = await Hive.openBox<Note>('notes');
    notifyListeners();
  }

  List<Note> getNotesByFolder(String folderId) {
    return notes.where((n) => n.folderId == folderId).toList();
  }

  int getNoteCount(String folderId) {
    return _noteBox.values.where((n) => n.folderId == folderId).length;
  }

  void createFolder(String name) {
    final folder = Folder(id: _uuid.v4(), name: name, createdAt: DateTime.now());
    _folderBox.put(folder.id, folder);
    notifyListeners();
  }

  String createNote(String folderId) {
    final note = Note(
      id: _uuid.v4(),
      folderId: folderId,
      title: '',
      content: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _noteBox.put(note.id, note);
    notifyListeners();
    return note.id;
  }

  // Update this existing method to accept the new fields
  void updateNote(String id, String title, String content, {String? imagePath, String? fontStyle}) {
    final note = _noteBox.get(id);
    if (note != null) {
      note.title = title;
      note.content = content;
      note.updatedAt = DateTime.now();
      if (imagePath != null) note.imagePath = imagePath.isEmpty ? null : imagePath;
      if (fontStyle != null) note.fontStyle = fontStyle;
      _noteBox.put(id, note);
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _noteBox.delete(id);
    notifyListeners();
  }
  // Add inside AppProvider class in lib/services/app_provider.dart

  void renameFolder(String id, String newName) {
    final folder = _folderBox.get(id);
    if (folder != null) {
      _folderBox.put(id, Folder(id: folder.id, name: newName, createdAt: folder.createdAt));
      notifyListeners();
    }
  }

  void deleteFolder(String id) {
    _folderBox.delete(id);
    // Delete all notes inside this folder too
    final notesToDelete = _noteBox.values.where((n) => n.folderId == id).map((n) => n.id).toList();
    for (var noteId in notesToDelete) {
      _noteBox.delete(noteId);
    }
    notifyListeners();
  }

  void deleteAllFolders() {
    _folderBox.clear();
    _noteBox.clear();
    notifyListeners();
  }

  void deleteAllNotesInFolder(String folderId) {
    final notesToDelete = _noteBox.values.where((n) => n.folderId == folderId).map((n) => n.id).toList();
    for (var noteId in notesToDelete) {
      _noteBox.delete(noteId);
    }
    notifyListeners();
  }

  
}