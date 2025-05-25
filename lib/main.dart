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
    const apiKey = 'f4b4303bcf39eb4490701fa1d35886d3';
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
          'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=hourly,minutely&appid=$apiKey&units=metric&lang=kr';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception("API 오류: ${response.statusCode} - ${response.body}");
      }

      final data = json.decode(response.body);
      final today = data['daily'][0];

      setState(() {
        location = locality;
        maxTemp = today['temp']['max'];
        minTemp = today['temp']['min'];
        currentTemp = data['current']?['temp'] ?? today['temp']['day'];
        weatherDescription = today['weather'][0]['description'];
        iconUrl =
            'https://openweathermap.org/img/wn/${today['weather'][0]['icon']}@2x.png';
        weeklyWeather = data['daily'];
        isLoading = false;
      });
    } catch (e) {
      print("\u274c 에러 발생: $e");
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
        weeklyWeather = List.generate(7, (index) => {});
        isLoading = false;
      });
    }
  }

  String _getDayLabel(int offset) {
    DateTime date = DateTime.now().add(Duration(days: offset));
    return DateFormat('M월 d일 EEEE', 'ko_KR').format(date);
  }

  Widget buildWeeklyStyledTextList() {
    return Container(
      margin: EdgeInsets.only(top: 30),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 24.0),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.blue.shade100,
              ),
              tabs: [
                Tab(text: '기온'),
                Tab(text: '미세먼지'),
                Tab(text: '날씨'),
                Tab(icon: Icon(Icons.more_horiz)),
              ],
            ),
            Container(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: List.generate(4, (tabIndex) {
                  return ListView.builder(
                    itemCount: weeklyWeather.length,
                    itemBuilder: (context, index) {
                      final dayData = weeklyWeather[index];
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 16.0,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.blue.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getDayLabel(index),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              (dayData['temp'] != null &&
                                      dayData['feels_like'] != null)
                                  ? '최고 ${dayData['temp']['max'].toStringAsFixed(0)}° / '
                                        '최저 ${dayData['temp']['min'].toStringAsFixed(0)}° / '
                                        '체감 ${dayData['feels_like']['day'].toStringAsFixed(0)}°'
                                  : '데이터 없음',
                              style: TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
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
                      buildWeeklyStyledTextList(),
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
