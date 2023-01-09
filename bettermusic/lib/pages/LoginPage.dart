import 'package:bettermusic/pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyLoginPage(title: 'Ojoj Google spadl'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<MyLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Login with Google'),
          onPressed: () async {
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
                  runApp(const HomePage()),
                });
          },
        ),
      ),
    );
  }
}
