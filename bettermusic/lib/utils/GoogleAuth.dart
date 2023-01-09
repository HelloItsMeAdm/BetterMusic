import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  static final GoogleAuth _instance = GoogleAuth._internal();

  factory GoogleAuth() {
    return _instance;
  }

  GoogleAuth._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<Object> getAccessToken() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      return account?.authentication.then((value) => value.accessToken.toString()) ?? "";
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      return "";
    }
  }
}


