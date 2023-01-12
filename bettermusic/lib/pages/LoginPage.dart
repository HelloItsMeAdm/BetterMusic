import 'package:flutter/material.dart';

import '../utils/CustomColors.dart';
import '../utils/Themes.dart';
import '../widgets/GoogleSignInButton.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyLoginPage(),
      theme: Themes.getDarkTheme(),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<MyLoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.darkGray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Image.asset(
                        'assets/images/logo_round.png',
                        height: 160,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'BetterMusic',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                    const Text(
                      'Listen to music like never before',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: GoogleSignInButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
