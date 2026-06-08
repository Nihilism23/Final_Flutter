import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'city_coordinates.dart';

class CaiyunWeatherService {
  static const String _apiKey = 'lcpDbON9IIfpiA8i';
  static const String _baseUrl = 'https://api.caiyunapp.com/v2.6';
  static const bool _useMockData = false;

  static final Map<String, String> _skyconToEnglish = {
    "CLEAR_DAY": "Clear",
    "CLEAR_NIGHT": "Clear",
    "PARTLY_CLOUDY_DAY": "Partly Cloudy",
    "PARTLY_CLOUDY_NIGHT": "Partly Cloudy",
    "CLOUDY": "Overcast",
    "LIGHT_HAZE": "Light Haze",
    "MODERATE_HAZE": "Moderate Haze",
    "HEAVY_HAZE": "Heavy Haze",
    "LIGHT_RAIN": "Light Rain",
    "MODERATE_RAIN": "Moderate Rain",
    "HEAVY_RAIN": "Heavy Rain",
    "STORM_RAIN": "Storm Rain",
    "FOG": "Fog",
    "LIGHT_SNOW": "Light Snow",
    "MODERATE_SNOW": "Moderate Snow",
    "HEAVY_SNOW": "Heavy Snow",
    "STORM_SNOW": "Storm Snow",
    "DUST": "Dust",
    "SAND": "Sand",
    "WIND": "Windy",
  };

  static String _mapDirectionToEnglish(double direction) {
    if (direction >= 337.5 || direction < 22.5) return "North";
    if (direction >= 22.5 && direction < 67.5) return "Northeast";
    if (direction >= 67.5 && direction < 112.5) return "East";
    if (direction >= 112.5 && direction < 157.5) return "Southeast";
    if (direction >= 157.5 && direction < 202.5) return "South";
    if (direction >= 202.5 && direction < 247.5) return "Southwest";
    if (direction >= 247.5 && direction < 292.5) return "West";
    if (direction >= 292.5 && direction < 337.5) return "Northwest";
    return "North";
  }

  CaiyunWeatherService();

