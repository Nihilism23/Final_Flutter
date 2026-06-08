import 'package:shared_preferences/shared_preferences.dart';
import 'city_coordinates.dart';

class CityManager {
  static const String _citiesKey = 'user_cities';
  static const String _currentCityKey = 'current_city';

  static Future<List<String>> getCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList(_citiesKey);
    if (citiesJson == null || citiesJson.isEmpty) {
      return ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Chengdu'];
    }
    return citiesJson;
  }

  static Future<void> saveCities(List<String> cities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_citiesKey, cities);
  }

  static Future<String> getCurrentCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentCityKey) ?? 'Beijing';
  }

  static Future<void> setCurrentCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentCityKey, city);
  }

  static Future<void> addCity(String city) async {
    final cities = await getCities();
    if (!cities.contains(city)) {
      cities.add(city);
      await saveCities(cities);
    }
  }

  static Future<void> removeCity(String city) async {
    final cities = await getCities();
    cities.remove(city);
    await saveCities(cities);
    final current = await getCurrentCity();
    if (current == city && cities.isNotEmpty) {
      await setCurrentCity(cities.first);
    }
  }

  static String getCityDisplayName(String city) {
    return city;
  }

  static List<String> getAvailableCities() {
    return CityCoordinates.getAllCities();
  }

  static List<String> getAvailableCitiesToAdd(List<String> existingCities) {
    return CityCoordinates.getAllCities().where((city) => !existingCities.contains(city)).toList();
  }
}
