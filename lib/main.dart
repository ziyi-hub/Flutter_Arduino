import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_in_flutter/SelectorDispositivePage.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart';
import 'package:dio/dio.dart';

import 'MyMapScreen.dart';
import 'accueil.dart';
import 'TaskDetail.dart';
import 'layout_bluetooth/StatusConexaoProvider.dart';
import 'location_map.dart';
import 'location_provider.dart';

void main() async {
  runApp(
    MyMapScreen(
      TaskDetail("01", "Steps Instructions", "Google maps indisponible",
          45.1938021, 5.7688764),
    ),
  );
}

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
            ChangeNotifierProvider<StatusConexaoProvider>.value(
              value: StatusConexaoProvider(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Map',
            home: const Accueil(),
            initialRoute: '/',
            routes: {
              // When navigating to the "/ardiuno" route, build the Ardiuno widget.
              '/arduino': (context) => const SelecionarDispositivoPage(),
              // When navigating to the "/ajout" route, build the AddEven widget.
              '/map': (context) => LocationMap(_taskDetail),
            },
          ),
        ),
        onWillPop: () {
          return Future.value(true); // if true allow back else block it
        });
  }
}
