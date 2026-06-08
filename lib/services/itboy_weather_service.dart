import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'city_codes.dart';

class ItBoyWeatherService {
  static const String _baseUrl = 'http://t.weather.itboy.net/api/weather/city';
  static const bool _useMockData = true;

  ItBoyWeatherService();

  Future<WeatherData?> getCurrentWeather(String cityName) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockCurrentWeather(cityName);
    }

    try {
      String cityCode = CityCode.getCityCode(cityName);
      if (cityCode.isEmpty) {
        return _getMockCurrentWeather(cityName);
      }

      final url = Uri.parse('$_baseUrl/$cityCode');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"cod": 408, "message": "Request Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['status'] == 200 && data['data'] != null) {
          final cityInfo = data['cityInfo'];
          final weatherData = data['data'];
          final forecast = weatherData['forecast'] as List;
          
          if (forecast.isNotEmpty) {
            final today = forecast[0];
            
            String weatherText = today['type'] ?? 'Unknown';
            String tempNow = weatherData['wendu']?.toString() ?? '0';
            String humidity = weatherData['shidu']?.toString() ?? '0%';
            String fx = today['fx'] ?? 'Unknown';
            String fl = today['fl'] ?? 'Unknown';
            
            String highStr = today['high']?.toString() ?? '???? 0??';
            String lowStr = today['low']?.toString() ?? '???? 0??';
            
            int tempHigh = _extractTemperature(highStr);
            int tempLow = _extractTemperature(lowStr);
            
            // Translate Chinese weather text to English
            weatherText = _translateWeatherText(weatherText);
            fx = _translateWindDirection(fx);
            fl = _translateWindScale(fl);
            
            return WeatherData(
              city: cityInfo['city'] ?? cityName,
              weatherText: weatherText,
              weatherCode: _mapWeatherTypeToCode(weatherText),
              tempNow: int.tryParse(tempNow) ?? tempHigh,
              humidity: _extractHumidity(humidity),
              windDir: fx,
              windScale: fl,
              pressure: 1013,
              visibility: '10.0',
              updateTime: DateTime.now().toIso8601String(),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      print('ItBoy Weather exception: $e');
      print('Stack: $stackTrace');
    }
    return _getMockCurrentWeather(cityName);
  }

  Future<List<DailyForecast>> getDailyForecast(String cityName) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockDailyForecast(cityName);
    }

    try {
      String cityCode = CityCode.getCityCode(cityName);
      if (cityCode.isEmpty) {
        return _getMockDailyForecast(cityName);
      }

      final url = Uri.parse('$_baseUrl/$cityCode');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return http.Response('{"cod": 408, "message": "Request Timeout"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['status'] == 200 && data['data'] != null) {
          final forecast = data['data']['forecast'] as List;
          
          final List<DailyForecast> result = [];
          int count = 0;
          
          for (var item in forecast) {
            if (count >= 5) break;
            
            String weatherText = item['type'] ?? 'Unknown';
            String highStr = item['high']?.toString() ?? '???? 0??';
            String lowStr = item['low']?.toString() ?? '???? 0??';
            String date = item['ymd'] ?? '';
            
            int tempHigh = _extractTemperature(highStr);
            int tempLow = _extractTemperature(lowStr);
            
            // Translate Chinese weather text to English
            weatherText = _translateWeatherText(weatherText);
            
            result.add(DailyForecast(
              date: date,
              dayText: weatherText,
              nightText: weatherText,
              tempMax: tempHigh,
              tempMin: tempLow,
              dayIcon: _mapWeatherTypeToCode(weatherText),
              nightIcon: _mapWeatherTypeToCode(weatherText),
            ));
            
            count++;
          }
          
          return result;
        }
      }
    } catch (e, stackTrace) {
      print('ItBoy Forecast exception: $e');
      print('Stack: $stackTrace');
    }
    return _getMockDailyForecast(cityName);
  }

  int _extractTemperature(String tempStr) {
    try {
      if (tempStr.isEmpty) return 0;
      
      List<String> parts = tempStr.split(' ');
      if (parts.length >= 2) {
        String tempPart = parts[1];
        String numStr = tempPart.replaceAll('??', '').replaceAll('??C', '');
        return int.tryParse(numStr) ?? 0;
      }
      
      RegExp reg = RegExp(r'\d+');
      Match? match = reg.firstMatch(tempStr);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 0;
      }
    } catch (e) {
      print('Extract temperature error: $e');
    }
    return 0;
  }

  int _extractHumidity(String humidityStr) {
    try {
      String numStr = humidityStr.replaceAll('%', '');
      return int.tryParse(numStr) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  String _translateWeatherText(String chineseText) {
    if (chineseText.contains('??')) return 'Clear';
    if (chineseText.contains('????')) return 'Cloudy';
    if (chineseText.contains('??')) return 'Overcast';
    if (chineseText.contains('??????')) return 'Thunderstorms';
    if (chineseText.contains('????')) return 'Showers';
    if (chineseText.contains('С??')) return 'Light Rain';
    if (chineseText.contains('????')) return 'Moderate Rain';
    if (chineseText.contains('????')) return 'Heavy Rain';
    if (chineseText.contains('????')) return 'Storm';
    if (chineseText.contains('????')) return 'Sleet';
    if (chineseText.contains('С?')) return 'Light Snow';
    if (chineseText.contains('???')) return 'Moderate Snow';
    if (chineseText.contains('???')) return 'Heavy Snow';
    if (chineseText.contains('???')) return 'Blizzard';
    if (chineseText.contains('??')) return 'Fog';
    if (chineseText.contains('??')) return 'Haze';
    if (chineseText.contains('?????')) return 'Sandstorm';
    return chineseText;
  }

  String _translateWindDirection(String chineseText) {
    if (chineseText.contains('??')) return 'North';
    if (chineseText.contains('????')) return 'Northeast';
    if (chineseText.contains('??')) return 'East';
    if (chineseText.contains('????')) return 'Southeast';
    if (chineseText.contains('??')) return 'South';
    if (chineseText.contains('????')) return 'Southwest';
    if (chineseText.contains('??')) return 'West';
    if (chineseText.contains('????')) return 'Northwest';
    return chineseText;
  }

  String _translateWindScale(String chineseText) {
    return chineseText.replaceAll(RegExp(r'[^\d-]'), '');
  }

  String _mapWeatherTypeToCode(String type) {
    if (type.contains('??') || type.toLowerCase().contains('clear') || type.toLowerCase().contains('sunny')) return '100';
    if (type.contains('????') || type.toLowerCase().contains('cloudy')) return '101';
    if (type.contains('??') || type.toLowerCase().contains('overcast')) return '104';
    if (type.contains('??????') || type.toLowerCase().contains('thunder')) return '302';
    if (type.contains('????') || type.toLowerCase().contains('shower')) return '300';
    if (type.contains('??') || type.toLowerCase().contains('rain')) return '305';
    if (type.contains('?') || type.toLowerCase().contains('snow')) return '401';
    if (type.contains('??') || type.toLowerCase().contains('fog')) return '501';
    if (type.contains('??') || type.toLowerCase().contains('haze')) return '502';
    if (type.contains('?????') || type.toLowerCase().contains('sand')) return '503';
    return '100';
  }

  WeatherData _getMockCurrentWeather(String cityName) {
    final mockWeatherData = {
      '北京': WeatherData(
        city: '北京',
        weatherText: 'Clear',
        weatherCode: '100',
        tempNow: 22,
        humidity: 45,
        windDir: 'Northeast',
        windScale: '3-4',
        pressure: 1013,
        visibility: '10.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '上海': WeatherData(
        city: '上海',
        weatherText: 'Cloudy',
        weatherCode: '101',
        tempNow: 24,
        humidity: 55,
        windDir: 'Southeast',
        windScale: '2-3',
        pressure: 1015,
        visibility: '8.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '广州': WeatherData(
        city: '广州',
        weatherText: 'Showers',
        weatherCode: '300',
        tempNow: 28,
        humidity: 75,
        windDir: 'South',
        windScale: '1-2',
        pressure: 1010,
        visibility: '6.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '深圳': WeatherData(
        city: '深圳',
        weatherText: 'Overcast',
        weatherCode: '104',
        tempNow: 27,
        humidity: 70,
        windDir: 'Southwest',
        windScale: '2',
        pressure: 1011,
        visibility: '7.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '杭州': WeatherData(
        city: '杭州',
        weatherText: 'Clear',
        weatherCode: '100',
        tempNow: 23,
        humidity: 50,
        windDir: 'East',
        windScale: '2-3',
        pressure: 1012,
        visibility: '9.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '成都': WeatherData(
        city: '成都',
        weatherText: 'Overcast',
        weatherCode: '104',
        tempNow: 20,
        humidity: 65,
        windDir: 'North',
        windScale: '1-2',
        pressure: 1014,
        visibility: '5.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '武汉': WeatherData(
        city: '武汉',
        weatherText: 'Cloudy',
        weatherCode: '101',
        tempNow: 25,
        humidity: 60,
        windDir: 'Northeast',
        windScale: '3',
        pressure: 1013,
        visibility: '8.5',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '西安': WeatherData(
        city: '西安',
        weatherText: 'Clear',
        weatherCode: '100',
        tempNow: 19,
        humidity: 40,
        windDir: 'West',
        windScale: '2-3',
        pressure: 1016,
        visibility: '9.5',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '南京': WeatherData(
        city: '南京',
        weatherText: 'Clear',
        weatherCode: '100',
        tempNow: 21,
        humidity: 48,
        windDir: 'Southeast',
        windScale: '2',
        pressure: 1012,
        visibility: '9.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '重庆': WeatherData(
        city: '重庆',
        weatherText: 'Overcast',
        weatherCode: '104',
        tempNow: 23,
        humidity: 70,
        windDir: 'East',
        windScale: '1-2',
        pressure: 1011,
        visibility: '6.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
      '昆明': WeatherData(
        city: '昆明',
        weatherText: 'Partly Cloudy',
        weatherCode: '101',
        tempNow: 20,
        humidity: 60,
        windDir: 'Southwest',
        windScale: '2',
        pressure: 1012,
        visibility: '10.0',
        updateTime: DateTime.now().toIso8601String(),
      ),
    };
    return mockWeatherData[cityName] ?? mockWeatherData['北京']!;
  }

  List<DailyForecast> _getMockDailyForecast(String cityName) {
    final mockForecasts = [
      DailyForecast(
        date: DateTime.now().toIso8601String(),
        dayText: 'Clear',
        nightText: 'Clear',
        tempMax: 26,
        tempMin: 15,
        dayIcon: '100',
        nightIcon: '100',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        dayText: 'Cloudy',
        nightText: 'Cloudy',
        tempMax: 24,
        tempMin: 14,
        dayIcon: '101',
        nightIcon: '101',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        dayText: 'Showers',
        nightText: 'Light Rain',
        tempMax: 22,
        tempMin: 13,
        dayIcon: '300',
        nightIcon: '305',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        dayText: 'Overcast',
        nightText: 'Overcast',
        tempMax: 20,
        tempMin: 12,
        dayIcon: '104',
        nightIcon: '104',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        dayText: 'Clear',
        nightText: 'Clear',
        tempMax: 25,
        tempMin: 14,
        dayIcon: '100',
        nightIcon: '100',
      ),
    ];
    return mockForecasts;
  }
}
