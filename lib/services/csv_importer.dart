import 'package:csv/csv.dart';
import '../models/course.dart';

class CsvImporter {
  static List<Course> parseFromText(String csvText) {
    final normalizedText = csvText.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalizedText.split('\n').where((line) => line.trim().isNotEmpty).toList();

    final rows = <List<dynamic>>[];
    for (final line in lines) {
      final row = const CsvToListConverter().convert(line).first;
      rows.add(row);
    }

    return _parseRows(rows);
  }

  static List<Course> _parseRows(List<List<dynamic>> rows) {
    List<Course> courses = [];

    if (rows.isEmpty) {
      return courses;
    }

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];

      if (row.isEmpty || row.length < 5) {
        continue;
      }

      final name = row[0].toString().trim();
      final classroom = row[1].toString().trim();
      final dayStr = row[2].toString().trim();
      final periodStr = row[3].toString().trim();
      final colorStr = row[4].toString().trim();

      if (name.isEmpty) {
        continue;
      }

      int dayOfWeek = _parseDayOfWeek(dayStr);
      int period = int.tryParse(periodStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      int colorIndex = int.tryParse(colorStr) ?? 0;

      int weekType = 0;
      if (row.length >= 6) {
        final weekTypeStr = row[5].toString().trim().toLowerCase();
        if (weekTypeStr.contains('odd') || weekTypeStr == '1') {
          weekType = 1;
        } else if (weekTypeStr.contains('even') || weekTypeStr == '2') {
          weekType = 2;
        }
      }

      courses.add(Course(
        name: name,
        classroom: classroom.isEmpty ? 'TBD' : classroom,
        dayOfWeek: dayOfWeek,
        period: period,
        colorIndex: colorIndex,
        weekType: weekType,
      ));
    }

    return courses;
  }

  static int _parseDayOfWeek(String str) {
    str = str.toLowerCase();

    if (str.contains('mon') || str.contains('1')) return 1;
    if (str.contains('tue') || str.contains('2')) return 2;
    if (str.contains('wed') || str.contains('3')) return 3;
    if (str.contains('thu') || str.contains('4')) return 4;
    if (str.contains('fri') || str.contains('5')) return 5;
    if (str.contains('sat') || str.contains('6')) return 6;
    if (str.contains('sun') || str.contains('7')) return 7;

    final num = int.tryParse(str.replaceAll(RegExp(r'[^0-9]'), ''));
    if (num != null && num >= 1 && num <= 7) return num;

    return 1;
  }

  static String getTemplate() {
    return 'Course Name,Classroom,Day,Period,Color,Week Type\nMath,Room A,1,1,0,Every week\nEnglish,Room B,2,2,1,Odd weeks\nPhysics,Lab,3,3,2,Even weeks';
  }
}
