import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _apiKey = 'dd549d14f548670d0853c92ec6f81ccd';
  static const bool _useMockData = true;

  WeatherService();

  static const Map<int, String> weatherCodeMap = {
    200: 'Thunderstorm with light rain',
    201: 'Thunderstorm with rain',
    202: 'Thunderstorm with heavy rain',
    210: 'Light thunderstorm',
    211: 'Thunderstorm',
    212: 'Heavy thunderstorm',
    221: 'Ragged thunderstorm',
    230: 'Thunderstorm with light drizzle',
    231: 'Thunderstorm with drizzle',
    232: 'Thunderstorm with heavy drizzle',
    300: 'Light intensity drizzle',
    301: 'Drizzle',
    302: 'Heavy intensity drizzle',
    310: 'Light intensity drizzle rain',
    311: 'Drizzle rain',
    312: 'Heavy intensity drizzle rain',
    313: 'Shower rain and drizzle',
    314: 'Heavy shower rain and drizzle',
    321: 'Shower drizzle',
    500: 'Light rain',
    501: 'Moderate rain',
    502: 'Heavy intensity rain',
    503: 'Very heavy rain',
    504: 'Extreme rain',
    511: 'Freezing rain',
    520: 'Light intensity shower rain',
    521: 'Shower rain',
    522: 'Heavy intensity shower rain',
    531: 'Ragged shower rain',
    600: 'Light snow',
    601: 'Snow',
    602: 'Heavy snow',
    611: 'Sleet',
    612: 'Light shower sleet',
    613: 'Shower sleet',
    615: 'Light rain and snow',
    616: 'Rain and snow',
    620: 'Light shower snow',
    621: 'Shower snow',
    622: 'Heavy shower snow',
    700: 'Mist',
    711: 'Smoke',
    721: 'Haze',
    731: 'Sand/dust whirls',
    741: 'Fog',
    751: 'Sand',
    761: 'Dust',
    762: 'Volcanic ash',
    771: 'Squalls',
    781: 'Tornado',
    800: 'Clear sky',
    801: 'Few clouds',
    802: 'Scattered clouds',
    803: 'Broken clouds',
    804: 'Overcast clouds',
  };

  String _getWeatherText(int code) {
    return weatherCodeMap[code] ?? 'Unknown';
  }

  String _mapCodeToIcon(int code) {
    if (code == 800) return '100';
    if (code <= 804) return '101';
    if (code <= 781) return '501';
    if (code <= 622) return '400';
    if (code <= 531) return '300';
    if (code <= 321) return '305';
    if (code <= 232) return '302';
    return '999';
  }

  Future<Map<String, dynamic>?> getCityLocation(String cityName) async {
    try {
      final url = Uri.https(
        'api.openweathermap.org',
        '/geo/1.0/direct',
        {
          'q': cityName,
          'limit': '1',
          'appid': _apiKey,
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"cod": 408, "message": "Request Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final location = data[0];
          return {
            'lat': location['lat'],
            'lon': location['lon'],
            'name': cityName,
          };
        }
      }
    } catch (e) {
      print('Location exception: $e');
    }
    return null;
  }

  Future<WeatherData?> getCurrentWeather(String cityName) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockWeatherData[cityName] ?? _mockWeatherData['Beijing'];
    }
    
    try {
      final location = await getCityLocation(cityName);
      if (location == null) {
        return null;
      }

      final url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'lat': location['lat'].toString(),
          'lon': location['lon'].toString(),
          'units': 'metric',
          'appid': _apiKey,
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"cod": 408, "message": "Request Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['weather'] != null && data['weather'].isNotEmpty) {
          final weather = data['weather'][0];
          final main = data['main'];
          final wind = data['wind'];
          final weatherCode = weather['id'] as int;
          final windSpeed = (wind['speed'] as num?)?.toDouble() ?? 0;
          final windDeg = (wind['deg'] as num?)?.toDouble() ?? 0;
          final visibility = (data['visibility'] as num?)?.toDouble() ?? 10000;

          return WeatherData(
            city: location['name'] ?? cityName,
            weatherText: _getWeatherText(weatherCode),
            weatherCode: _mapCodeToIcon(weatherCode),
            tempNow: (main['temp'] as num?)?.round() ?? 0,
            humidity: (main['humidity'] as num?)?.round() ?? 0,
            windDir: _mapWindDeg(windDeg),
            windScale: _mapWindSpeed(windSpeed),
            pressure: (main['pressure'] as num?)?.round() ?? 1013,
            visibility: (visibility / 1000).toStringAsFixed(1),
            updateTime: DateTime.now().toIso8601String(),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Weather exception: $e');
      print('Stack: $stackTrace');
    }
    return null;
  }

  Future<List<DailyForecast>> getDailyForecast(String cityName) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockForecastData[cityName] ?? _mockForecastData['Beijing'] ?? [];
    }
    
    try {
      final location = await getCityLocation(cityName);
      if (location == null) {
        return [];
      }

      final url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/forecast',
        {
          'lat': location['lat'].toString(),
          'lon': location['lon'].toString(),
          'units': 'metric',
          'appid': _apiKey,
        },
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"cod": 408, "message": "Request Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['list'] != null) {
          final list = data['list'] as List;

          final Map<String, List<dynamic>> dailyData = {};
          for (var item in list) {
            final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
            final dateKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            if (!dailyData.containsKey(dateKey)) {
              dailyData[dateKey] = [];
            }
            dailyData[dateKey]!.add(item);
          }

          final forecast = <DailyForecast>[];
          int count = 0;
          for (var entry in dailyData.entries) {
            if (count >= 5) break;
            final items = entry.value;
            items.sort((a, b) => (a['main']['temp'] as num).compareTo(b['main']['temp'] as num));

            final minItem = items.first;
            final maxItem = items.last;
            final midItem = items[items.length ~/ 2];

            final weather = midItem['weather'][0];
            final weatherCode = weather['id'] as int;

            forecast.add(DailyForecast(
              date: entry.key,
              dayText: _getWeatherText(weatherCode),
              nightText: _getWeatherText(weatherCode),
              tempMax: (maxItem['main']['temp'] as num?)?.round() ?? 0,
              tempMin: (minItem['main']['temp'] as num?)?.round() ?? 0,
              dayIcon: _mapCodeToIcon(weatherCode),
              nightIcon: _mapCodeToIcon(weatherCode),
            ));
            count++;
          }

          return forecast;
        }
      }
    } catch (e, stackTrace) {
      print('Forecast exception: $e');
      print('Stack: $stackTrace');
    }
    return [];
  }

  String _mapWindDeg(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'N';
    if (deg >= 22.5 && deg < 67.5) return 'NE';
    if (deg >= 67.5 && deg < 112.5) return 'E';
    if (deg >= 112.5 && deg < 157.5) return 'SE';
    if (deg >= 157.5 && deg < 202.5) return 'S';
    if (deg >= 202.5 && deg < 247.5) return 'SW';
    if (deg >= 247.5 && deg < 292.5) return 'W';
    if (deg >= 292.5 && deg < 337.5) return 'NW';
    return 'Unknown';
  }

  String _mapWindSpeed(double speed) {
    if (speed < 0.3) return '0';
    if (speed < 1.6) return '1';
    if (speed < 3.4) return '2';
    if (speed < 5.5) return '3';
    if (speed < 8.0) return '4';
    if (speed < 10.8) return '5';
    if (speed < 13.9) return '6';
    if (speed < 17.2) return '7';
    if (speed < 20.8) return '8';
    return '9+';
  }

  Map<String, WeatherData> _mockWeatherData = {
    'Beijing': WeatherData(
      city: 'Beijing',
      weatherText: 'Clear sky',
      weatherCode: '100',
      tempNow: 28,
      humidity: 45,
      windDir: 'N',
      windScale: '2',
      pressure: 1015,
      visibility: '10.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Shanghai': WeatherData(
      city: 'Shanghai',
      weatherText: 'Few clouds',
      weatherCode: '101',
      tempNow: 30,
      humidity: 65,
      windDir: 'SE',
      windScale: '3',
      pressure: 1013,
      visibility: '8.5',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Guangzhou': WeatherData(
      city: 'Guangzhou',
      weatherText: 'Light rain',
      weatherCode: '300',
      tempNow: 32,
      humidity: 78,
      windDir: 'S',
      windScale: '4',
      pressure: 1008,
      visibility: '6.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Shenzhen': WeatherData(
      city: 'Shenzhen',
      weatherText: 'Broken clouds',
      weatherCode: '101',
      tempNow: 31,
      humidity: 72,
      windDir: 'NE',
      windScale: '3',
      pressure: 1010,
      visibility: '9.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Hangzhou': WeatherData(
      city: 'Hangzhou',
      weatherText: 'Overcast clouds',
      weatherCode: '101',
      tempNow: 27,
      humidity: 60,
      windDir: 'E',
      windScale: '2',
      pressure: 1014,
      visibility: '7.5',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Chengdu': WeatherData(
      city: 'Chengdu',
      weatherText: 'Fog',
      weatherCode: '501',
      tempNow: 24,
      humidity: 85,
      windDir: 'SW',
      windScale: '1',
      pressure: 1016,
      visibility: '2.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Wuhan': WeatherData(
      city: 'Wuhan',
      weatherText: 'Thunderstorm with rain',
      weatherCode: '302',
      tempNow: 29,
      humidity: 70,
      windDir: 'NW',
      windScale: '5',
      pressure: 1009,
      visibility: '5.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Xian': WeatherData(
      city: 'Xian',
      weatherText: 'Clear sky',
      weatherCode: '100',
      tempNow: 26,
      humidity: 40,
      windDir: 'W',
      windScale: '2',
      pressure: 1018,
      visibility: '12.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Nanjing': WeatherData(
      city: 'Nanjing',
      weatherText: 'Scattered clouds',
      weatherCode: '101',
      tempNow: 28,
      humidity: 55,
      windDir: 'NE',
      windScale: '3',
      pressure: 1012,
      visibility: '8.0',
      updateTime: DateTime.now().toIso8601String(),
    ),
    'Chongqing': WeatherData(
      city: 'Chongqing',
      weatherText: 'Heavy intensity rain',
      weatherCode: '300',
      tempNow: 33,
      humidity: 82,
      windDir: 'S',
      windScale: '4',
      pressure: 1006,
      visibility: '4.5',
      updateTime: DateTime.now().toIso8601String(),
    ),
  };

  Map<String, List<DailyForecast>> _mockForecastData = {
    'Beijing': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 30, tempMin: 18, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 29, tempMin: 17, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Broken clouds', nightText: 'Few clouds', tempMax: 27, tempMin: 16, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Broken clouds', tempMax: 25, tempMin: 15, dayIcon: '300', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 28, tempMin: 16, dayIcon: '100', nightIcon: '100'),
    ],
    'Shanghai': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 32, tempMin: 22, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Overcast clouds', nightText: 'Broken clouds', tempMax: 31, tempMin: 23, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Light rain', tempMax: 29, tempMin: 22, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Thunderstorm', nightText: 'Light rain', tempMax: 28, tempMin: 21, dayIcon: '302', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 30, tempMin: 20, dayIcon: '100', nightIcon: '100'),
    ],
    'Guangzhou': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Light rain', nightText: 'Heavy rain', tempMax: 33, tempMin: 25, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Heavy rain', nightText: 'Light rain', tempMax: 32, tempMin: 24, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Thunderstorm', nightText: 'Thunderstorm', tempMax: 31, tempMin: 23, dayIcon: '302', nightIcon: '302'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 33, tempMin: 24, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 34, tempMin: 25, dayIcon: '100', nightIcon: '100'),
    ],
    'Shenzhen': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Broken clouds', nightText: 'Few clouds', tempMax: 32, tempMin: 25, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Overcast clouds', tempMax: 31, tempMin: 24, dayIcon: '300', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Heavy shower rain', nightText: 'Light rain', tempMax: 30, tempMin: 23, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 32, tempMin: 24, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 33, tempMin: 25, dayIcon: '100', nightIcon: '100'),
    ],
    'Hangzhou': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Overcast clouds', nightText: 'Broken clouds', tempMax: 28, tempMin: 20, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Light rain', tempMax: 26, tempMin: 19, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 27, tempMin: 18, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 29, tempMin: 19, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Broken clouds', nightText: 'Few clouds', tempMax: 28, tempMin: 20, dayIcon: '101', nightIcon: '101'),
    ],
    'Chengdu': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Fog', nightText: 'Mist', tempMax: 25, tempMin: 18, dayIcon: '501', nightIcon: '501'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Mist', nightText: 'Fog', tempMax: 24, tempMin: 17, dayIcon: '501', nightIcon: '501'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 26, tempMin: 16, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 27, tempMin: 17, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Overcast clouds', nightText: 'Broken clouds', tempMax: 25, tempMin: 18, dayIcon: '101', nightIcon: '101'),
    ],
    'Wuhan': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Thunderstorm', nightText: 'Heavy rain', tempMax: 30, tempMin: 22, dayIcon: '302', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Heavy rain', nightText: 'Light rain', tempMax: 28, tempMin: 21, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Clear sky', tempMax: 27, tempMin: 20, dayIcon: '300', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 29, tempMin: 19, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 30, tempMin: 20, dayIcon: '101', nightIcon: '100'),
    ],
    'Xian': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 27, tempMin: 12, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 28, tempMin: 13, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 26, tempMin: 12, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Broken clouds', nightText: 'Few clouds', tempMax: 25, tempMin: 11, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 27, tempMin: 12, dayIcon: '100', nightIcon: '100'),
    ],
    'Nanjing': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Scattered clouds', nightText: 'Few clouds', tempMax: 29, tempMin: 19, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Light rain', tempMax: 27, tempMin: 18, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Overcast clouds', nightText: 'Broken clouds', tempMax: 26, tempMin: 17, dayIcon: '101', nightIcon: '101'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 28, tempMin: 17, dayIcon: '100', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 29, tempMin: 18, dayIcon: '101', nightIcon: '100'),
    ],
    'Chongqing': [
      DailyForecast(date: DateTime.now().toString().substring(0, 10), dayText: 'Heavy rain', nightText: 'Thunderstorm', tempMax: 34, tempMin: 25, dayIcon: '300', nightIcon: '302'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10), dayText: 'Thunderstorm', nightText: 'Heavy rain', tempMax: 32, tempMin: 24, dayIcon: '302', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 2)).toString().substring(0, 10), dayText: 'Light rain', nightText: 'Light rain', tempMax: 31, tempMin: 23, dayIcon: '300', nightIcon: '300'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 3)).toString().substring(0, 10), dayText: 'Few clouds', nightText: 'Clear sky', tempMax: 33, tempMin: 23, dayIcon: '101', nightIcon: '100'),
      DailyForecast(date: DateTime.now().add(const Duration(days: 4)).toString().substring(0, 10), dayText: 'Clear sky', nightText: 'Clear sky', tempMax: 34, tempMin: 24, dayIcon: '100', nightIcon: '100'),
    ],
  };
}
