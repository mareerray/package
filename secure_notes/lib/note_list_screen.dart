import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:note/note.dart';
import 'edit_screen.dart';

// ================ Note List Screen ================

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override 
  State<NotesListScreen> createState() => 
    _NotesListScreenState();
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
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => 
      EditNoteScreen(note: existing)));

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

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final Note note = _notes.removeAt(oldIndex);
      _notes.insert(newIndex, note);
    });
  }

  String formatNoteDate(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return DateFormat('MMM dd, yyyy • HH:mm').format(dateTime);
  }



  // ================ Build UI foundation ================

  @override
  Widget build(BuildContext context) => Scaffold(
    // extendBodyBehindAppBar: true,
    appBar: AppBar(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,  
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note_alt_outlined, color: Colors.black87, size: 32, fontWeight: FontWeight.w900),
              const SizedBox(width: 5),
              Text('Secure Notes', 
                style: GoogleFonts.pattaya(color: Colors.black87, fontSize: 30, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),      backgroundColor: Colors.transparent,
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
          icon: Icon(Icons.delete_sweep_rounded, color: Colors.black87, fontWeight: FontWeight.bold, size: 28),
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
        SizedBox(height: 16),
        // 4. Signature - bottom left, same level as FAB
        Positioned(
          bottom: 30,
          left: 20,
          child: Text(
            'Created by Mayuree Reunsati',
            style: GoogleFonts.signika(
              fontSize: 14,
              color: Color(0xFF32a4bb),
              fontWeight: FontWeight.w500,
              // shadows: [
              //   Shadow(offset: Offset(1, 1), blurRadius: 3, color: Colors.grey[400]),
              // ],
            ),
          ),
        ),
      ],
    ),
    
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
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_sharp, size: 80, color: Colors.grey[900]),
                const SizedBox(height: 16),
                Text('No notes yet', style: GoogleFonts.inconsolata(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                const SizedBox(height: 8),
                Text('Tap the + button', style: GoogleFonts.inconsolata(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
                const SizedBox(height: 8),
                Text('to add your first note', style: GoogleFonts.inconsolata(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[900])),
              ],
            ),
          ),
        )
      : ReorderableListView(
          onReorder: _onReorder,
          padding: const EdgeInsets.all(16),
          children: _notes.map((note) => _buildNoteCard(note)).toList(),
        );


    // ================ Build Individual Note ================

  Widget _buildNoteCard(Note note) => Card(
    key: ValueKey(note.id),
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
            Text(note.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.inconsolata(color: Colors.grey[900], fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[800]),
                const SizedBox(width: 4),
                Text(formatNoteDate(note.date), style: GoogleFonts.inconsolata(color: Colors.grey[800], fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      trailing: PopupMenuButton<IconData>(
        icon: const Icon(Icons.more_vert),
        color: Colors.white.withValues(alpha:0.8),
        elevation: 8,
        onSelected: (action) async {
          if (action == Icons.edit) {
            _addOrEditNote(existing: note);
          } else if (action == Icons.delete_outline) {
            final confirmed = await _confirmSingleDelete(note);
            if (confirmed == true) {
              final noteIndex = _notes.indexWhere((n) => n.id == note.id);
              if (noteIndex != -1) {
                setState(() => _notes.removeAt(noteIndex));
              }
              await _db.deleteNote(note: note);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${note.title}"')),
              );
            }
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: Icons.edit, child: Row(children: [Icon(Icons.edit), SizedBox(width: 12), Text('Edit')])),
          PopupMenuItem(value: Icons.delete_outline, child: Row(children: [Icon(Icons.delete_outline, color: Colors.red), SizedBox(width: 12),        Text('Delete', style: TextStyle(color: Colors.red))])),
        ],
      ),
      onTap: () => _addOrEditNote(existing: note),
    ),
  );
}
