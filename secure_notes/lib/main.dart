import 'package:flutter/material.dart';
import 'note_list_screen.dart';

void main() => runApp(
  const SecureNotesApp()
);

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Secure Notes Pro',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey.shade700), useMaterial3: true),
    home: NotesListScreen(),
  );
}

