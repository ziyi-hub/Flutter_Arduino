import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'TaskDetail.dart';
import 'location_provider.dart';
import 'main.dart';

class LocationMap extends StatefulWidget {
  LocationMap(TaskDetail taskDetail) {
    taskDetails = taskDetail;
  }

  @override
  _LocationMapState createState() => _LocationMapState();
}

late TaskDetail taskDetails;
bool _showCardView = true; //this is to map destination Info

Color myHexColor = Color(0xff003499);
String _timeString = "";
Timer? timer;
int count = 0;
int timeBeforeTurn = 2;

String _formatDateTime(DateTime dateTime) {
  return DateFormat('E | MMMM d, yyyy | hh:mm a').format(dateTime);
}

class _LocationMapState extends State<LocationMap> {
  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 2), (Timer t) => _getTime());
    Provider.of<LocationProvider>(context, listen: false).initialization();
  }

  void trigger() {
    //count = 0;
    setState(
      () {
        timer = Timer.periodic(
          Duration(seconds: timeBeforeTurn),
          (timer) => {
            if (count <
                Provider.of<LocationProvider>(context, listen: false)
                    .info!
                    .totalSteps
                    .length)
              {
                count++,
                // timeBeforeTurn += int.parse(
                //     Provider.of<LocationProvider>(context).stepsInstructions[0]
                //         [count]['duration']["text"][0]),
              },
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  Widget _widgetbuilder() {
    Widget result = const RotatedBox(quarterTurns: 2, child: null);

    if (count <
        Provider.of<LocationProvider>(context, listen: false)
            .info!
            .totalSteps
            .length) {
      if (Provider.of<LocationProvider>(context).stepsInstructions[0][count]
              ["maneuver"] !=
          null) {
        if (Provider.of<LocationProvider>(context)
            .stepsInstructions[0][count]["maneuver"]
            .contains("right")) {
          result = const RotatedBox(
            quarterTurns: 2,
            child: IconButton(
              icon: Icon(
                Icons.subdirectory_arrow_left_sharp,
                color: Colors.red,
                size: 200.0,
              ),
              onPressed: null,
            ),
          );
        } else {
          result = const RotatedBox(
            quarterTurns: 2,
            child: IconButton(
              icon: Icon(
                Icons.subdirectory_arrow_left_sharp,
                color: Colors.red,
                size: 200.0,
              ),
              onPressed: null,
            ),
          );
          result = const RotatedBox(
            quarterTurns: 2,
            child: IconButton(
              icon: Icon(
                Icons.subdirectory_arrow_right_sharp,
                color: Colors.red,
                size: 200.0,
              ),
              onPressed: null,
            ),
          );
        }
      }

      //
    }
    return result;
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        resizeToAvoidBottomInset: false, // set it to false
        appBar: AppBar(
          toolbarHeight: 65,
          titleSpacing: 25,
          backgroundColor: myHexColor,
          leading: Transform.scale(
            scale: 1.5,
            child: Padding(
              padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
              child: Image.asset('assets/placeholder.png'),
            ),
          ),
          title: Text(
            _timeString.toUpperCase(),
            style: const TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              child: googleMapUI(),
            ),
            Container(
              margin: EdgeInsets.all(20.0),
              child: _showCardView
                  ? Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          ListTile(
                            leading: null,
                            title: Text("0" +
                                count.toString() +
                                " | " +
                                taskDetails.taskDetails +
                                '\n\n\n\n\n\n\n\n\n\n\n\n\n\n'),
                            subtitle:
                                (Provider.of<LocationProvider>(context).info) !=
                                        null
                                    ? _widgetbuilder()
                                    : Text(taskDetails.taskNote),
                          ),
                          ButtonBar(
                            children: <Widget>[],
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            Container(
              child: IconButton(
                color: _showCardView ? Colors.grey[400] : myHexColor,
                icon: _showCardView
                    ? Icon(Icons.cancel)
                    : Icon(
                        Icons.info,
                      ),
                onPressed: () {
                  setState(() {
                    // Here we changing the icon.
                    _showCardView = !_showCardView;
                  });
                },
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: trigger,
          tooltip: 'Démarrer',
          child: const Icon(Icons.garage_outlined),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      ),
      onWillPop: () {
        return Future.value(true); // if true allow back else block it
      },
    );
  }

  Widget googleMapUI() {
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      if (model.locationPosition != null) {
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: model.locationPosition!,
                  zoom: 20,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.of(model.markers.values),
                polylines: Set<Polyline>.of(model.polylines.values),
                onMapCreated: (GoogleMapController controller) async {
                  Provider.of<LocationProvider>(context, listen: false)
                      .setMapController(controller);
                },
              ),
            ),
          ],
        );
      }

      return Container(
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}
