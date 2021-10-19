class NotesModel {
  int id;
  String title;
  String text;
  String dateTime;
  String createdAt;

  NotesModel({
    this.id,
    this.title,
    this.text,
    this.dateTime,
    this.createdAt,
  });

  factory NotesModel.fromJson(Map<String, dynamic> json) {
    return NotesModel(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      title: json['title'] ?? "",
      text: json['text'] ?? "",
      dateTime: json['datetime'] ?? "",
      createdAt: json['createdat'] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'text': text,
        'datetime': dateTime,
        'createdat': createdAt,
      };
}
