import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';

class PlaceAutocompleteResult {
  PlaceAutocompleteResult({required this.description, required this.placeId});

  final String description;
  final String placeId;
}

class PlaceDetailsResult {
  PlaceDetailsResult({required this.latLng, this.formattedAddress});

  final LatLng latLng;
  final String? formattedAddress;
}

/// Google Places (legacy REST) + Geocoding for fleet post-job location.
class GooglePlacesService {
  GooglePlacesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static Uri _autocompleteUri(String input) => Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': input,
          'key': ApiConstants.googleMapsApiKey,
          'types': 'geocode',
        },
      );

  static Uri _detailsUri(String placeId) => Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': placeId,
          'fields': 'geometry,formatted_address',
          'key': ApiConstants.googleMapsApiKey,
        },
      );

  static Uri _geocodeUri(LatLng latLng) => Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'latlng': '${latLng.latitude},${latLng.longitude}',
          'key': ApiConstants.googleMapsApiKey,
        },
      );

  Future<List<PlaceAutocompleteResult>> autocomplete({required String input}) async {
    final q = input.trim();
    if (q.length < 2) return const [];

    final res = await _client.get(_autocompleteUri(q));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Places autocomplete failed (HTTP ${res.statusCode}).');
    }

    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) return const [];

    final status = body['status'] as String?;
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw Exception(body['error_message'] as String? ?? 'Places error: $status');
    }

    final preds = body['predictions'];
    if (preds is! List) return const [];

    return preds
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .map((m) {
          final desc = m['description'] as String? ?? '';
          final pid = m['place_id'] as String? ?? '';
          if (desc.isEmpty || pid.isEmpty) return null;
          return PlaceAutocompleteResult(description: desc, placeId: pid);
        })
        .whereType<PlaceAutocompleteResult>()
        .toList(growable: false);
  }

  Future<PlaceDetailsResult?> placeDetails({required String placeId}) async {
    final res = await _client.get(_detailsUri(placeId));
    if (res.statusCode < 200 || res.statusCode >= 300) return null;

    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) return null;
    if (body['status'] != 'OK') return null;

    final result = body['result'];
    if (result is! Map<String, dynamic>) return null;
    final geom = result['geometry'];
    if (geom is! Map<String, dynamic>) return null;
    final loc = geom['location'];
    if (loc is! Map<String, dynamic>) return null;
    final lat = (loc['lat'] as num?)?.toDouble();
    final lng = (loc['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    return PlaceDetailsResult(
      latLng: LatLng(lat, lng),
      formattedAddress: result['formatted_address'] as String?,
    );
  }

  Future<String?> reverseGeocode(LatLng latLng) async {
    final res = await _client.get(_geocodeUri(latLng));
    if (res.statusCode < 200 || res.statusCode >= 300) return null;

    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) return null;
    if (body['status'] != 'OK') return null;

    final results = body['results'];
    if (results is! List || results.isEmpty) return null;
    final first = results.first;
    if (first is! Map<String, dynamic>) return null;
    return first['formatted_address'] as String?;
  }
}
