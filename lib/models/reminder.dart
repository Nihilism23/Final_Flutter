class Reminder {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final bool isRead;
  final ReminderType type;

  Reminder({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.isRead = false,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'type': type.index,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      date: DateTime.parse(map['date'] as String),
      isRead: (map['isRead'] as int?) == 1,
      type: ReminderType.values[map['type'] as int? ?? 0],
    );
  }
}

enum ReminderType {
  weather,
  course,
  system,
}
