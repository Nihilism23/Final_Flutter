import '../models/course.dart';
import '../models/reminder.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  final SimpleStorage _storage = SimpleStorage.instance;

  DatabaseService._init();

  Future<int> insertCourse(Course course) async {
    return await _storage.insertCourse(course);
  }

  Future<List<Course>> getAllCourses() async {
    return await _storage.getAllCourses();
  }

  Future<int> deleteCourse(int id) async {
    return await _storage.deleteCourse(id);
  }

  Future<int> updateCourse(Course course) async {
    return await _storage.updateCourse(course);
  }

  Future<void> clearAllCourses() async {
    return await _storage.clearAllCourses();
  }

  Future<int> insertReminder(Reminder reminder) async {
    return await _storage.insertReminder(reminder);
  }

  Future<List<Reminder>> getAllReminders() async {
    return await _storage.getAllReminders();
  }

  Future<int> deleteReminder(int id) async {
    return await _storage.deleteReminder(id);
  }

  Future<int> markReminderRead(int id) async {
    return await _storage.markReminderRead(id);
  }
}

class SimpleStorage {
  static final SimpleStorage instance = SimpleStorage._init();
  List<Course> _courses = [];
  List<Reminder> _reminders = [];
  int _courseIdCounter = 1;
  int _reminderIdCounter = 1;

  SimpleStorage._init();

  Future<int> insertCourse(Course course) async {
    final newId = _courseIdCounter++;
    final newCourse = Course(
      id: newId,
      name: course.name,
      classroom: course.classroom,
      dayOfWeek: course.dayOfWeek,
      period: course.period,
      colorIndex: course.colorIndex,
      weekType: course.weekType,
    );
    _courses.add(newCourse);
    return newId;
  }

  Future<List<Course>> getAllCourses() async {
    return _courses;
  }

  Future<int> deleteCourse(int id) async {
    _courses.removeWhere((c) => c.id == id);
    return 1;
  }

  Future<int> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      return 1;
    }
    return 0;
  }

  Future<void> clearAllCourses() async {
    _courses.clear();
    _courseIdCounter = 1;
  }

  Future<int> insertReminder(Reminder reminder) async {
    final newId = _reminderIdCounter++;
    final newReminder = Reminder(
      id: newId,
      title: reminder.title,
      content: reminder.content,
      date: reminder.date,
      isRead: reminder.isRead,
      type: reminder.type,
    );
    _reminders.add(newReminder);
    return newId;
  }

  Future<List<Reminder>> getAllReminders() async {
    _reminders.sort((a, b) => b.date.compareTo(a.date));
    return _reminders;
  }

  Future<int> deleteReminder(int id) async {
    _reminders.removeWhere((r) => r.id == id);
    return 1;
  }

  Future<int> markReminderRead(int id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = Reminder(
        id: id,
        title: _reminders[index].title,
        content: _reminders[index].content,
        date: _reminders[index].date,
        isRead: true,
        type: _reminders[index].type,
      );
      return 1;
    }
    return 0;
  }
}
