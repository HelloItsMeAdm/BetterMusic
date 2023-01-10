import 'package:bettermusic/pages/LoginPage.dart';
import 'package:bettermusic/pages/HomePage.dart';
import 'package:bettermusic/utils/InternetCheck.dart';
import 'package:bettermusic/utils/SharedPrefs.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefs().setDefaultData();

  // Request access to files permission
  await Permission.manageExternalStorage.request();

  if (await InternetCheck().canUseInternet()) {
    // If user is not signed in, redirect to login page, else redirect to home page
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
    if (googleUser == null) {
      runApp(const LoginPage());
    } else {
      runApp(const HomePage());
    }
  } else {
    runApp(const HomePage());
  }
}
