// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';

// void main() {
//   runApp(WeatherApp());
// }

// class WeatherApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '날씨 앱',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: WeatherHomePage(),
//     );
//   }
// }

// class WeatherHomePage extends StatefulWidget {
//   @override
//   _WeatherHomePageState createState() => _WeatherHomePageState();
// }

// class _WeatherHomePageState extends State<WeatherHomePage> {
//   String _temperature = '';
//   String _description = '';
//   String _city = '';
//   String _iconCode = '';
//   double _pm10 = 0.0;
//   double _pm25 = 0.0;
//   bool _isLoadingDust = false;
//   int selectedTab = 0;

//   final String apiKey = 'f4b4303bcf39eb4490701fa1d35886d3';

//   final List<String> tabs = ['기온', '미세먼지', '날씨'];
//   final List<Map<String, String>> tempData = [
//     {'date': '5월 12일 월요일', 'temp': '22°/16°'},
//     {'date': '5월 13일 화요일', 'temp': '24°/13°'},
//     {'date': '5월 14일 수요일', 'temp': '20°/10°'},
//     {'date': '5월 15일 목요일', 'temp': '21°/12°'},
//     {'date': '5월 16일 금요일', 'temp': '23°/16°'},
//     {'date': '5월 17일 토요일', 'temp': '27°/18°'},
//     {'date': '5월 18일 일요일', 'temp': '24°/11°'},
//   ];

//   final List<Map<String, dynamic>> dustData = [
//     {
//       'date': '5월 12일 월요일',
//       'value': 30,
//       'grade': '좋음',
//       'icon': Icons.check_circle,
//       'color': Colors.green,
//     },
//     {
//       'date': '5월 13일 화요일',
//       'value': 45,
//       'grade': '보통',
//       'icon': Icons.check_circle,
//       'color': Colors.amber,
//     },
//     {
//       'date': '5월 14일 수요일',
//       'value': 60,
//       'grade': '보통',
//       'icon': Icons.check_circle,
//       'color': Colors.amber,
//     },
//     {
//       'date': '5월 15일 목요일',
//       'value': 90,
//       'grade': '나쁨',
//       'icon': Icons.cancel,
//       'color': Colors.red,
//     },
//     {
//       'date': '5월 16일 금요일',
//       'value': 130,
//       'grade': '매우나쁨',
//       'icon': Icons.block,
//       'color': Colors.black,
//     },
//     {
//       'date': '5월 17일 토요일',
//       'value': 70,
//       'grade': '보통',
//       'icon': Icons.check_circle,
//       'color': Colors.amber,
//     },
//     {
//       'date': '5월 18일 일요일',
//       'value': 20,
//       'grade': '좋음',
//       'icon': Icons.check_circle,
//       'color': Colors.green,
//     },
//   ];

//   final List<Map<String, dynamic>> weatherData = [
//     {'date': '5월 12일 월요일', 'desc': '맑음', 'icon': Icons.wb_sunny},
//     {'date': '5월 13일 화요일', 'desc': '흐림', 'icon': Icons.cloud},
//     {'date': '5월 14일 수요일', 'desc': '흐림', 'icon': Icons.cloud},
//     {'date': '5월 15일 목요일', 'desc': '비', 'icon': Icons.umbrella},
//     {'date': '5월 16일 금요일', 'desc': '안개,흐림', 'icon': Icons.blur_on},
//     {'date': '5월 17일 토요일', 'desc': '맑음,구름', 'icon': Icons.wb_cloudy},
//     {'date': '5월 18일 일요일', 'desc': '맑음', 'icon': Icons.wb_sunny},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchWeather();
//     _fetchAirPollution();
//   }

//   Future<void> _fetchWeather() async {
//     try {
//       Position position = await _getLocation();
//       final url = Uri.parse(
//         'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric&lang=kr',
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _temperature = "${data['main']['temp'].round()}°C";
//           _description = data['weather'][0]['description'];
//           _city = data['name'];
//           _iconCode = data['weather'][0]['icon'];
//         });
//       }
//     } catch (e) {
//       print('에러 발생: $e');
//     }
//   }

