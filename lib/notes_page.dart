import 'package:flutter/material.dart';
import 'package:notes_app/note.dart';
import 'package:notes_app/note_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  // Note database
  final _noteDatabase = NoteDatabase();
  final textController = TextEditingController();
  final searchController = TextEditingController();
  bool isFilteredByFavorite = false;
  bool isSearching = false;

  void toggleFavorite(Note note) {
    note.isFavorite = !note.isFavorite;
    _noteDatabase.updateNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: isSearching
              ? TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search Notes',
                    border: InputBorder.none,
                  ),
                  autofocus: true,
                  onChanged: (value) => setState(() {}),
                )
              : const Text('Aqua'),
          actions: [
            IconButton(
              onPressed: () => setState(() => isSearching = !isSearching),
              icon: Icon(isSearching ? Icons.close : Icons.search),
            ),
            IconButton(
              onPressed: () =>
                  setState(() => isFilteredByFavorite = !isFilteredByFavorite),
              icon:
                  Icon(isFilteredByFavorite ? Icons.favorite : Icons.favorite_border),
            )
          ]),
      body: StreamBuilder(
        stream: _noteDatabase.getNotesStream(),
        builder: (context, snapshot) {
          // loading ...
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // loaded
          final notes = snapshot.data!;
          final searchedNotes = searchController.text.isEmpty
              ? notes
              : notes
                  .where((note) => note.content
                      .toLowerCase()
                      .contains(searchController.text.toLowerCase()))
                  .toList();
          final filteredNotes = isFilteredByFavorite
              ? searchedNotes
                  .where((searchedNotes) => searchedNotes.isFavorite)
                  .toList()
              : searchedNotes;

          // Empty state
          if (filteredNotes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(searchController.text.isEmpty
                      ? 'No notes found'
                      : 'No results found'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addNewNote,
                    child: const Text('Add a note'),
                  ),
                ],
              ),
            );
          }

          // List of notes
          return ListView.separated(
            itemCount: filteredNotes.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: 10,
            ),
            itemBuilder: (context, index) => ListTile(
              title: Text(filteredNotes[index].content),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => editNote(filteredNotes[index]),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => deleteNote(filteredNotes[index]),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
              leading: filteredNotes[index].isFavorite
                  ? GestureDetector(
                      onTap: () => toggleFavorite(filteredNotes[index]),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.green,
                      ),
                    )
                  : GestureDetector(
                      onTap: () => toggleFavorite(filteredNotes[index]),
                      child: const Icon(Icons.favorite_border),
                    ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewNote,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addNewNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Note'),
        content: TextField(
          controller: textController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              // create a new note
              final note =
                  Note(content: textController.text, isFavorite: false);

              // Save the note to the database
              _noteDatabase.insertNote(note);

              // Close the dialog
              Navigator.pop(context);
              textController.clear();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void saveNote() async {
    await Supabase.instance.client.from('aqua').insert({
      'body': textController.text,
    });
    textController.clear();
  }

  // Edit a note
  void editNote(Note note) {
  // Set the text controller to the note content
  textController.text = note.content;
  bool isFavoriteTemp = note.isFavorite; // Temporary variable to hold favorite status

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Edit Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: 'Edit content'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      isFavoriteTemp = !isFavoriteTemp;
                    });
                  },
                  child: Icon(
                    isFavoriteTemp ? Icons.favorite : Icons.favorite_border,
                    color: isFavoriteTemp ? Colors.green : null,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Mark as Favorite'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Update the note content and favorite status
              note.content = textController.text;
              note.isFavorite = isFavoriteTemp;
              _noteDatabase.updateNote(note);

              // Close the dialog
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
}

  // Delete a note
  void deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
            'Are you sure you want to delete this note?\n\n"${note.content}"'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Final Confirmation'),
                  content: const Text('This action cannot be undone. Proceed?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _noteDatabase.deleteNote(note.id!);
                        Navigator.pop(context); // Close final confirmation
                        Navigator.pop(context); // Close first confirmation
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void toggleImportantStatus(Note note) async {
    note.isFavorite = !note.isFavorite;
    _noteDatabase.updateNote(note);
    setState(() {});
  }

  void toggleDoneStatus(Note note) async {
    note.isFavorite = !note.isFavorite;
    _noteDatabase.updateNote(note);
    setState(() {});
  }
}
