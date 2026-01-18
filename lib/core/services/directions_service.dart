import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DirectionsService {
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    if (_apiKey.isEmpty) {
      debugPrint('❌ Google Maps API key not found');
      return [origin, destination]; // Fallback to straight line
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=walking&' // Use walking mode for campus navigation
        'key=$_apiKey';

    debugPrint('🔍 Fetching directions from API...');
    debugPrint('📍 Origin: ${origin.latitude}, ${origin.longitude}');
    debugPrint(
      '📍 Destination: ${destination.latitude}, ${destination.longitude}',
    );

    try {
      final response = await http.get(Uri.parse(url));

      debugPrint('📡 API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        debugPrint('📊 API Status: ${data['status']}');

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'];

          debugPrint('✅ Route found! Decoding polyline...');

          // Decode the polyline
          final decodedPoints = _decodePolyline(polylinePoints);
          debugPrint('✅ Decoded ${decodedPoints.length} route points');

          return decodedPoints;
        } else {
          debugPrint('❌ Directions API error: ${data['status']}');
          if (data['error_message'] != null) {
            debugPrint('❌ Error message: ${data['error_message']}');
          }
          debugPrint('⚠️ Full response: ${response.body}');
        }
      } else {
        debugPrint('❌ HTTP error: ${response.statusCode}');
        debugPrint('❌ Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Exception fetching directions: $e');
    }

    debugPrint('⚠️ Falling back to straight line');
    // Fallback to straight line if API fails
    return [origin, destination];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<Map<String, dynamic>> getDirectionsDetails(
    LatLng origin,
    LatLng destination,
  ) async {
    if (_apiKey.isEmpty) {
      return {'distance': 0, 'duration': 0, 'steps': <String>[]};
    }

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}&'
        'destination=${destination.latitude},${destination.longitude}&'
        'mode=walking&'
        'key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          return {
            'distance': leg['distance']['value'], // in meters
            'duration': leg['duration']['value'], // in seconds
            'distanceText': leg['distance']['text'],
            'durationText': leg['duration']['text'],
            'steps': (leg['steps'] as List)
                .map((step) => step['html_instructions'].toString())
                .toList(),
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching direction details: $e');
    }

    return {'distance': 0, 'duration': 0, 'steps': <String>[]};
  }
}
