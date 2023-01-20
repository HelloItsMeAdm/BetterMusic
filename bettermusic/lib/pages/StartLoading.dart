import 'package:flutter/material.dart';

import '../utils/Constants.dart';
import '../utils/CustomColors.dart';
import '../utils/Themes.dart';

class StartLoading extends StatelessWidget {
  const StartLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const StartLoadingPage(),
      theme: Themes.getDarkTheme(),
      title: Constants.APP_NAME,
    );
  }
}

class StartLoadingPage extends StatefulWidget {
  const StartLoadingPage({super.key});

  @override
  _StartLoadingState createState() => _StartLoadingState();
}

class _StartLoadingState extends State<StartLoadingPage> {
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Loading...',
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
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
