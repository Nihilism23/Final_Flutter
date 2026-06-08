class Course {
  final int? id;
  final String name;
  final String classroom;
  final int dayOfWeek;
  final int period;
  final int colorIndex;
  final int weekType;

  Course({
    this.id,
    required this.name,
    required this.classroom,
    required this.dayOfWeek,
    required this.period,
    this.colorIndex = 0,
    this.weekType = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'classroom': classroom,
      'dayOfWeek': dayOfWeek,
      'period': period,
      'colorIndex': colorIndex,
      'weekType': weekType,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      name: map['name'] as String,
      classroom: map['classroom'] as String,
      dayOfWeek: map['dayOfWeek'] as int,
      period: map['period'] as int,
      colorIndex: map['colorIndex'] as int? ?? 0,
      weekType: map['weekType'] as int? ?? 0,
    );
  }

  bool shouldShow(int currentWeek) {
    if (weekType == 0) return true;
    if (weekType == 1) return currentWeek % 2 == 1;
    if (weekType == 2) return currentWeek % 2 == 0;
    return true;
  }

  String get weekTypeText {
    switch (weekType) {
      case 1:
        return 'Odd';
      case 2:
        return 'Even';
      default:
        return 'Every';
    }
  }

  @override
  String toString() {
    return '$name\n$classroom';
  }
}
