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
      MyMapScreen(
          TaskDetail("01", "Destination Address", "ok", 45.1939059, 5.7657611)),
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

// class MapScreen extends StatefulWidget {
//   const MapScreen({Key? key}) : super(key: key);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   //late GoogleMapController mapController;
//   final Completer<GoogleMapController> _controller = Completer();

//   static const LatLng origin = LatLng(45.178920, 5.732690);
//   static const LatLng destination = LatLng(45.1939059, 5.7657611);
//   LocationData? currentLocation;
//   late bool _serviceEnabled;
//   late PermissionStatus _permissionGranted;

//   Map<MarkerId, Marker> markers = {};
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();
//   String googleAPiKey = "AIzaSyDNvoOjptBGs4dqxhAzC_EmdH0FiPS-KyM";

//   //BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
//   //BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;

//   void getCurrentLocation() async {
//     Location location = Location();

//     _serviceEnabled = await location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     location.getLocation().then(
//       (location) {
//         currentLocation = location;
//       },
//     );

//     GoogleMapController googleMapController = await _controller.future;

//     location.onLocationChanged.listen((LocationData newLoc) {
//       currentLocation = newLoc;
//       googleMapController.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             zoom: 13,
//             target: LatLng(newLoc.latitude!, newLoc.longitude!),
//           ),
//         ),
//       );
//       setState(() {});
//     });
//   }

//   void _onMapCreated(GoogleMapController controller) async {
//     //mapController = controller;
//     _controller.complete(controller);
//   }

//   _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
//     MarkerId markerId = MarkerId(id);
//     Marker marker =
//         Marker(markerId: markerId, icon: descriptor, position: position);
//     markers[markerId] = marker;
//   }

//   _addPolyLine() {
//     PolylineId id = const PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.red,
//       points: polylineCoordinates,
//     );
//     polylines[id] = polyline;
//     setState(() {});
//   }

//   void _getPolyline() async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleAPiKey,
//       PointLatLng(origin.latitude, origin.longitude),
//       PointLatLng(destination.latitude, destination.longitude),
//       //travelMode: TravelMode.driving,
//       //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
//     );
//     // Fix error
//     if (result.points.isNotEmpty) {
//       for (var point in result.points) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       }
//     } else {
//       print(result.errorMessage);
//     }
//     _addPolyLine();
//   }

//   // void setCustomMarkerIcon() {
//   //   BitmapDescriptor.fromAssetImage(
//   //           ImageConfiguration.empty, "assets/Badge.png")
//   //       .then(
//   //     (icon) {
//   //       currentLocationIcon = icon;
//   //     },
//   //   );
//   //   BitmapDescriptor.fromAssetImage(
//   //           ImageConfiguration.empty, "assets/Pin_destination.png")
//   //       .then(
//   //     (icon) {
//   //       destinationIcon = icon;
//   //     },
//   //   );
//   // }

//   @override
//   void initState() {
//     getCurrentLocation();
//     //setCustomMarkerIcon();

//     /// origin marker
//     _addMarker(
//       LatLng(origin.latitude, origin.longitude),
//       "origin",
//       BitmapDescriptor.defaultMarker,
//     );

//     /// destination marker
//     _addMarker(
//       LatLng(destination.latitude, destination.longitude),
//       "destination",
//       //destinationIcon,
//       BitmapDescriptor.defaultMarkerWithHue(90),
//     );

//     // current position
//     if (currentLocation?.latitude != null &&
//         currentLocation?.longitude != null) {
//       _addMarker(
//         LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
//         "currentLocationIcon",
//         BitmapDescriptor.defaultMarker,
//         //currentLocationIcon,
//       );
//     }

//     _getPolyline();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           appBar: AppBar(
//             title: const Text('Maps App'),
//             backgroundColor: Colors.green[700],
//           ),
//           body: currentLocation != null
//               ? GoogleMap(
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(currentLocation!.latitude!,
//                         currentLocation!.longitude!),
//                     zoom: 13,
//                   ),
//                   myLocationEnabled: true,
//                   tiltGesturesEnabled: true,
//                   compassEnabled: true,
//                   scrollGesturesEnabled: true,
//                   zoomGesturesEnabled: true,
//                   onMapCreated: _onMapCreated,
//                   markers: Set<Marker>.of(markers.values),
//                   // markers: {
//                   //   const Marker(
//                   //     markerId: MarkerId("source"),
//                   //     position: origin,
//                   //   ),
//                   //   const Marker(
//                   //     markerId: MarkerId("destination"),
//                   //     position: destination,
//                   //   ),
//                   // },
//                   polylines: Set<Polyline>.of(polylines.values),
//                   // polylines: {
//                   //   Polyline(
//                   //     polylineId: const PolylineId("route"),
//                   //     points: polylineCoordinates,
//                   //   )
//                   // },
//                 )
//               : const Center(
//                   child: Text("Loading"),
//                 )),
//     );
//   }
// }



