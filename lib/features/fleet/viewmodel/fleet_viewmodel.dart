import 'package:flutter/foundation.dart';

import '../../../data/models/vehicle.dart';
import '../../../data/repositories/app_repository.dart';

class FleetViewModel extends ChangeNotifier {
  FleetViewModel(this._jobs);

  final JobRepository _jobs;

  String tab = 'dashboard';
  bool profileComplete = false;
  Vehicle? selectedVehicle;
  Vehicle? prefilledVehicle;
  bool showHelp = false;
  bool showPaymentMethods = false;
  bool showVehicles = false;
  bool showChat = false;
  bool showNotifications = false;

  List<Vehicle> get vehicles => _jobs.fleetVehicles();

  void setTab(String value) {
    tab = value;
    notifyListeners();
  }

  void markProfileComplete() {
    profileComplete = true;
    tab = 'profile';
    notifyListeners();
  }

  void selectVehicle(Vehicle v) {
    selectedVehicle = v;
    showVehicles = false;
    tab = 'vehicle-detail';
    notifyListeners();
  }

  void clearSelectedVehicle() {
    selectedVehicle = null;
    tab = 'profile';
    notifyListeners();
  }

  void requestServiceFromVehicle(Vehicle v) {
    prefilledVehicle = v;
    tab = 'post-job';
    notifyListeners();
  }

  void openVehicles() {
    showVehicles = true;
    notifyListeners();
  }

  void closeVehicles() {
    showVehicles = false;
    tab = 'profile';
    notifyListeners();
  }

  void openPayment() {
    showPaymentMethods = true;
    notifyListeners();
  }

  void closePayment() {
    showPaymentMethods = false;
    tab = 'profile';
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

  void openChat() {
    showChat = true;
    notifyListeners();
  }

  void closeChat() {
    showChat = false;
    notifyListeners();
  }

  void openNotifications() {
    showNotifications = true;
    notifyListeners();
  }

  void closeNotifications() {
    showNotifications = false;
    notifyListeners();
  }

  String get bottomNavActive {
    if (tab == 'tracking-detail' || tab == 'quote-received') return 'tracking';
    if (tab == 'edit-profile' || tab == 'payment-methods' || tab == 'vehicles' || tab == 'vehicle-detail') {
      return 'profile';
    }
    return tab;
  }
}
