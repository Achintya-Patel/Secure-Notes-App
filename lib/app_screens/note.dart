import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteapp/app_screens/note_list.dart';
import 'package:noteapp/models/notes_model.dart';
import 'package:noteapp/providers/note_provider.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/providers/notification_dialogue.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NoteMode { Editing, Adding }

class Note extends StatefulWidget {
  final NoteMode noteMode;
  final NotesModel note;

  Note(this.noteMode, this.note);

  @override
  NoteState createState() {
    return new NoteState();
  }
}

class NoteState extends State<Note> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('icon');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  bool flagDueNotificationIssue =
      true; //called once when page opened for the first time

  Future onSelectNotification(String payload) async {
    if (flagDueNotificationIssue) {
      flagDueNotificationIssue = false;
      return;
    }
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime createdDate = DateTime.now();
  // final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final DateFormat dateFormat = DateFormat.yMd().add_jm();

  @override
  void didChangeDependencies() {
    if (widget.noteMode == NoteMode.Editing) {
      _titleController.text = widget.note.title;
      _textController.text = widget.note.text;
      _dateTimeController.text = widget.note.dateTime;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteMode == NoteMode.Adding
            ? 'Add note'
            : widget.note.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              final title = _titleController.text;
              final text = _textController.text;
              final datetime = _dateTimeController.text;
              final createdAt = DateFormat.jm().format(createdDate);

              if (widget?.noteMode == NoteMode.Adding) {
                print(title + " " + text + " " + datetime + " " + createdAt);
                NoteProvider.insertNote(NotesModel(
                  title: title,
                  text: text,
                  dateTime: datetime,
                  createdAt: createdAt,
                ));
                if (datetime.length != 0) {
                  scheduleNotification(selectedDate, title);
                }
              } else if (widget?.noteMode == NoteMode.Editing) {
                NoteProvider.updateNote(NotesModel(
                  id: widget.note.id,
                  title: title,
                  text: text,
                  dateTime: datetime,
                  createdAt: widget.note.createdAt,
                ));
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => NoteList()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          if (widget.noteMode == NoteMode.Editing)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await NoteProvider.deleteNote(widget.note.id);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => NoteList()),
                  (Route<dynamic> route) => false,
                );
              },
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
                fontSize: 30,
              ),
            ),
            Container(
              height: 8,
            ),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Content',
                border: InputBorder.none,
              ),
              style: TextStyle(fontFamily: 'OpenSans'),
            ),
            Container(
              height: 16.0,
            ),
            if (widget.noteMode != NoteMode.Editing) SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                widget.noteMode == NoteMode.Editing
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: _NoteButton('Add Reminder', Colors.orange,
                            () async {
                          showDateTimeDialog(context, initialDate: selectedDate,
                              onSelectedDate: (selectedDate) {
                            setState(() {
                              this.selectedDate = selectedDate;
                              _dateTimeController.text =
                                  selectedDate.toString().substring(0, 16);
                            });
                          });
                        }),
                      )
              ],
            ),
            if (widget.noteMode == NoteMode.Editing)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Created: ' + widget.note.createdAt,
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> scheduleNotification(DateTime selectedDate, String title) async {
    var scheduledNotificationDateTime = selectedDate;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      icon: 'icon',
      largeIcon: DrawableResourceAndroidBitmap('icon'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(0, title, 'Tap to see more',
        scheduledNotificationDateTime, platformChannelSpecifics);
  }
}

class _NoteButton extends StatelessWidget {
  final String _text;
  final Color _color;
  final Function _onPressed;

  _NoteButton(this._text, this._color, this._onPressed);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: _onPressed,
      child: Text(
        _text,
        style: TextStyle(color: Colors.white),
      ),
      height: 40,
      minWidth: 80,
      color: _color,
    );
  }
}

class NewScreen extends StatelessWidget {
  final String payload;

  NewScreen({
    @required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload),
      ),
    );
  }
}
