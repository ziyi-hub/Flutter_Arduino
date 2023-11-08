import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'TaskDetail.dart';
import 'main.dart';

class MyMapPage extends StatefulWidget {
  MyMapPage(TaskDetail task) {
    taskDetails = task;
  }

  @override
  _MyMapPageState createState() => _MyMapPageState(taskDetails);
}

TaskDetail taskDetails = new TaskDetail(
    "03", "Test Task", "Sample data", 24.92882971812439, 67.0578712459639);

class _MyMapPageState extends State<MyMapPage> {
  late StreamSubscription _locationSubscription;
  final Location _locationTracker = Location();

  late GoogleMapController _controller;

  final Map<String, Marker> _markers = {};

  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = 'AIzaSyDNvoOjptBGs4dqxhAzC_EmdH0FiPS-KyM';
  Color myHexColor = Color(0xff003499);
  String _timeString = "";

  _MyMapPageState(TaskDetail taskDetail) {
    taskDetails = taskDetail;
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
  }

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    /*final destinationMarker = Marker(
      markerId: MarkerId(taskDetails.taskNumber),
      position: LatLng(taskDetails.lat, taskDetails.lon),
      infoWindow: InfoWindow(
        title: taskDetails.taskNumber,
        snippet: taskDetails.taskDetails,
      ),
    );


    _markers.clear();
    _markers["Destination"] = destinationMarker;*/
    LatLng currentlatlng =
        LatLng(newLocalData.latitude!, newLocalData.longitude!);
    _controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentlatlng,
      zoom: 14.4746,
    )));
    LatLng latlng = LatLng(newLocalData.latitude!, newLocalData.longitude!);

    this.setState(() {
      Marker marker = Marker(
          markerId: MarkerId("driver"),
          position: latlng,
          rotation: newLocalData.heading!,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      Circle circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy!,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));

      _markers["Driver"] = marker;

      _getPolyline();
    });
  }

  void getCurrentLocation() async {
    try {
      Uint8List imageData = await getMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target:
                      LatLng(newLocalData.latitude!, newLocalData.longitude!),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;

    setState(() {
      final destinationMarker = Marker(
        markerId: MarkerId(taskDetails.taskNumber),
        position: LatLng(taskDetails.lat, taskDetails.lon),
        infoWindow: InfoWindow(
          title: taskDetails.taskNumber,
          snippet: taskDetails.taskDetails,
        ),
      );

      _markers.clear();
      _markers["Destination"] = destinationMarker;
    });
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('E | MMMM d, yyyy | hh:mm a').format(dateTime);
  }

  _launchURL() async {
    const url = 'https://google.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.blue, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    //disableButton();
    polylineCoordinates.clear();
    Marker driver = _markers.entries.elementAt(1).value;
    Marker destination = _markers.entries.elementAt(0).value;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(driver.position.latitude, driver.position.longitude),
      PointLatLng(
          destination.position.latitude, destination.position.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  bool isEnabled = true;

  enableButton() {
    setState(() {
      isEnabled = true;
    });
  }

  disableButton() {
    setState(() {
      isEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false); // if true allow back else block it
      },
      child: Scaffold(
        appBar: AppBar(
            toolbarHeight: 65,
            titleSpacing: 25,
            backgroundColor: myHexColor,
            leading: Transform.scale(
                scale: 1.5,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(35, 0, 0, 0),
                  child: new Image.asset('assets/gkg_logo_symbol_rgb_app.png'),
                )),
            title: Text(
              _timeString.toUpperCase(),
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )),
        body: Stack(children: <Widget>[
          Container(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(taskDetails.lat, taskDetails.lon),
                zoom: 18,
              ),
              markers: _markers.values.toSet(),
              polylines: Set<Polyline>.of(polylines.values),
            ),
          ),
          Container(
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: null,
                    title: Text(taskDetails.taskNumber +
                        " | " +
                        taskDetails.taskDetails),
                    subtitle: Text(taskDetails.taskNote),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        onPressed:
                            isEnabled ? () => {getCurrentLocation()} : null,
                        color: myHexColor,
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text('Route'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
        bottomNavigationBar: BottomAppBar(
            color: myHexColor,
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                      padding: EdgeInsets.fromLTRB(40, 25, 10, 25),
                      disabledColor: Colors.grey,
                      icon: Transform.scale(
                        scale: 1,
                        child:
                            new Image.asset('assets/gkg_app_icon_search.png'),
                      ),
                      onPressed: () {
                        _launchURL();
                      }),
                  IconButton(
                      disabledColor: Colors.grey,
                      padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
                      icon: Transform.scale(
                        scale: 1,
                        child: new Image.asset('assets/gkg_app_icon_back.png'),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      }),
                  IconButton(
                      disabledColor: Colors.grey,
                      padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
                      icon: Transform.scale(
                        scale: 1,
                        child: new Image.asset('assets/gkg_app_icon_home.png'),
                      ),
                      onPressed: () async {
                        Navigator.pop(context, false);
                      }),
                  IconButton(
                      disabledColor: Colors.grey,
                      padding: EdgeInsets.fromLTRB(10, 15, 40, 15),
                      icon: Transform.scale(
                          scale: 1,
                          child:
                              new Image.asset('assets/gkg_app_icon_call.png')),
                      onPressed: () {
                        launch("tel://414-212-8844");
                      })
                ])),
      ),
    );
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }
}
