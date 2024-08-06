import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Note {
  final int id;
  final String content;
  final String date;

  Note({
    required this.id,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'date': date,
    };
  }
}

class notes_view extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<notes_view> {
  late Database database;
  List<Note> notes = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'note_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, date TEXT)',
        );
      },
      version: 1,
    );
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final List<Map<String, dynamic>> maps = await database.query('notes');
    setState(() {
      notes = List.generate(maps.length, (i) {
        return Note(
          id: maps[i]['id'],
          content: maps[i]['content'],
          date: maps[i]['date'],
        );
      });
    });
  }

  Future<void> insertNote() async {
    if (_controller.text.isEmpty) return;
    await database.insert(
      'notes',
      {
        'content': _controller.text,
        'date': DateTime.now().toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _controller.clear();
    fetchNotes();
  }

  Future<void> deleteNote(int id) async {
    await database.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/images/note-icon.png',
                width: 50,
                height: 50,
              ),
              const Text(
                'My notes',
                style: TextStyle(fontSize: 34),
              ),
              Text(
                '${notes.length} notes',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 40,
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter Your Note',
                  //labelText: 'Enter Your Note',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: insertNote,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDate(notes[index].date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notes[index].content,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
  }
}