//   Future<void> _fetchAirPollution() async {
//     try {
//       setState(() => _isLoadingDust = true);
//       Position position = await _getLocation();
//       final url = Uri.parse(
//         'https://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey',
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _pm10 = data['list'][0]['components']['pm10'];
//           _pm25 = data['list'][0]['components']['pm2_5'];
//         });
//       }
//     } catch (e) {
//       print('에러 발생: $e');
//     } finally {
//       setState(() => _isLoadingDust = false);
//     }
//   }

//   Future<Position> _getLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       return Future.error('위치 서비스 비활성화됨');
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return Future.error('위치 권한 거부됨');
//       }
//     }

//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFBFD5F5),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: _temperature == ''
//                 ? CircularProgressIndicator()
//                 : Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Image.network(
//                         'http://openweathermap.org/img/wn/${_iconCode}@2x.png',
//                         width: 80,
//                         height: 80,
//                       ),
//                       SizedBox(width: 16),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _city,
//                             style: TextStyle(
//                               fontSize: 35,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             _temperature,
//                             style: TextStyle(
//                               fontSize: 100,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           Text(
//                             _description,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: List.generate(tabs.length, (index) {
//                 final isSelected = selectedTab == index;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => setState(() => selectedTab = index),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       margin: EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         color: isSelected ? Colors.blue.shade100 : Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.blue),
//                       ),
//                       child: Center(
//                         child: Text(
//                           tabs[index],
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//           Expanded(
//             child: Builder(
//               builder: (_) {
//                 if (selectedTab == 0) {
//                   return ListView.builder(
//                     itemCount: tempData.length,
//                     itemBuilder: (context, index) {
//                       final item = tempData[index];
//                       return Container(
//                         margin: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         padding: EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(color: Colors.grey.shade300),
//                         ),
//                         child: Text(
//                           '${item['date']}: ${item['temp']} 최고기온/최저기온',
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       );
//                     },
//                   );
//                 } else if (selectedTab == 1) {
//                   return ListView.builder(
//                     itemCount: dustData.length,
//                     itemBuilder: (context, index) {
//                       final item = dustData[index];
//                       return ListTile(
//                         title: Text('${item['date']}: ${item['value']}㎍/㎥'),
//                         subtitle: Text(item['grade']),
//                         trailing: Icon(item['icon'], color: item['color']),
//                       );
//                     },
//                   );
//                 } else {
//                   return ListView.builder(
//                     itemCount: weatherData.length,
//                     itemBuilder: (context, index) {
//                       final item = weatherData[index];
//                       return ListTile(
//                         title: Text('${item['date']}: ${item['desc']}'),
//                         trailing: Icon(item['icon']),
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.backpack), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
//         ],
//         currentIndex: 1,
//         onTap: (index) {},
//         selectedItemColor: Colors.black,
//         unselectedItemColor: Colors.grey,
//         showSelectedLabels: false,
//         showUnselectedLabels: false,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// void main() {
//   runApp(WeatherApp());
// }

// class WeatherApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: WeatherForecastPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class WeatherForecastPage extends StatefulWidget {
//   @override
//   _WeatherForecastPageState createState() => _WeatherForecastPageState();
// }

// class _WeatherForecastPageState extends State<WeatherForecastPage> {
//   List<String> forecasts = [];

//   @override
//   void initState() {
//     super.initState();
//     fetch5DayForecast();
//   }

//   Future<void> fetch5DayForecast() async {
//     final apiKey =
//         'f4b4303bcf39eb4490701fa1d35886d3'; // 👉 여기에 본인의 OpenWeatherMap API 키 입력
//     final city = 'Seoul';
//     final url =
//         'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric&lang=kr';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final jsonData = json.decode(response.body);
//         final List<dynamic> forecastList = jsonData['list'];

