class WeatherData {
  final String city;
  final String weatherText;
  final String weatherCode;
  final int tempNow;
  final int humidity;
  final String windDir;
  final String windScale;
  final int pressure;
  final String visibility;
  final String updateTime;
  final List<HourlyForecast>? hourly;
  final List<LifeIndexItem>? lifeIndex;
  final double? aqi;

  WeatherData({
    required this.city,
    required this.weatherText,
    required this.weatherCode,
    required this.tempNow,
    required this.humidity,
    required this.windDir,
    required this.windScale,
    required this.pressure,
    required this.visibility,
    required this.updateTime,
    this.hourly,
    this.lifeIndex,
    this.aqi,
  });
}

class DailyForecast {
  final String date;
  final String dayText;
  final String nightText;
  final int tempMax;
  final int tempMin;
  final String dayIcon;
  final String nightIcon;

  DailyForecast({
    required this.date,
    required this.dayText,
    required this.nightText,
    required this.tempMax,
    required this.tempMin,
    required this.dayIcon,
    required this.nightIcon,
  });
}

class HourlyForecast {
  final String time;
  final String weatherText;
  final String weatherCode;
  final int temperature;
  final int humidity;

  HourlyForecast({
    required this.time,
    required this.weatherText,
    required this.weatherCode,
    required this.temperature,
    required this.humidity,
  });
}

class LifeIndexItem {
  final String name;
  final String level;
  final String description;

  LifeIndexItem({
    required this.name,
    required this.level,
    required this.description,
  });
}

class WeatherIconHelper {
  static const Map<String, String> weatherTextMap = {
    '100': 'Sunny',
    '101': 'Cloudy',
    '102': 'Partly Cloudy',
    '103': 'Mostly Sunny',
    '104': 'Overcast',
    '150': 'Clear Night',
    '300': 'Shower',
    '301': 'Heavy Shower',
    '302': 'Thunderstorm',
    '303': 'Severe Thunderstorm',
    '304': 'Thunderstorm with Hail',
    '305': 'Light Rain',
    '306': 'Moderate Rain',
    '307': 'Heavy Rain',
    '308': 'Extreme Rain',
    '309': 'Drizzle',
    '310': 'Storm',
    '311': 'Heavy Storm',
    '312': 'Severe Storm',
    '313': 'Freezing Rain',
    '314': 'Light to Moderate Rain',
    '315': 'Moderate to Heavy Rain',
    '316': 'Heavy to Storm',
    '317': 'Storm to Heavy Storm',
    '318': 'Heavy to Severe Storm',
    '399': 'Rain',
    '400': 'Light Snow',
    '401': 'Moderate Snow',
    '402': 'Heavy Snow',
    '403': 'Blizzard',
    '404': 'Sleet',
    '405': 'Rain and Snow',
    '406': 'Shower Snow',
    '407': 'Snow Shower',
    '499': 'Snow',
    '500': 'Mist',
    '501': 'Fog',
    '502': 'Haze',
    '503': 'Sand',
    '504': 'Dust',
    '507': 'Sandstorm',
    '508': 'Severe Sandstorm',
    '509': 'Dense Fog',
    '510': 'Thick Fog',
    '511': 'Moderate Haze',
    '512': 'Heavy Haze',
    '513': 'Severe Haze',
    '514': 'Heavy Fog',
    '515': 'Extreme Fog',
    '900': 'Hot',
    '901': 'Cold',
    '999': 'Unknown',
  };

  static bool needUmbrella(String code) {
    final codeInt = int.tryParse(code) ?? 0;
    return codeInt >= 300 && codeInt < 500;
  }

  static String getWeatherType(String code) {
    final codeInt = int.tryParse(code) ?? 100;
    if (codeInt == 100 || codeInt == 150) return 'sunny';
    if (codeInt < 200) return 'cloudy';
    if (codeInt >= 300 && codeInt < 400) return 'rainy';
    if (codeInt >= 400 && codeInt < 500) return 'snowy';
    if (codeInt >= 500) return 'foggy';
    return 'sunny';
  }

  static String formatDateLabel(String dateStr, int index) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';
    if (index == 2) return 'Day after';
    try {
      final date = DateTime.parse(dateStr);
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } catch (_) {
      return dateStr;
    }
  }

  static String getWeatherTextCN(String type) {
    switch (type) {
      case 'sunny':
        return 'Sunny';
      case 'cloudy':
        return 'Cloudy';
      case 'rainy':
        return 'Rain';
      case 'snowy':
        return 'Snow';
      case 'foggy':
        return 'Fog';
      default:
        return 'Unknown';
    }
  }
}
