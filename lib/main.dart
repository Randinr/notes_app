import 'package:flutter/material.dart';
import 'package:notes_app/notes_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Supabase Setup
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pyqgofcbibvhcqwzvbmv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB5cWdvZmNiaWJ2aGNxd3p2Ym12Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI5NTY3NjcsImV4cCI6MjA0ODUzMjc2N30.dS9eIMejRtU4ZAK2LQaaP92jmR6TXD3DYvfgy8-hdpA',
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}