import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '.env.dart';

import 'directions_model.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng? origin,
    required LatLng? dest,
  }) async {
    final response = await _dio.get(
      _baseUrl,
      // queryParameters: {
      //   'origin': '${origin!.latitude},${origin.longitude}',
      //   'destination': '${dest!.latitude},${dest.longitude}',
      //   'key': googleAPiKey
      // },
      queryParameters: {
        'origin': "20 Rue Monge, 38100 Grenoble",
        'destination': "60 Rue de la Chimie, 38400 Saint-Martin-d'Hères",
        'key': googleAPiKey
      },
    );

    //Check if response is successfull
    if (response.statusCode == 200) {
      print(Directions.fromMap(response.data));
      return Directions.fromMap(response.data);
    } else {
      throw Exception('Failed to create event');
    }
  }
}
