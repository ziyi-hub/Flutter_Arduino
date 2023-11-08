import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'TaskDetail.dart';
import 'location_provider.dart';
import 'location_map.dart';

class MyMapScreen extends StatelessWidget {
  MyMapScreen(TaskDetail taskDetails) {
    _taskDetail = taskDetails;
  }

  TaskDetail _taskDetail = new TaskDetail("", "", "", 0, 0);

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
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
          return Future.value(false); // if true allow back else block it
        });
  }
}
