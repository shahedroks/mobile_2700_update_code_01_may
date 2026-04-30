import 'package:flutter/foundation.dart';

class CompanyViewModel extends ChangeNotifier {
  String screen = 'company-dashboard';

  void setScreen(String s) {
    screen = s;
    notifyListeners();
  }

  String get bottomResolved {
    if (screen == 'company-earnings' || screen == 'company-edit-profile') return 'company-profile';
    return screen;
  }
}
