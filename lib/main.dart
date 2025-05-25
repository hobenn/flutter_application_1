import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '날씨 앱',
      theme: ThemeData(fontFamily: 'Arial', primarySwatch: Colors.blue),
      themeMode: ThemeMode.light,
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String location = "현위치";
  String date = "";
  String weatherDescription = "";
  String iconUrl = "";
  double? maxTemp;
  double? minTemp;
  double? currentTemp;
  List<dynamic> weeklyWeather = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    date = DateFormat('M월 d일', 'ko_KR').format(DateTime.now());
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = 'YOUR_API_KEY_HERE'; // <-- 여기에 OpenWeatherMap API 키 입력
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("위치 서비스 꺼짐");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("위치 권한 거부됨");
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double lat = position.latitude;
      double lon = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      String? locality = placemarks.isNotEmpty
          ? placemarks.first.locality ?? placemarks.first.name ?? '현위치'
          : '현위치';

      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception("API 오류: ${response.statusCode} - ${response.body}");
      }

      final data = json.decode(response.body);

      setState(() {
        location = locality;
        currentTemp = data['main']['temp'];
        maxTemp = data['main']['temp_max'];
        minTemp = data['main']['temp_min'];
        weatherDescription = data['weather'][0]['description'];
        iconUrl =
            'https://openweathermap.org/img/wn/${data['weather'][0]['icon']}@2x.png';
        weeklyWeather = []; // 주간 날씨는 빈 리스트로 유지
        isLoading = false;
      });
    } catch (e) {
      print("❌ 에러 발생: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('날씨 데이터를 불러오지 못했습니다: $e')));
      setState(() {
        location = "현위치";
        maxTemp = null;
        minTemp = null;
        currentTemp = null;
        weatherDescription = "데이터 없음";
        iconUrl = "";
        weeklyWeather = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD2DCFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentTemp != null
                                ? '${currentTemp!.toStringAsFixed(0)}°'
                                : '',
                            style: TextStyle(fontSize: 80, color: Colors.black),
                          ),
                        ],
                      ),
                      Text(
                        '현위치 온도',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          if (iconUrl.isNotEmpty)
                            Image.network(iconUrl, width: 40, height: 40),
                          SizedBox(width: 10),
                          Text(
                            weatherDescription,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        maxTemp != null && minTemp != null
                            ? '최고 ${maxTemp!.toStringAsFixed(0)}° / 최저 ${minTemp!.toStringAsFixed(0)}°'
                            : '최고 / 최저 기온 정보 없음',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.shade400,
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
        ],
      ),
    );
  }
}
