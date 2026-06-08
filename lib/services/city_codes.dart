class CityCode {
  static final Map<String, String> _cityCodeMap = _initCityCodeMap();

  static Map<String, String> _initCityCodeMap() {
    final map = <String, String>{};
    map['beijing'] = '101010100';
    map['shanghai'] = '101020100';
    map['guangzhou'] = '101280101';
    map['shenzhen'] = '101280601';
    map['hangzhou'] = '101210101';
    map['chengdu'] = '101270101';
    map['wuhan'] = '101200101';
    map['xian'] = '101110101';
    map['nanjing'] = '101190101';
    map['chongqing'] = '101040100';
    map['北京'] = '101010100';
    map['上海'] = '101020100';
    map['广州'] = '101280101';
    map['深圳'] = '101280601';
    map['杭州'] = '101210101';
    map['成都'] = '101270101';
    map['武汉'] = '101200101';
    map['西安'] = '101110101';
    map['南京'] = '101190101';
    map['重庆'] = '101040100';
    return map;
  }

  static String getCityCode(String cityName) {
    final lowerName = cityName.toLowerCase();
    if (_cityCodeMap.containsKey(lowerName)) {
      return _cityCodeMap[lowerName]!;
    }
    if (_cityCodeMap.containsKey(cityName)) {
      return _cityCodeMap[cityName]!;
    }
    return '';
  }
}
