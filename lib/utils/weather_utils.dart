import 'package:flutter_weather_bg/flutter_weather_bg.dart';

class WeatherUtils {
  static final weatherMap = {
    "CLEAR_DAY": "Çç",
    "CLEAR_NIGHT": "Çç",
    "PARTLY_CLOUDY_DAY": "¶àÔÆ",
    "PARTLY_CLOUDY_NIGHT": "¶àÔÆ",
    "CLOUDY": "Òõ",
    "LIGHT_HAZE": "ö²",
    "MODERATE_HAZE": "ö²",
    "HEAVY_HAZE": "ö²",
    "LIGHT_RAIN": "Ğ¡Óê",
    "MODERATE_RAIN": "ÖĞÓê",
    "HEAVY_RAIN": "´óÓê",
    "STORM_RAIN": "±©Óê",
    "FOG": "Îí",
    "LIGHT_SNOW": "Ğ¡Ñ©",
    "MODERATE_SNOW": "ÖĞÑ©",
    "HEAVY_SNOW": "´óÑ©",
    "STORM_SNOW": "±©Ñ©",
    "DUST": "¸¡³¾",
    "SAND": "É³³¾",
    "WIND": "´ó·ç",
  };

  static final weatherTypeMap = {
    "CLEAR_DAY": WeatherType.sunny,
    "CLEAR_NIGHT": WeatherType.sunnyNight,
    "PARTLY_CLOUDY_DAY": WeatherType.cloudy,
    "PARTLY_CLOUDY_NIGHT": WeatherType.cloudyNight,
    "CLOUDY": WeatherType.overcast,
    "LIGHT_HAZE": WeatherType.hazy,
    "MODERATE_HAZE": WeatherType.hazy,
    "HEAVY_HAZE": WeatherType.hazy,
    "LIGHT_RAIN": WeatherType.lightRainy,
    "MODERATE_RAIN": WeatherType.middleRainy,
    "HEAVY_RAIN": WeatherType.heavyRainy,
    "STORM_RAIN": WeatherType.thunder,
    "FOG": WeatherType.foggy,
    "LIGHT_SNOW": WeatherType.lightSnow,
    "MODERATE_SNOW": WeatherType.middleSnow,
    "HEAVY_SNOW": WeatherType.heavySnow,
    "STORM_SNOW": WeatherType.heavySnow,
    "DUST": WeatherType.dusty,
    "SAND": WeatherType.dusty,
    "WIND": WeatherType.overcast,
  };

  static String getWeatherText(String skycon) {
    if (weatherMap[skycon] == null || weatherMap[skycon]!.isEmpty) {
      return "Çç";
    }
    return weatherMap[skycon]!;
  }

  static WeatherType getWeatherType(String skycon) {
    if (weatherTypeMap[skycon] == null) {
      return WeatherType.sunny;
    }
    return weatherTypeMap[skycon]!;
  }

  static String getAqiDesc(double aqi) {
    if (aqi >= 0 && aqi <= 50) {
      return "ÓÅ";
    }
    if (aqi > 50 && aqi <= 100) {
      return "Á¼";
    }
    if (aqi > 100 && aqi <= 150) {
      return "Çá¶ÈÎÛÈ¾";
    }
    if (aqi > 150 && aqi <= 200) {
      return "ÖĞ¶ÈÎÛÈ¾";
    }
    if (aqi > 200 && aqi <= 300) {
      return "ÖØ¶ÈÎÛÈ¾";
    }
    if (aqi > 300) {
      return "ÑÏÖØÎÛÈ¾";
    }
    return "";
  }
}
