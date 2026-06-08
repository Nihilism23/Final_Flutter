import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_weather_bg/flutter_weather_bg.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather.dart';
import '../services/weather_service_manager.dart';
import '../services/city_manager.dart';
import '../services/city_coordinates.dart';
import '../utils/weather_utils.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String currentCity = "Beijing";
  List<String> userCities = [];
  WeatherData? weatherData;
  List<DailyForecast> forecastData = [];
  bool isLoading = false;
  bool isLocating = false;
  Timer? autoUpdateTimer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    autoUpdateTimer?.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    autoUpdateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _fetchWeather();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 清理旧的缓存数据，防止乱码问题
    await prefs.clear();
    
    // 设置默认天气源为彩云
    WeatherServiceManager.setWeatherSource(WeatherSource.caiyun);

    // 使用默认的英文城市列表
    final cities = ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Chengdu'];
    final city = 'Beijing';

    // 保存默认设置
    await CityManager.saveCities(cities);
    await CityManager.setCurrentCity(city);

    setState(() {
      userCities = cities;
      currentCity = city;
    });

    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });

    try {
      final weather = await WeatherServiceManager.getCurrentWeather(currentCity);
      final forecast = await WeatherServiceManager.getDailyForecast(currentCity);

      setState(() {
        weatherData = weather;
        forecastData = forecast;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLocating = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLocating = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location service is disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            isLocating = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          isLocating = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        isLocating = false;
      });

      String nearestCity = _getNearestCity(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          currentCity = nearestCity;
        });
        await CityManager.setCurrentCity(nearestCity);
        _fetchWeather();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Using weather for $nearestCity')),
        );
      }
    } catch (e) {
      setState(() {
        isLocating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  String _getNearestCity(double lat, double lon) {
    final allCities = CityCoordinates.getAllCities();
    double minDistance = double.infinity;
    String nearestCity = allCities.isNotEmpty ? allCities.first : "Beijing";

    for (String city in allCities) {
      final coords = CityCoordinates.getCoordinates(city);
      if (coords != null) {
        double distance = _calculateDistance(lat, lon, coords['lat']!, coords['lon']!);
        if (distance < minDistance) {
          minDistance = distance;
          nearestCity = city;
        }
      }
    }

    return nearestCity;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return (lat1 - lat2).abs() + (lon1 - lon2).abs();
  }

  void _showCityManager() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCityManagerSheet(),
    );
  }

  Widget _buildCityManagerSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Manage Cities",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: userCities.length,
                itemBuilder: (context, index) {
                  final city = userCities[index];
                  final isSelected = currentCity == city;

                  return ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(city),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) const Icon(Icons.check, color: Colors.blue),
                        if (userCities.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              await CityManager.removeCity(city);
                              final updatedCities = await CityManager.getCities();
                              final updatedCurrent = await CityManager.getCurrentCity();
                              setState(() {
                                userCities = updatedCities;
                                currentCity = updatedCurrent;
                              });
                              _fetchWeather();
                            },
                          ),
                      ],
                    ),
                    onTap: () async {
                      await CityManager.setCurrentCity(city);
                      setState(() {
                        currentCity = city;
                      });
                      if (mounted) Navigator.pop(context);
                      _fetchWeather();
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ElevatedButton.icon(
                onPressed: _showAddCityDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add City"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCityDialog() {
    final allCities = CityCoordinates.getAllCities();
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredCities = searchQuery.isEmpty
                ? allCities
                : CityCoordinates.searchCities(searchQuery);

            final availableCities = filteredCities.where((city) => !userCities.contains(city)).toList();

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add City"),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search city...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: availableCities.isEmpty
                    ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? "All cities are already added"
                              : "City \"$searchQuery\" not found",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableCities.length,
                        itemBuilder: (context, index) {
                          final city = availableCities[index];
                          return ListTile(
                            title: Text(city),
                            trailing: const Icon(Icons.add),
                            onTap: () async {
                              await CityManager.addCity(city);
                              final updatedCities = await CityManager.getCities();
                              setState(() {
                                userCities = updatedCities;
                              });
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildRealTimeWeather() {
    final temp = weatherData?.tempNow ?? 0;
    String weatherText = weatherData?.weatherText ?? "Clear";

    return Column(
      children: [
        Text(
          currentCity,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          weatherText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "$temp",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 96,
            fontWeight: FontWeight.bold,
            height: 0.9,
          ),
        ),
        Text(
          "C",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildWeatherDetails() {
    final humidity = weatherData?.humidity ?? 0;
    final windDir = weatherData?.windDir ?? "";
    final windScale = weatherData?.windScale ?? "";
    final pressure = weatherData?.pressure ?? 0;
    final visibility = weatherData?.visibility ?? "0";

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: buildDetailItem(
                  Icons.water_drop,
                  "Humidity",
                  "${(humidity * 1).toInt()}%",
                ),
              ),
              Expanded(
                child: buildDetailItem(
                  Icons.air,
                  "Wind",
                  "$windDir $windScale",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: buildDetailItem(
                  Icons.compress,
                  "Pressure",
                  "$pressure hPa",
                ),
              ),
              Expanded(
                child: buildDetailItem(
                  Icons.visibility,
                  "Visibility",
                  "$visibility km",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHourlyForecast() {
    final hourly = weatherData?.hourly;
    if (hourly == null || hourly.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "24 Hour Forecast",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final item = hourly[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(
                        Icons.wb_sunny,
                        color: Colors.white,
                        size: 28,
                      ),
                      Text(
                        "${item.temperature}C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForecast() {
    if (forecastData.isEmpty) {
      return const SizedBox.shrink();
    }

    final weekDays = ["Today", "Tomorrow", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "7 Day Forecast",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...forecastData.asMap().entries.map((entry) {
            final index = entry.key;
            final forecast = entry.value;
            final weatherText = forecast.dayText ?? "Clear";

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      index < weekDays.length ? weekDays[index] : "Day ${index + 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.wb_sunny,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      weatherText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    "${forecast.tempMax}C/${forecast.tempMin}C",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WeatherType weatherType;
    if (weatherData != null) {
      weatherType = WeatherUtils.getWeatherType(weatherData!.weatherCode);
    } else {
      weatherType = WeatherType.sunny;
    }

    return Scaffold(
      body: Stack(
        children: [
          WeatherBg(
            weatherType: weatherType,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: isLocating
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.my_location, color: Colors.white),
                              onPressed: _getCurrentLocation,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.location_city, color: Colors.white),
                              onPressed: _showCityManager,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _fetchWeather,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLoading && weatherData == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Loading weather...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          children: [
                            const SizedBox(height: 40),
                            buildRealTimeWeather(),
                            const SizedBox(height: 20),
                            buildWeatherDetails(),
                            const SizedBox(height: 20),
                            buildHourlyForecast(),
                            const SizedBox(height: 20),
                            buildForecast(),
                            const SizedBox(height: 40),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
