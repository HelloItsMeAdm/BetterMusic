import 'package:bettermusic/pages/LoginPage.dart';
import 'package:bettermusic/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // If user is not signed in, redirect to login page, else redirect to home page
  final GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
  if (googleUser == null) {
    runApp(const LoginPage());
  } else {
    runApp(const HomePage());
  }
}
