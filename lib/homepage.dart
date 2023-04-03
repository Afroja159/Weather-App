import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition();
    getWeatherData();
  }

  Position? position;
  Map<String, dynamic>? weathermap;
  Map<String, dynamic>? forecastmap;

  getWeatherData() async {
    var weather = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position!.latitude}&lon=${position!.longitude}&appid=26eea1527d23bc6106b0fd0a92120193&units=metric"));

    var forecast = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?lat=${position!.latitude}&lon=${position!.longitude}&appid=26eea1527d23bc6106b0fd0a92120193&units=metric"));

    setState(() {
      weathermap = Map<String, dynamic>.from(jsonDecode(weather.body));
      forecastmap = Map<String, dynamic>.from(jsonDecode(forecast.body));
    });
  }

  @override
  void initState() {
    determinePosition();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: weathermap != null
            ? Scaffold(
                body: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("images/bg.jpg"),
                          fit: BoxFit.cover)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.place,
                                size: 22,
                                color: Colors.white,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "${weathermap!["name"]}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ),
                              Icon(
                                Icons.arrow_downward,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          Icon(
                            Icons.calendar_month,
                            size: 24,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Image.network(
                        "https://openweathermap.org/img/wn/${weathermap!["weather"][0]["icon"]}@2x.png",
                        scale: 0.4,
                      ),
                      Text(
                        "${weathermap!["weather"][0]["description"]}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "${weathermap!["main"]["temp"]} °C",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wind_power,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              "${weathermap!["wind"]["speed"]} km/h",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Icon(
                              Icons.water_drop_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              "${weathermap!["main"]["humidity"]} %",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: forecastmap!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 450,
                              padding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 12),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color(0x57000000)),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${Jiffy.parse("${forecastmap!["list"][index]["dt_txt"]}").jm}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Image.network(
                                      "https://openweathermap.org/img/wn/${forecastmap!["list"][index]["weather"][0]["icon"]}@2x.png",
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${forecastmap!["list"][index]["main"]["temp"]} °C",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
