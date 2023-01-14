import 'package:bettermusic/pages/HomePage.dart';
import 'package:bettermusic/pages/LoginPage.dart';
import 'package:bettermusic/utils/InternetCheck.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init for just audio
  await JustAudioBackground.init(
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidNotificationChannelId: 'com.helloitsmeadm.bettermusic.audio',
    androidNotificationIcon: "mipmap/logo_rounded",
  );

  // Request access to files permission
  await Permission.manageExternalStorage.request();

  if (await InternetCheck().canUseInternet()) {
    // If user is not signed in, redirect to login page, else redirect to home page
    final GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount? googleUser = await googleSignIn.signInSilently();
    if (googleUser == null) {
      runApp(const LoginPage());
    } else {
      runApp(const HomePage(offlineMode: false));
    }
  } else {
    runApp(const HomePage(offlineMode: true));
  }
}