//         final now = DateTime.now();
//         Map<String, List<double>> tempPerDay = {};
//         Map<String, String> descriptionPerDay = {};
//         Map<String, String> datePerDay = {};

//         // forecastList는 3시간 간격, 5일간 예보가 담겨 있음
//         for (var item in forecastList) {
//           final dt = DateTime.parse(item['dt_txt']);
//           final dayKey = "${dt.year}-${dt.month}-${dt.day}";

//           if (dt.isAfter(now)) {
//             final temp = item['main']['temp'].toDouble();
//             tempPerDay.putIfAbsent(dayKey, () => []).add(temp);

//             if (dt.hour == 12) {
//               descriptionPerDay[dayKey] = item['weather'][0]['description'];
//               datePerDay[dayKey] = item['dt_txt'];
//             }
//           }
//         }

//         List<String> dailyForecasts = [];

//         final sortedDays = tempPerDay.keys.toList()
//           ..sort((a, b) => a.compareTo(b));

//         for (int i = 0; i < 5 && i < sortedDays.length; i++) {
//           final day = sortedDays[i];
//           final temps = tempPerDay[day]!;
//           final maxTemp = temps.reduce((a, b) => a > b ? a : b);
//           final minTemp = temps.reduce((a, b) => a < b ? a : b);
//           final desc = descriptionPerDay[day] ?? '정보 없음';
//           final date = datePerDay[day] ?? day;

//           dailyForecasts.add(
//             '📅 날짜: $date\n🌡 최고: ${maxTemp.toStringAsFixed(1)}°C\n🌡 최저: ${minTemp.toStringAsFixed(1)}°C\n☀️ 날씨: $desc',
//           );
//         }

//         setState(() {
//           forecasts = dailyForecasts;
//         });
//       } else {
//         setState(() {
//           forecasts = ['❌ 날씨 정보를 불러오지 못했습니다 (code: ${response.statusCode})'];
//         });
//       }
//     } catch (e) {
//       setState(() {
//         forecasts = ['🚫 오류 발생: $e'];
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('5일간 날씨 예보')),
//       body: ListView.builder(
//         itemCount: forecasts.length,
//         itemBuilder: (context, index) {
//           return Card(
//             margin: EdgeInsets.all(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(forecasts[index], style: TextStyle(fontSize: 18)),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';

// void main() {
//   runApp(MaterialApp(home: AirPollutionForecast()));
// }

// class AirPollutionForecast extends StatefulWidget {
//   @override
//   _AirPollutionForecastState createState() => _AirPollutionForecastState();
// }

// class _AirPollutionForecastState extends State<AirPollutionForecast> {
//   final String apiKey =
//       'f4b4303bcf39eb4490701fa1d35886d3'; // OpenWeather API Key
//   List<Map<String, dynamic>> forecastList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchForecast();
//   }

//   Future<void> fetchForecast() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       double lat = position.latitude;
//       double lon = position.longitude;

//       final url = Uri.parse(
//         'https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=$lat&lon=$lon&appid=$apiKey',
//       );

//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         final List list = data['list'];

//         // 하루에 1개씩만 보여주도록 (매일 12:00 시점 기준으로 필터링)
//         final dailyData = list
//             .where((item) {
//               final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
//               return dt.hour == 12;
//             })
//             .take(5)
//             .toList();

//         setState(() {
//           forecastList = dailyData.map((item) {
//             final date = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
//             final pm10 = item['components']['pm10'];
//             final pm25 = item['components']['pm2_5'];
//             final aqi = item['main']['aqi'];
//             return {
//               'date': date.toLocal().toString().split(' ')[0],
//               'pm10': pm10,
//               'pm25': pm25,
//               'aqi': aqi,
//             };
//           }).toList();
//         });
//       } else {
//         print('API 실패: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('오류 발생: $e');
//     }
//   }

