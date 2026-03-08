import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note/note.dart';

// ================ Edit/Add Note Screen ================

class EditNoteScreen extends StatefulWidget {
  final Note? note;
  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => 
    _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _body;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();  // Saves to _title, _body

    final note = Note(
      id: widget.note?.id,
      title: _title!.trim(),
      body: _body!.trim(),
      date: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(note);
  }

  // ================ Build Note Edit Form ================
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
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
        title: Text(isEditing ? 'Edit note' : 'Add note', style: GoogleFonts.pattaya(color:  Colors.black87, fontSize: 30, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: widget.note?.title,
                onSaved: (value) => _title = value,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.inconsolata(fontSize: 20, fontWeight: FontWeight.bold),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextFormField(
                  initialValue: widget.note?.body,
                  onSaved: (value) => _body = value,
                  decoration: InputDecoration(
                    labelText: 'Body',
                    labelStyle: GoogleFonts.inconsolata(fontSize: 20, fontWeight: FontWeight.bold),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Body is required' : null,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32a4bb),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    elevation: 6,
                  ),
                  onPressed: _save,
                  child: Text(isEditing ? 'Save changes' : 'Add note',
                    style: GoogleFonts.inconsolata(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
