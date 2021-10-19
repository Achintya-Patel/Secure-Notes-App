import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/models/notes_model.dart';
import 'package:noteapp/providers/note_provider.dart';
import 'note.dart';

class NoteList extends StatefulWidget {
  @override
  NoteListState createState() {
    return new NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            /*
            UserAccountsDrawerHeader(
              accountName: Text(""),
              accountEmail: Text(""),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  "",
                  style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
                backgroundColor: Colors.white,
              ),
            ),
            */
            AppBar(
              title: Text('Hello!'),
              automaticallyImplyLeading: false,
            ),
            ListTile(
              leading: Icon(Icons.perm_identity),
              title: Text("Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Notes"),
              onTap: () {},
              selected: true,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
                leading: Icon(Icons.feedback),
                title: Text("Feedback"),
                onTap: () {}),
            ListTile(
              leading: Icon(Icons.note),
              title: Text("About"),
              onTap: () {},
            ),
            /*
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  leading: Icon(Icons.copyright),
                  title: Text(
                    ""
                  ),
                ),
              ),
            )
            */
          ],
        ),
      ),
      body: FutureBuilder(
        future: NoteProvider.getNoteList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final notes = snapshot.data as List<NotesModel>;
            if (notes.length == 0)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No notes',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Tap the Add button to create a note.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Note(NoteMode.Editing, note)));
                  },
                  child: Card(
                    elevation: 5,
                    margin: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: _NoteTitle(
                        note.title,
                        note.dateTime,
                      ),
                      subtitle: _NoteText(
                        note.text,
                      ),
                      trailing: MediaQuery.of(context).size.width > 460
                          ? FlatButton.icon(
                              icon: Icon(Icons.delete),
                              label: Text('Delete'),
                              textColor: Theme.of(context).errorColor,
                              onPressed: null,
                            )
                          : IconButton(
                              icon: Icon(Icons.delete),
                              color: Theme.of(context).errorColor,
                              onPressed: () async {
                                await NoteProvider.deleteNote(note.id);
                                setState(() {});
                              },
                            ),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Note(NoteMode.Adding, null)));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class _NoteTitle extends StatelessWidget {
  final String _title;
  final String _datetime;

  _NoteTitle(this._title, this._datetime);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        _datetime.length == 0
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                child: Icon(
                  Icons.alarm_on,
                  size: 20,
                ),
              )
      ],
    );
  }
}

class _NoteText extends StatelessWidget {
  final String _text;

  _NoteText(this._text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1.0),
      child: Text(
        _text,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
