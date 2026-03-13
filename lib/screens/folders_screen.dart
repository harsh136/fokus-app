import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import 'notes_screen.dart';
import 'editor_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  // ... (keep existing _isSearching, _searchQuery, _searchController, dispose logic)
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
    final filteredFolders = provider.folders.where((f) => f.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(hintText: 'Search folders...', border: InputBorder.none),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text('Folders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 20),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) { _searchQuery = ''; _searchController.clear(); }
            }),
          ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, size: 20, color: Color(0xFF1C1C1C)),
              elevation: 0, // Removes the drop shadow
              color: const Color(0xFFEDE9E2), // Matches the app background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: Color(0xFFD8D5CE), width: 1), // Adds a thin, crisp border
              ),
              onSelected: (value) {
                if (value == 'delete_all') provider.deleteAllFolders();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete_all', 
                  child: Text('Delete all folders', style: TextStyle(color: Colors.red, fontSize: 14))
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFD8D5CE), height: 1),
        ),
      ),
      body: filteredFolders.isEmpty
          ? const Center(child: Text('No folders.', style: TextStyle(color: Color(0xFF8A8A8A))))
          : ListView.separated(
              itemCount: filteredFolders.length,
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1, color: Color(0xFFD8D5CE)),
              itemBuilder: (context, index) {
                final folder = filteredFolders[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  title: Text(folder.name, style: const TextStyle(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${provider.getNoteCount(folder.id)}', style: const TextStyle(color: Color(0xFF8A8A8A))),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(folder: folder))),
                  onLongPress: () => _showFolderOptionsDialog(context, folder.id, folder.name),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'btn1', backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0,
              onPressed: () => _showCreateFolderDialog(context),
              child: const Icon(Icons.create_new_folder_outlined),
            ),
            FloatingActionButton(
              heroTag: 'btn2', backgroundColor: Colors.black, foregroundColor: Colors.white, elevation: 0,
              onPressed: () => _showCreateNoteSelector(context, provider),
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderOptionsDialog(BuildContext context, String folderId, String currentName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFEDE9E2),
        title: const Text('Folder Options'),
        content: const Text('What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppProvider>().deleteFolder(folderId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRenameFolderDialog(context, folderId, currentName);
            },
            child: const Text('Rename', style: TextStyle(color: Color(0xFF1C1C1C))),
          ),
        ],
      ),
    );
  }

  void _showRenameFolderDialog(BuildContext context, String folderId, String currentName) {
    String name = currentName;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFEDE9E2),
        title: const Text('Rename Folder'),
        content: TextField(
          autofocus: true, controller: TextEditingController(text: currentName),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty) context.read<AppProvider>().renameFolder(folderId, name);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) { /* Same as before */ 
    String name = "";
    showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFFEDE9E2), title: const Text('New Folder'), content: TextField(autofocus: true, onChanged: (val) => name = val), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), TextButton(onPressed: () { if (name.isNotEmpty) context.read<AppProvider>().createFolder(name); Navigator.pop(ctx); }, child: const Text('Save'))]));
  }

  void _showCreateNoteSelector(BuildContext context, AppProvider provider) {
    if (provider.folders.isEmpty) {
      provider.createFolder("Default");
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFEDE9E2),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: provider.folders.length,
        itemBuilder: (ctx, index) {
          return ListTile(
            title: Text('Add to: ${provider.folders[index].name}'),
            onTap: () {
              Navigator.pop(ctx);
              final id = provider.createNote(provider.folders[index].id);
              Navigator.push(context, MaterialPageRoute(builder: (_) => EditorScreen(noteId: id)));
            },
          );
        },
      ),
    );
  }
}