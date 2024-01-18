import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _cityController = TextEditingController();
  List<dynamic> _suggestions = [];
  dynamic _weather;

  final String MAPBOX_API_KEY = 'pk.eyJ1IjoibmJha2x1YiIsImEiOiJjbHJjNGV5dG8wdjBnMmtydjQ0NnQwN3ljIn0.fTo-u0u4Y8mDm7x2ETDpfw';
  final String MAPBOX_GEOCODING_API_URL = 'https://api.mapbox.com/geocoding/v5/mapbox.places';

  final String OPENWEATHER_API_KEY = '6deaca16b5cc4a313dba32d30bc504e5';
  final String OPENWEATHER_API_URL = 'https://api.openweathermap.org/data/2.5/weather';

  Future<void> _fetchCitySuggestions(String input) async {
    try {
      final response = await http.get(
        Uri.parse('$MAPBOX_GEOCODING_API_URL/${Uri.encodeComponent(input)}.json?access_token=$MAPBOX_API_KEY&types=place'),
      );
      final data = json.decode(response.body);
      setState(() {
        _suggestions = data['features'];
      });
    } catch (error) {
      print('Error fetching city suggestions: $error');
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final response = await http.get(
        Uri.parse('$OPENWEATHER_API_URL?q=${Uri.encodeComponent(_cityController.text)}&appid=$OPENWEATHER_API_KEY&units=metric'),
      );
      final data = json.decode(response.body);
      setState(() {
        _weather = data;
      });
    } catch (error) {
      print('Error fetching weather data: $error');
    }
  }

  void _flatListHandle(dynamic suggestion) {
    _cityController.text = suggestion['place_name'];
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network('https://i.imgur.com/Z8eUMU7.png', width: 50, height: 50),
                Text(
                  'Weather App',
                  style: TextStyle(fontSize: 28),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      hintText: 'Enter city',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        _fetchCitySuggestions(text);
                      }
                    },
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_suggestions[index]['place_name']),
                        onTap: () => _flatListHandle(_suggestions[index]),
                      );
                    },
                  ),
                if (_weather != null)
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_fetchBGImage(_weather['weather'][0]['main'])),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_weather['name'], style: TextStyle(fontSize: 40, color: Colors.white)),
                        Text('${_weather['main']['temp']} °C', style: TextStyle(fontSize: 40, color: Colors.blue)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fetchBGImage(String main) {
    switch (main) {
      case 'Clear':
        return 'https://i.imgur.com/yZfdwKp.jpg';
      case 'Clouds':
        return 'https://i.imgur.com/botI5GA.jpg';
      case 'scattered clouds':
        return 'https://i.imgur.com/0Zj4V78.jpg';
      case 'broken clouds':
        return 'https://i.imgur.com/PQNlynX.jpg';
      case 'Rain':
        return 'https://i.imgur.com/cLkncqU.jpg';
      case 'Thunderstorm':
        return 'https://i.imgur.com/XUYqvzW.jpg';
      case 'Snow':
        return 'https://i.imgur.com/wbw5Dn6.jpg';
      default:
        return 'https://i.imgur.com/t4eq4Kf.jpg';
    }
  }
}
