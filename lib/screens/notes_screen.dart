import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/folder.dart';
import '../services/app_provider.dart';
import 'editor_screen.dart';

class NotesScreen extends StatefulWidget {
  final Folder folder;
  const NotesScreen({super.key, required this.folder});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notes = provider.getNotesByFolder(widget.folder.id);

    // Filter notes based on the search query (checking both title and content)
    final filteredNotes = notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) || 
             note.content.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28), 
          onPressed: () => Navigator.pop(context)
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Color(0xFF8A8A8A)),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : Text(widget.folder.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 20),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF1C1C1C)),
              elevation: 0,
              color: const Color(0xFFEDE9E2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: Color(0xFFD8D5CE), width: 1),
              ),
              onSelected: (value) {
                if (value == 'delete_all') provider.deleteAllNotesInFolder(widget.folder.id);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete_all', 
                  child: Text('Delete all notes', style: TextStyle(color: Colors.red, fontSize: 14))
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFD8D5CE), height: 1),
        ),
      ),
      body: filteredNotes.isEmpty
          ? Center(
              child: Text(
                _isSearching ? 'No notes match your search.' : 'No notes yet. Create one!',
                style: const TextStyle(color: Color(0xFF8A8A8A)),
              ),
            )
          : ListView.separated(
              itemCount: filteredNotes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: Color(0xFFD8D5CE)),
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return InkWell(
                  onLongPress: () => _showDeleteConfirmation(context, provider, note.id),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(noteId: note.id))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
  note.title.isEmpty ? 'Untitled' : note.title, 
  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
),
                              const SizedBox(height: 4),
                              Text(
                                note.content.isEmpty ? 'No text...' : note.content,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('dd.MM.yy').format(note.updatedAt),
                          style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () {
          final id = provider.createNote(widget.folder.id);
          Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(noteId: id)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Added a clean confirmation dialog for the long-press delete action
  void _showDeleteConfirmation(BuildContext context, AppProvider provider, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFEDE9E2),
        title: const Text('Delete Note?', style: TextStyle(fontSize: 18)),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8A8A8A)))
          ),
          TextButton(
            onPressed: () {
              provider.deleteNote(noteId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}