//   String interpretAqi(int aqi) {
//     switch (aqi) {
//       case 1:
//         return '좋음';
//       case 2:
//         return '보통';
//       case 3:
//         return '나쁨';
//       case 4:
//         return '매우 나쁨';
//       case 5:
//         return '위험';
//       default:
//         return '정보 없음';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('미세먼지 5일 예보 (OpenWeather)')),
//       body: forecastList.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: forecastList.length,
//               itemBuilder: (context, index) {
//                 final item = forecastList[index];
//                 return ListTile(
//                   title: Text('${item['date']}'),
//                   subtitle: Text(
//                     'PM10: ${item['pm10']}㎍/㎥, PM2.5: ${item['pm25']}㎍/㎥, AQI: ${interpretAqi(item['aqi'])}',
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';

// void main() {
//   runApp(WeatherApp());
// }

// class WeatherApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '5일간 날씨 상태',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: WeatherPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class WeatherPage extends StatefulWidget {
//   @override
//   _WeatherPageState createState() => _WeatherPageState();
// }

// class _WeatherPageState extends State<WeatherPage> {
//   final String apiKey =
//       'f4b4303bcf39eb4490701fa1d35886d3'; // 🔑 너의 OpenWeatherMap API 키
//   List<Map<String, dynamic>> forecast = [];
//   String locationInfo = "위치를 불러오는 중...";

//   @override
//   void initState() {
//     super.initState();
//     getLocationAndFetchWeather();
//   }

//   Future<void> getLocationAndFetchWeather() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       setState(() => locationInfo = "위치 서비스 꺼짐");
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         setState(() => locationInfo = "위치 권한 필요");
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       setState(() => locationInfo = "위치 권한 영구 거부됨");
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       locationInfo =
//           "현재 위치: (${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})";
//     });

//     await fetchWeather(position.latitude, position.longitude);
//   }

//   Future<void> fetchWeather(double lat, double lon) async {
//     final url =
//         'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey&lang=kr';

//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List<Map<String, dynamic>> dailyWeather = [];

//       for (var item in data['list']) {
//         final dtTxt = item['dt_txt'];
//         if (dtTxt.contains('12:00:00')) {
//           dailyWeather.add({
//             'date': dtTxt.split(' ')[0],
//             'weather': item['weather'][0]['description'],
//           });
//         }
//       }

//       setState(() {
//         forecast = dailyWeather.take(5).toList();
//       });
//     } else {
//       print("날씨 가져오기 실패: ${response.statusCode}");
//     }
//   }

//   /// 날씨 설명에 따라 아이콘 선택
//   IconData getWeatherIcon(String description) {
//     if (description.contains("맑음")) return Icons.wb_sunny;
//     if (description.contains("비")) return Icons.beach_access;
//     if (description.contains("눈")) return Icons.ac_unit;
//     if (description.contains("흐림") || description.contains("구름"))
//       return Icons.cloud;
//     return Icons.wb_cloudy; // 기본값
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('5일간 날씨 상태')),
//       body: Column(
//         children: [
//           SizedBox(height: 10),
//           Text(locationInfo, style: TextStyle(fontSize: 16)),
//           SizedBox(height: 10),
//           Expanded(
//             child: forecast.isEmpty
//                 ? Center(child: CircularProgressIndicator())
//                 : ListView.builder(
//                     itemCount: forecast.length,
//                     itemBuilder: (context, index) {
//                       final item = forecast[index];
//                       final dateStr = DateFormat(
//                         'MM월 dd일',
//                       ).format(DateTime.parse(item['date']));
//                       final weather = item['weather'];
//                       return ListTile(
//                         leading: Icon(getWeatherIcon(weather), size: 30),
//                         title: Text('$dateStr: $weather'),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';

// void main() => runApp(
//   const MaterialApp(
//     home: WeatherTabbedApp(),
//     debugShowCheckedModeBanner: false,
//   ),
// );

