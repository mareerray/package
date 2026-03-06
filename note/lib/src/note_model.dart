class Note {
  final int? id;
  final String title;
  final String body;
  final String date;

  const Note({
    this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  Note copyWith({
    int? id,
    String? title,
    String? body,
    String? date,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as int?,
      title: map['title'] as String,
      body: map['body'] as String,
      date: map['date'] as String,
    );
  }
}