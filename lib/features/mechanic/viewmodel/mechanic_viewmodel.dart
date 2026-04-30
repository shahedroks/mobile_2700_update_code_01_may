import 'package:flutter/foundation.dart';

import '../../../data/models/job_offer.dart';
import '../../../data/repositories/app_repository.dart';
class MechanicViewModel extends ChangeNotifier {
  MechanicViewModel(this._jobs);

  final JobRepository _jobs;

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

  void toggleOnline() {
    online = !online;
    notifyListeners();
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