// class WeatherTabbedApp extends StatefulWidget {
//   const WeatherTabbedApp({super.key});

//   @override
//   State<WeatherTabbedApp> createState() => _WeatherTabbedAppState();
// }

// class _WeatherTabbedAppState extends State<WeatherTabbedApp> {
//   final String apiKey = 'f4b4303bcf39eb4490701fa1d35886d3';
//   String city = '';
//   String today = '';
//   String temperature = '';
//   String description = '';
//   String iconCode = '';

//   int selectedTab = 0;
//   late PageController _pageController;

//   List<Map<String, dynamic>> dustForecast = [];
//   List<Map<String, dynamic>> weatherForecast = [];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: selectedTab);
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     Position pos = await _getLocation();
//     await _fetchTodayWeather(pos);
//     await _fetchDustForecast(pos);
//     await _fetchWeatherForecast(pos);
//   }

//   Future<Position> _getLocation() async {
//     bool enabled = await Geolocator.isLocationServiceEnabled();
//     if (!enabled) await Geolocator.openLocationSettings();
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied)
//       permission = await Geolocator.requestPermission();
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//   }

//   Future<void> _fetchTodayWeather(Position pos) async {
//     final url =
//         'https://api.openweathermap.org/data/2.5/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey&units=metric&lang=kr';
//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = json.decode(res.body);
//       setState(() {
//         city = data['name'];
//         temperature = '${data['main']['temp'].round()}°';
//         description = data['weather'][0]['description'];
//         iconCode = data['weather'][0]['icon'];
//         today = DateFormat('M월 d일').format(DateTime.now());
//       });
//     }
//   }

//   Future<void> _fetchDustForecast(Position pos) async {
//     final url =
//         'https://api.openweathermap.org/data/2.5/air_pollution/forecast?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey';
//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = json.decode(res.body);
//       final List list = data['list'];
//       final daily = list
//           .where(
//             (e) =>
//                 DateTime.fromMillisecondsSinceEpoch(e['dt'] * 1000).hour == 12,
//           )
//           .take(5)
//           .map((e) {
//             final dt = DateTime.fromMillisecondsSinceEpoch(e['dt'] * 1000);
//             return {
//               'date': DateFormat('MM월 dd일').format(dt),
//               'pm10': e['components']['pm10'],
//               'pm25': e['components']['pm2_5'],
//               'aqi': e['main']['aqi'],
//             };
//           })
//           .toList();
//       setState(() => dustForecast = daily);
//     }
//   }

//   Future<void> _fetchWeatherForecast(Position pos) async {
//     final url =
//         'https://api.openweathermap.org/data/2.5/forecast?lat=${pos.latitude}&lon=${pos.longitude}&appid=$apiKey&units=metric&lang=kr';
//     final res = await http.get(Uri.parse(url));
//     if (res.statusCode == 200) {
//       final data = json.decode(res.body);
//       final List list = data['list'];
//       final Map<String, List<double>> tempMap = {};
//       final Map<String, String> descMap = {};

//       for (var item in list) {
//         final dt = DateTime.parse(item['dt_txt']);
//         final dateKey = DateFormat('yyyy-MM-dd').format(dt);
//         final temp = item['main']['temp']?.toDouble();
//         if (temp != null) {
//           tempMap.putIfAbsent(dateKey, () => []).add(temp);
//         }
//         if (dt.hour >= 12 && dt.hour <= 15 && !descMap.containsKey(dateKey)) {
//           descMap[dateKey] = item['weather'][0]['description'];
//         }
//       }

//       final List<Map<String, dynamic>> daily = [];
//       final sortedKeys = tempMap.keys.toList()..sort();
//       for (var dateKey in sortedKeys.take(5)) {
//         final temps = tempMap[dateKey]!;
//         final maxTemp = temps.reduce((a, b) => a > b ? a : b);
//         final minTemp = temps.reduce((a, b) => a < b ? a : b);
//         final desc = descMap[dateKey] ?? '정보 없음';

