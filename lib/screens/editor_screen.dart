import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_provider.dart';

class EditorScreen extends StatefulWidget {
  final String noteId;
  const EditorScreen({super.key, required this.noteId});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  
  String? _imagePath;
  String _currentFont = 'Inter'; // Default font

  @override
  void initState() {
    super.initState();
    final note = context.read<AppProvider>().notes.firstWhere((n) => n.id == widget.noteId);
    _titleController = TextEditingController(text: note.title);
    _contentController = TextEditingController(text: note.content);
    _imagePath = note.imagePath;
    _currentFont = note.fontStyle;

    // Listen to focus changes to update the bottom bar
    _titleFocus.addListener(() => setState(() {}));
    _contentFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _saveNote() {
    context.read<AppProvider>().updateNote(
      widget.noteId,
      _titleController.text,
      _contentController.text,
      imagePath: _imagePath ?? '', 
      fontStyle: _currentFont,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      _saveNote();
    }
  }

  void _insertChecklist() {
    if (_contentFocus.hasFocus) {
      final text = _contentController.text;
      final selection = _contentController.selection;
      // Insert checklist formatting at cursor
      final newText = text.replaceRange(selection.start, selection.end, '- [ ] ');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + 6),
      );
    }
  }

  void _toggleFont() {
    setState(() {
      if (_currentFont == 'Inter') _currentFont = 'Serif';
      else if (_currentFont == 'Serif') _currentFont = 'Monospace';
      else _currentFont = 'Inter';
    });
  }

  TextStyle _getFontStyle(double size, FontWeight weight) {
    if (_currentFont == 'Serif') return GoogleFonts.ptSerif(fontSize: size, fontWeight: weight);
    if (_currentFont == 'Monospace') return GoogleFonts.robotoMono(fontSize: size, fontWeight: weight);
    return GoogleFonts.inter(fontSize: size, fontWeight: weight); // Default
  }

  @override
  Widget build(BuildContext context) {
    final isTitleFocused = _titleFocus.hasFocus;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) => _saveNote(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => Navigator.pop(context)),
          bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: const Color(0xFFD8D5CE), height: 1)),
        ),
        body: Column(
          children: [
            // We wrap the text fields and image in an Expanded + SingleChildScrollView
            // so the user can scroll through long content or tall images without crashing.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: TextField(
                        controller: _titleController,
                        focusNode: _titleFocus,
                        maxLines: null,
                        style: _getFontStyle(16, FontWeight.w600).copyWith(color: const Color(0xFF1C1C1C)),
                        decoration: const InputDecoration(
                          hintText: 'Title...', 
                          border: InputBorder.none, 
                          isDense: true
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFD8D5CE)),
                    
                    if (_imagePath != null && _imagePath!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(File(_imagePath!), fit: BoxFit.contain),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, shadows: [Shadow(blurRadius: 4, color: Colors.black)]),
                              onPressed: () => setState(() => _imagePath = null),
                            )
                          ],
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        maxLines: null,
                        // Notice we removed 'expands: true' so it plays nice with scrolling
                        style: _getFontStyle(14, FontWeight.normal).copyWith(color: const Color(0xFF1C1C1C)),
                        decoration: const InputDecoration(
                          hintText: 'Start typing...', 
                          border: InputBorder.none
                        ),
                      ),
                    ),
                    
                    // Extra padding at the bottom so typing isn't cramped against the keyboard
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
            
            // Bottom Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFD8D5CE), width: 1))),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleFont,
                    child: Text('Aa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _currentFont != 'Inter' ? Colors.black : const Color(0xFF8A8A8A))),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: _titleFocus.hasFocus ? null : _insertChecklist,
                    child: Icon(Icons.check_circle_outline, color: _titleFocus.hasFocus ? const Color(0xFFD8D5CE) : const Color(0xFF8A8A8A), size: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _titleFocus.hasFocus ? null : _pickImage,
                    child: Icon(Icons.image_outlined, color: _titleFocus.hasFocus ? const Color(0xFFD8D5CE) : const Color(0xFF8A8A8A), size: 24),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}