import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheck {
  Future<bool> canUseInternet() async {
    return await Connectivity().checkConnectivity() == ConnectivityResult.wifi;
  }
}
