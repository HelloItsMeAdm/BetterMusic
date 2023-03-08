import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bettermusic/utils/CustomColors.dart';
import 'package:bettermusic/widgets/Snacker.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../pages/HomePage.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _isSigningIn
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.primaryColor),
            )
          : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _isSigningIn = true;
                });

                // Sign in with Google
                final GoogleSignIn googleSignIn = GoogleSignIn(
                  scopes: [
                    'email',
                    'https://www.googleapis.com/auth/youtube.readonly',
                  ],
                );

                GoogleSignInAccount? googleUser = await googleSignIn.signIn();

                // Get the authorization code and print it
                await googleUser?.authentication.then((value) => {
                  Snacker().show(
                    context: context,
                    contentType: ContentType.success,
                    title: "Success",
                    message: "Signed in with Google",
                  ),
                  runApp(const HomePage(offlineMode: false)),
                });

                setState(() {
                  _isSigningIn = false;
                });
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Image(
                      image: AssetImage("assets/images/google_logo.png"),
                      height: 35.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