  Future<WeatherData?> getCurrentWeather(String cityName) async {
    if (_useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _getMockCurrentWeather(cityName);
    }

    try {
      final coords = CityCoordinates.getCoordinates(cityName);
      if (coords == null) {
        return _getMockCurrentWeather(cityName);
      }

      final url = Uri.parse('$_baseUrl/$_apiKey/${coords["lon"]},${coords["lat"]}/weather?dailysteps=5&hourlysteps=24');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return http.Response('{"status": "error"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data["status"] == "ok" && data["result"] != null) {
          final result = data["result"];
          final realtime = result["realtime"];
          final daily = result["daily"];
          final hourly = result["hourly"];

          String skycon = realtime["skycon"] ?? "CLEAR_DAY";
          int temperature = realtime["temperature"]?.toInt() ?? 25;
          double humidity = realtime["humidity"]?.toDouble() ?? 0.5;
          double visibility = realtime["visibility"]?.toDouble() ?? 10.0;
          double pressure = realtime["pressure"]?.toDouble() ?? 1013.0;

          final wind = realtime["wind"];
          double windSpeed = wind?["speed"]?.toDouble() ?? 0.0;
          double windDirection = wind?["direction"]?.toDouble() ?? 0.0;

          final aqiObj = realtime["air_quality"]?["aqi"]?["chn"];
          double aqi = aqiObj?.toDouble() ?? 0.0;

          String weatherText = _skyconToEnglish[skycon] ?? "Clear";
          String windDir = _mapDirectionToEnglish(windDirection);

          List<HourlyForecast>? hourlyList;
          if (hourly != null) {
            final hourlyTemp = hourly["temperature"] as List?;
            final hourlySkycon = hourly["skycon"] as List?;
            final hourlyHumidity = hourly["humidity"] as List?;
            
            if (hourlyTemp != null && hourlySkycon != null && hourlyHumidity != null) {
              hourlyList = [];
              final count = hourlyTemp.length > 24 ? 24 : hourlyTemp.length;
              for (int i = 0; i < count; i++) {
                final tempItem = hourlyTemp[i];
                final skyconItem = hourlySkycon[i];
                final humidityItem = hourlyHumidity[i];
                
                DateTime dt = DateTime.tryParse(tempItem["datetime"] ?? "") ?? DateTime.now();
                String timeStr = "${dt.hour}:00";
                int temp = tempItem["value"]?.toInt() ?? 25;
                int hum = (humidityItem["value"]?.toDouble() ?? 0.5 * 100).toInt();
                String sk = skyconItem["value"] ?? "CLEAR_DAY";
                
                hourlyList.add(HourlyForecast(
                  time: timeStr,
                  weatherText: _skyconToEnglish[sk] ?? "Clear",
                  weatherCode: sk,
                  temperature: temp,
                  humidity: hum,
                ));
              }
            }
          }

          List<LifeIndexItem>? lifeIndexList = [
            LifeIndexItem(name: "UV Index", level: "Moderate", description: "Wear sunglasses"),
            LifeIndexItem(name: "Comfort", level: "Good", description: "Nice weather"),
          ];

          return WeatherData(
            city: cityName,
            weatherText: weatherText,
            weatherCode: skycon,
            tempNow: temperature,
            humidity: (humidity * 100).toInt(),
            windDir: windDir,
            windScale: windSpeed.toStringAsFixed(1),
            pressure: pressure.toInt(),
            visibility: visibility.toStringAsFixed(1),
            updateTime: DateTime.now().toIso8601String(),
            hourly: hourlyList,
            lifeIndex: lifeIndexList,
            aqi: aqi,
          );
        }
      }
    } catch (e, stackTrace) {
      print('Caiyun Weather exception: $e');
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
      final coords = CityCoordinates.getCoordinates(cityName);
      if (coords == null) {
        return _getMockDailyForecast(cityName);
      }

      final url = Uri.parse('$_baseUrl/$_apiKey/${coords["lon"]},${coords["lat"]}/weather?dailysteps=5&hourlysteps=48');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return http.Response('{"status": "error"}', 408);
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data["status"] == "ok" && data["result"] != null) {
          final daily = data["result"]["daily"];
          final temperature = daily["temperature"];
          final skycon = daily["skycon"];

          final List<DailyForecast> resultList = [];
          final count = temperature.length > 5 ? 5 : temperature.length;

          for (int i = 0; i < count; i++) {
            final temp = temperature[i];
            final sky = skycon[i];

            String weatherText = _skyconToEnglish[sky["value"]] ?? "Clear";
            int tempMax = temp["max"]?.toInt() ?? 28;
            int tempMin = temp["min"]?.toInt() ?? 18;
            String date = temp["date"] ?? DateTime.now().toIso8601String();

            resultList.add(DailyForecast(
              date: date,
              dayText: weatherText,
              nightText: weatherText,
              tempMax: tempMax,
              tempMin: tempMin,
              dayIcon: sky["value"],
              nightIcon: sky["value"],
            ));
          }

          return resultList;
        }
      }
    } catch (e, stackTrace) {
      print('Caiyun Forecast exception: $e');
      print('Stack: $stackTrace');
    }
    return _getMockDailyForecast(cityName);
  }

  WeatherData _getMockCurrentWeather(String cityName) {
    List<HourlyForecast> mockHourly = [];
    int currentHour = DateTime.now().hour;
    for (int i = 0; i < 24; i++) {
      int hour = (currentHour + i) % 24;
      String timeStr = "$hour:00";
      int temp = 22 + (i % 6) - 3;
      String skycon = i < 6 ? 'CLEAR_DAY' : 'PARTLY_CLOUDY_DAY';
      mockHourly.add(HourlyForecast(
        time: timeStr,
        weatherText: _skyconToEnglish[skycon] ?? "Clear",
        weatherCode: skycon,
        temperature: temp,
        humidity: 45 + i,
      ));
    }

    List<LifeIndexItem> mockLifeIndex = [
      LifeIndexItem(name: "UV Index", level: "Moderate", description: "Wear sunglasses"),
      LifeIndexItem(name: "Comfort", level: "Good", description: "Nice weather"),
      LifeIndexItem(name: "Sports", level: "Suitable", description: "Great for outdoor activities"),
    ];

    final mockWeatherData = {
      'Beijing': WeatherData(
        city: 'Beijing',
        weatherText: 'Clear',
        weatherCode: 'CLEAR_DAY',
        tempNow: 22,
        humidity: 45,
        windDir: 'Northeast',
        windScale: '3.2',
        pressure: 1013,
        visibility: '10.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 55.0,
      ),
      'Shanghai': WeatherData(
        city: 'Shanghai',
        weatherText: 'Partly Cloudy',
        weatherCode: 'PARTLY_CLOUDY_DAY',
        tempNow: 24,
        humidity: 55,
        windDir: 'Southeast',
        windScale: '2.5',
        pressure: 1015,
        visibility: '8.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 75.0,
      ),
      'Guangzhou': WeatherData(
        city: 'Guangzhou',
        weatherText: 'Light Rain',
        weatherCode: 'LIGHT_RAIN',
        tempNow: 28,
        humidity: 75,
        windDir: 'South',
        windScale: '1.8',
        pressure: 1010,
        visibility: '6.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 45.0,
      ),
      'Shenzhen': WeatherData(
        city: 'Shenzhen',
        weatherText: 'Overcast',
        weatherCode: 'CLOUDY',
        tempNow: 27,
        humidity: 70,
        windDir: 'Southwest',
        windScale: '2.1',
        pressure: 1011,
        visibility: '7.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 65.0,
      ),
      'Hangzhou': WeatherData(
        city: 'Hangzhou',
        weatherText: 'Clear',
        weatherCode: 'CLEAR_DAY',
        tempNow: 23,
        humidity: 50,
        windDir: 'East',
        windScale: '2.3',
        pressure: 1012,
        visibility: '9.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 35.0,
      ),
      'Chengdu': WeatherData(
        city: 'Chengdu',
        weatherText: 'Overcast',
        weatherCode: 'CLOUDY',
        tempNow: 20,
        humidity: 65,
        windDir: 'North',
        windScale: '1.5',
        pressure: 1014,
        visibility: '5.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 95.0,
      ),
      'Wuhan': WeatherData(
        city: 'Wuhan',
        weatherText: 'Partly Cloudy',
        weatherCode: 'PARTLY_CLOUDY_DAY',
        tempNow: 25,
        humidity: 60,
        windDir: 'Northeast',
        windScale: '2.8',
        pressure: 1013,
        visibility: '8.5',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 55.0,
      ),
      'Xi\'an': WeatherData(
        city: 'Xi\'an',
        weatherText: 'Clear',
        weatherCode: 'CLEAR_DAY',
        tempNow: 19,
        humidity: 40,
        windDir: 'West',
        windScale: '3.0',
        pressure: 1016,
        visibility: '9.5',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 40.0,
      ),
      'Nanjing': WeatherData(
        city: 'Nanjing',
        weatherText: 'Clear',
        weatherCode: 'CLEAR_DAY',
        tempNow: 21,
        humidity: 48,
        windDir: 'Southeast',
        windScale: '2.0',
        pressure: 1012,
        visibility: '9.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 50.0,
      ),
      'Chongqing': WeatherData(
        city: 'Chongqing',
        weatherText: 'Overcast',
        weatherCode: 'CLOUDY',
        tempNow: 23,
        humidity: 70,
        windDir: 'East',
        windScale: '1.9',
        pressure: 1011,
        visibility: '6.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 85.0,
      ),
      'Kunming': WeatherData(
        city: 'Kunming',
        weatherText: 'Partly Cloudy',
        weatherCode: 'PARTLY_CLOUDY_DAY',
        tempNow: 20,
        humidity: 60,
        windDir: 'Southwest',
        windScale: '2.0',
        pressure: 1012,
        visibility: '10.0',
        updateTime: DateTime.now().toIso8601String(),
        hourly: mockHourly,
        lifeIndex: mockLifeIndex,
        aqi: 45.0,
      ),
    };
    return mockWeatherData[cityName] ?? mockWeatherData['Beijing']!;
  }

  List<DailyForecast> _getMockDailyForecast(String cityName) {
    final mockForecasts = [
      DailyForecast(
        date: DateTime.now().toIso8601String(),
        dayText: 'Clear',
        nightText: 'Clear',
        tempMax: 26,
        tempMin: 15,
        dayIcon: 'CLEAR_DAY',
        nightIcon: 'CLEAR_NIGHT',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        dayText: 'Partly Cloudy',
        nightText: 'Partly Cloudy',
        tempMax: 24,
        tempMin: 14,
        dayIcon: 'PARTLY_CLOUDY_DAY',
        nightIcon: 'PARTLY_CLOUDY_NIGHT',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        dayText: 'Light Rain',
        nightText: 'Light Rain',
        tempMax: 22,
        tempMin: 13,
        dayIcon: 'LIGHT_RAIN',
        nightIcon: 'LIGHT_RAIN',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 3)).toIso8601String(),
        dayText: 'Overcast',
        nightText: 'Overcast',
        tempMax: 20,
        tempMin: 12,
        dayIcon: 'CLOUDY',
        nightIcon: 'CLOUDY',
      ),
      DailyForecast(
        date: DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        dayText: 'Clear',
        nightText: 'Clear',
        tempMax: 25,
        tempMin: 14,
        dayIcon: 'CLEAR_DAY',
        nightIcon: 'CLEAR_NIGHT',
      ),
    ];
    return mockForecasts;
  }
}
