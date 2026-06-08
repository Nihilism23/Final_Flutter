import '../models/weather.dart';
import 'weather_service.dart';
import 'itboy_weather_service.dart';
import 'caiyun_weather_service.dart';

enum WeatherSource {
  openWeatherMap,
  itBoy,
  caiyun,
}

class WeatherServiceManager {
  static WeatherSource _currentSource = WeatherSource.caiyun;
  static final WeatherService _openWeatherService = WeatherService();
  static final ItBoyWeatherService _itBoyService = ItBoyWeatherService();
  static final CaiyunWeatherService _caiyunService = CaiyunWeatherService();

  static void setWeatherSource(WeatherSource source) {
    _currentSource = source;
  }

  static WeatherSource get currentSource => _currentSource;

  static Future<WeatherData?> getCurrentWeather(String cityName) async {
    switch (_currentSource) {
      case WeatherSource.openWeatherMap:
        return await _openWeatherService.getCurrentWeather(cityName);
      case WeatherSource.itBoy:
        return await _itBoyService.getCurrentWeather(cityName);
      case WeatherSource.caiyun:
        return await _caiyunService.getCurrentWeather(cityName);
    }
  }

  static Future<List<DailyForecast>> getDailyForecast(String cityName) async {
    switch (_currentSource) {
      case WeatherSource.openWeatherMap:
        return await _openWeatherService.getDailyForecast(cityName);
      case WeatherSource.itBoy:
        return await _itBoyService.getDailyForecast(cityName);
      case WeatherSource.caiyun:
        return await _caiyunService.getDailyForecast(cityName);
    }
  }

  static String getSourceName(WeatherSource source) {
    switch (source) {
      case WeatherSource.openWeatherMap:
        return 'OpenWeatherMap';
      case WeatherSource.itBoy:
        return 'itBoy Weather';
      case WeatherSource.caiyun:
        return 'Caiyun Weather';
    }
  }

  static String getSourceDescription(WeatherSource source) {
    switch (source) {
      case WeatherSource.openWeatherMap:
        return 'International Weather API, supports global cities';
      case WeatherSource.itBoy:
        return 'Free domestic weather API, no API key required';
      case WeatherSource.caiyun:
        return 'Professional weather service by Caiyun';
    }
  }
}