//         daily.add({
//           'date': DateFormat('MM월 dd일').format(DateTime.parse(dateKey)),
//           'desc': desc,
//           'maxTemp': maxTemp.toStringAsFixed(1),
//           'minTemp': minTemp.toStringAsFixed(1),
//         });
//       }

//       setState(() => weatherForecast = daily);
//     }
//   }

//   IconData getIcon(String desc) {
//     if (desc.contains("맑음")) return Icons.wb_sunny;
//     if (desc.contains("비")) return Icons.beach_access;
//     if (desc.contains("눈")) return Icons.ac_unit;
//     if (desc.contains("흐림") || desc.contains("구름")) return Icons.cloud;
//     return Icons.wb_cloudy;
//   }

//   String interpretAQI(int aqi) {
//     switch (aqi) {
//       case 1:
//         return '좋음';
//       case 2:
//         return '보통';
//       case 3:
//         return '나쁨';
//       case 4:
//         return '매우 나쁨';
//       case 5:
//         return '위험';
//       default:
//         return '정보 없음';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFBFD5F5),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             Text(
//               '$city 📍',
//               style: const TextStyle(fontSize: 20, color: Colors.white),
//             ),
//             Text(
//               today,
//               style: const TextStyle(fontSize: 20, color: Colors.white),
//             ),
//             Text(
//               temperature,
//               style: const TextStyle(fontSize: 60, color: Colors.white),
//             ),
//             const Text('최고기온/최저기온', style: TextStyle(color: Colors.white70)),
//             Text(
//               description,
//               style: const TextStyle(fontSize: 18, color: Colors.white),
//             ),
//             const SizedBox(height: 10),
//             ToggleButtons(
//               isSelected: [
//                 selectedTab == 0,
//                 selectedTab == 1,
//                 selectedTab == 2,
//               ],
//               onPressed: (index) {
//                 setState(() => selectedTab = index);
//                 _pageController.animateToPage(
//                   index,
//                   duration: Duration(milliseconds: 300),
//                   curve: Curves.easeInOut,
//                 );
//               },
//               borderRadius: BorderRadius.circular(20),
//               selectedColor: Colors.black,
//               fillColor: Colors.white,
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('기온'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('미세먼지'),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   child: Text('날씨'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   setState(() {
//                     selectedTab = index;
//                   });
//                 },
//                 children: [
//                   // 기온 탭
//                   ListView.builder(
//                     itemCount: weatherForecast.length,
//                     itemBuilder: (context, i) => ListTile(
//                       title: Text('${weatherForecast[i]['date']}'),
//                       subtitle: Text(
//                         '최고: ${weatherForecast[i]['maxTemp']}°C / 최저: ${weatherForecast[i]['minTemp']}°C',
//                       ),
//                     ),
//                   ),
//                   // 미세먼지 탭
//                   ListView.builder(
//                     itemCount: dustForecast.length,
//                     itemBuilder: (context, i) => ListTile(
//                       title: Text('${dustForecast[i]['date']}'),
//                       subtitle: Text(
//                         'PM10: ${dustForecast[i]['pm10']}㎍/㎥, PM2.5: ${dustForecast[i]['pm25']}㎍/㎥',
//                       ),
//                       trailing: Text(interpretAQI(dustForecast[i]['aqi'])),
//                     ),
//                   ),
//                   // 날씨 탭
//                   ListView.builder(
//                     itemCount: weatherForecast.length,
//                     itemBuilder: (context, i) => ListTile(
//                       title: Text(
//                         '${weatherForecast[i]['date']}: ${weatherForecast[i]['desc']}',
//                       ),
//                       trailing: Icon(getIcon(weatherForecast[i]['desc'])),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase 로그인 앱',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
