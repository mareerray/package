import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:note/note.dart';

String formatNoteDate(String isoString) {
  final dateTime = DateTime.parse(isoString);
  final now = DateTime.now();
  final isSameDay = dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
  return isSameDay ? DateFormat.Hm().format(dateTime) : DateFormat('yyyy-MM-dd').format(dateTime);
}

void main() => runApp(const SecureNotesApp());

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Secure Notes Pro',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), useMaterial3: true),
    home: NotesListScreen(),
  );
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});
  @override State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesDatabase _db = NotesDatabase();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _db.database;
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _db.getAllNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _addOrEditNote({Note? existing}) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditNoteScreen(note: existing)));
    if (result == null) return;
    if (result == 'delete') {
      if (existing != null) {
        await _db.deleteNote(note: existing);
        await _loadNotes();
      }
      return;
    }
    if (result is Note) {
      if (existing == null) {
        await _db.addNote(note: result);
      } else {
        await _db.updateNote(oldNote: existing, newNote: result);
      }
      await _loadNotes();
    }
  }

  Future<void> _deleteAll() async {
    await _db.deleteAllNotes();
    await _loadNotes();
  }

  Future<void> _confirmDeleteAll() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Notes?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (shouldDelete == true) await _deleteAll();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final Note note = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, note);
    });
    // TODO: Save order to DB if position field added
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    // extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Row(
        children: [
          Icon(Icons.note_alt_outlined, color: Colors.grey[800], size: 32, fontWeight: FontWeight.w900),
          const SizedBox(width: 5),
          Text('Secure Notes', 
              style: GoogleFonts.pattaya(color: Colors.grey[800], fontSize: 30, fontWeight: FontWeight.bold)),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 92, 185, 192), const Color.fromARGB(255, 40, 118, 147)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_sweep, color: Colors.grey[800], fontWeight: FontWeight.bold, size: 28),
          tooltip: 'Delete All Notes',          
          onPressed: _notes.isEmpty ? null : _confirmDeleteAll,
        ),
        SizedBox(width: 12),
      ],
    ),
    body: Stack(
      children: [
        // 1. Background image (bottom)
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.only(bottom: 50),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bluebg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // 2. Overlay gradient (middle)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha:0.2),  
                  Colors.black.withValues(alpha:0.1),
                ],
              ),
            ),
          ),
        ),
        // 3. Content (top - visible!)
        SafeArea(
          child: Column(children: [
            Expanded(child: _buildNotesList()),
          ]),
        ),
      ],
    ),
    // Dark overlay
    floatingActionButton: FloatingActionButton(
      onPressed: () => _addOrEditNote(),
      backgroundColor: const Color(0xFF32a4bb),
      child: const Icon(Icons.add, color: Colors.white),
    ),
  );

  // ================ Build Notes List ================

  Widget _buildNotesList() => _isLoading
      ? const Center(child: CircularProgressIndicator())
      : _notes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_sharp, size: 80, color: Colors.grey[900]),
                  const SizedBox(height: 16),
                  Text('No notes yet', style: GoogleFonts.inconsolata(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  const SizedBox(height: 8),
                  Text('Tap the + button to add your first note', style: GoogleFonts.inconsolata(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),],
              ),
            )
          : ReorderableListView(
              onReorder: _onReorder,
              padding: const EdgeInsets.all(16),
              children: _notes.map((note) => _buildNoteCard(note)).toList(),
            );

  // ================ Build Individual Note ================

  Widget _buildNoteCard(Note note) => Dismissible(
    key: ValueKey(note.id),
    direction: DismissDirection.endToStart,
    background: Container(
      decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    ),
    confirmDismiss: (_) async => await _confirmSingleDelete(note),
    child: Card(
      // elevation: 4,
      color: Colors.white.withValues(alpha: 0.8),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: const Icon(Icons.drag_indicator, color: Color(0xFF32a4bb)),
        title: Text(note.title, style: GoogleFonts.inconsolata(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis, style:GoogleFonts.inconsolata(color: Colors.grey[800], fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(formatNoteDate(note.date), style: GoogleFonts.inconsolata(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<IconData>(
          icon: const Icon(Icons.more_vert),
          color: Colors.white.withValues(alpha:0.8),  // ← background color
          elevation: 8,
          onSelected: (action) {
            if (action == Icons.edit) _addOrEditNote(existing: note);
            if (action == Icons.delete_outline) _confirmSingleDelete(note);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: Icons.edit, child: Row(children: [Icon(Icons.edit), SizedBox(width: 12), Text('Edit')])),
            PopupMenuItem(value: Icons.delete_outline, child: Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 12), Text('Delete', style: TextStyle(color: Colors.red))])),
          ],
        ),
        onTap: () => _addOrEditNote(existing: note),
      ),
    ),
  );

  Future<bool?> _confirmSingleDelete(Note note) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Note'),
      content: Text('"${note.title}" will be deleted.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}



class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      date: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(note);
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('Do you want to remove this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      Navigator.of(context).pop('delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF32a4bb),
        title: Text(isEditing ? 'Edit note' : 'Add note', style: GoogleFonts.pattaya(color:  Colors.grey[900], fontSize: 26, fontWeight: FontWeight.bold)),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title', labelStyle: GoogleFonts.inconsolata(fontSize: 18, fontWeight: FontWeight.bold)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  decoration: InputDecoration(labelText: 'Body', labelStyle: GoogleFonts.inconsolata(fontSize: 18, fontWeight: FontWeight.bold)),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Body is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF32a4bb)),
                    onPressed: _save,
                    child: Text(isEditing ? 'Save changes' : 'Add note', style: GoogleFonts.inconsolata(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
