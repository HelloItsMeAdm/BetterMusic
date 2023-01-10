import 'package:connectivity_plus/connectivity_plus.dart';

class InternetCheck {
  Future<bool> canUseInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.none) {
      return false;
    }
    return true;
  }
}
