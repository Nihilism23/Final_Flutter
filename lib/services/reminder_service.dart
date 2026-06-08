import '../models/course.dart';
import '../models/weather.dart';
import '../models/reminder.dart';
import 'database_service.dart';

class ReminderService {
  static final ReminderService instance = ReminderService._init();
  final DatabaseService _db = DatabaseService.instance;

  ReminderService._init();

  Future<void> checkAndCreateReminders(
    List<Course> todayCourses,
    WeatherData? weather,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (weather != null) {
      final weatherType = WeatherIconHelper.getWeatherType(weather.weatherCode);
      if (weatherType == 'rainy' || weatherType == 'snowy') {
        await _createWeatherReminder(weather, todayCourses.isNotEmpty);
      }
    }

    for (final course in todayCourses) {
      await _createCourseReminder(course, weather);
    }
  }

  Future<void> _createWeatherReminder(WeatherData weather, bool hasCourses) async {
    final weatherType = WeatherIconHelper.getWeatherType(weather.weatherCode);
    String title, content;

    if (weatherType == 'rainy') {
      title = 'Rain Alert';
      if (hasCourses) {
        content = 'It will rain today. Remember to bring an umbrella! You have classes today.';
      } else {
        content = 'It will rain today. Remember to bring an umbrella!';
      }
    } else if (weatherType == 'snowy') {
      title = 'Snow Alert';
      content = 'It will snow today. Stay warm and be careful on the roads!';
    } else {
      return;
    }

    final reminder = Reminder(
      title: title,
      content: content,
      date: DateTime.now(),
      type: ReminderType.weather,
    );

    await _db.insertReminder(reminder);
  }

  Future<void> _createCourseReminder(Course course, WeatherData? weather) async {
    final needUmbrella = weather != null && WeatherIconHelper.needUmbrella(weather.weatherCode);

    String title = 'Class Reminder';
    StringBuffer content = StringBuffer('You have ${course.name} today, Room: ${course.classroom}');

    if (needUmbrella) {
      content.write(' - Remember to bring an umbrella!');
    }

    final reminder = Reminder(
      title: title,
      content: content.toString(),
      date: DateTime.now(),
      type: ReminderType.course,
    );

    await _db.insertReminder(reminder);
  }

  Future<List<Reminder>> getReminders() async {
    return await _db.getAllReminders();
  }

  Future<void> deleteReminder(int id) async {
    await _db.deleteReminder(id);
  }

  Future<void> markRead(int id) async {
    await _db.markReminderRead(id);
  }
}
