import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../../../data/models/job_offer.dart';
import '../../../data/repositories/app_repository.dart';
import '../../../data/services/mechanic_api_service.dart';

typedef _Coord = ({double lat, double lng});

class MechanicViewModel extends ChangeNotifier {
  MechanicViewModel(this._jobs, this._auth, this._api);

  final JobRepository _jobs;
  final AuthRepository _auth;
  final MechanicApiService _api;

  String tab = 'feed';
  bool online = true;
  int radiusMi = 15;
  int? maxDistMi;
  String postcode = 'M1 1AE';
  String city = 'Manchester';
  bool showHelp = false;

  List<JobOffer> get rawJobs => _jobs.mechanicJobsNearby();

  List<JobOffer> filteredJobs() {
    var list = rawJobs.where((j) => j.distanceMi <= radiusMi);
    if (maxDistMi != null) {
      list = list.where((j) => j.distanceMi <= maxDistMi!);
    }
    return list.toList()..sort((a, b) => a.distanceMi.compareTo(b.distanceMi));
  }

  void setTab(String t) {
    tab = t;
    notifyListeners();
  }

  static const Map<String, _Coord> _cityCoords = {
    'Manchester': (lat: 53.4808, lng: -2.2426),
    'London': (lat: 51.5074, lng: -0.1278),
    'Birmingham': (lat: 52.4862, lng: -1.8904),
    'Leeds': (lat: 53.8008, lng: -1.5491),
    'Liverpool': (lat: 53.4084, lng: -2.9916),
    'Sheffield': (lat: 53.3811, lng: -1.4701),
    'Bristol': (lat: 51.4545, lng: -2.5879),
  };

  _Coord _resolvedCoords() {
    return _cityCoords[city] ?? (lat: 53.4808, lng: -2.2426);
  }

  Future<_Coord> _getRealCoordsOrFallback() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _resolvedCoords();

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _resolvedCoords();
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return _resolvedCoords();
    }
  }

  Future<void> toggleOnline() async {
    final next = !online;
    online = next;
    notifyListeners();

    try {
      final session = await _auth.getSession();
      final token = session?.accessToken;
      if (token == null || token.trim().isEmpty) {
        throw Exception('Missing access token. Please login again.');
      }
      final coords = await _getRealCoordsOrFallback();
      await _api.updateAvailability(
        accessToken: token,
        availability: next ? 'ONLINE' : 'OFFLINE',
        latitude: coords.lat,
        longitude: coords.lng,
      );
    } catch (_) {
      online = !next; // revert
      notifyListeners();
      rethrow;
    }
  }

  void setRadius(int v) {
    radiusMi = v;
    if (maxDistMi != null && maxDistMi! > radiusMi) maxDistMi = null;
    notifyListeners();
  }

  void applyLocation(String newPostcode) {
    final upper = newPostcode.trim().toUpperCase();
    postcode = upper;
    final alnum = upper.replaceAll(RegExp(r'[^A-Z]'), '');
    final prefix = alnum.length >= 2 ? alnum.substring(0, 2) : (alnum.isEmpty ? 'M1' : alnum);
    const cityMap = {
      'M': 'Manchester',
      'B': 'Birmingham',
      'E': 'London',
      'N': 'London',
      'W': 'London',
      'LS': 'Leeds',
      'S': 'Sheffield',
      'L': 'Liverpool',
      'BS': 'Bristol',
    };
    city = cityMap[prefix] ?? cityMap[prefix[0]] ?? upper.split(' ').first;
    notifyListeners();
  }

  void setMaxDist(int? d) {
    maxDistMi = d;
    notifyListeners();
  }

  void openHelp() {
    showHelp = true;
    notifyListeners();
  }

  void closeHelp() {
    showHelp = false;
    notifyListeners();
  }

  String get bottomNavResolved {
    if (tab == 'job-tracker' || tab == 'quote-detail') return 'my-jobs';
    if (tab == 'earnings' || tab == 'edit-profile' || tab == 'payment-methods') return 'profile';
    return tab;
  }
}
