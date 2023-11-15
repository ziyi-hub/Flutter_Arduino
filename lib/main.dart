import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';

import 'MyMapScreen.dart';
import 'TaskDetail.dart';
import 'location_map.dart';
import 'location_provider.dart';

void main() => runApp(
      MyMapScreen(TaskDetail("01", "Steps Instructions",
          "Google maps indisponible", 45.1939059, 5.7657611)),
    );

class MyMapScreen extends StatelessWidget {
  late TaskDetail _taskDetail;

  MyMapScreen(TaskDetail taskDetails) {
    _taskDetail = taskDetails;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) =>
                  LocationProvider(_taskDetail.lat, _taskDetail.lon),
              child: LocationMap(_taskDetail),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Map',
            home: LocationMap(_taskDetail),
          ),
        ),
        onWillPop: () {
          return Future.value(true); // if true allow back else block it
        });
  }
}
