import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../background/Player.dart';
import '../utils/CustomColors.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.videoData, required this.basePath});

  final Map videoData;
  final String basePath;

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  Map<String, dynamic> playerData = <String, dynamic>{
    "title": "",
    "author": "",
    "thumbnail": "",
    "playPause": false,
    "shuffle": false,
    "currentPosition": 0,
    "duration": 0,
    "index": 0,
  };
  bool stopUpdate = false;

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  void updateUI() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.videoData.isNotEmpty && !stopUpdate) {
        setState(() {
          playerData = Player().getData(widget.videoData, widget.basePath);
        });
      }
      updateUI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: playerData['thumbnail'] == ""
                  ? const AssetImage("assets/images/black.png") as ImageProvider
                  : FileImage(File(playerData['thumbnail'])),
              fit: BoxFit.cover),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.75),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Stack(children: <Widget>[
                  SizedBox(
                    height: 35,
                    width: 130,
                    child: GestureDetector(
                      onVerticalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  Container(
                    height: 5,
                    width: 100,
                    margin:
                        const EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ]),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                playerData["thumbnail"] == ""
                    ? Lottie.asset('assets/lotties/not_found.json',
                        width: 200, height: 200, fit: BoxFit.fill)
                    : Image.file(
                        File(playerData["thumbnail"]),
                        width: 300,
                        height: 300,
                      ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    playerData["title"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    playerData["author"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.stop),
                      color: Colors.white,
                      onPressed: () {
                        Player().stop();
                      },
                    ),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      color: Colors.white,
                      onPressed: () {
                        Player().previous();
                      },
                    ),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: Icon(
                        playerData["playPause"] ? Icons.pause : Icons.play_arrow,
                      ),
                      color: playerData["playPause"]
                          ? CustomColors.primaryColor
                          : Colors.white,
                      onPressed: () {
                        Player().playPause(widget.videoData, widget.basePath);
                      },
                    ),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      color: Colors.white,
                      onPressed: () {
                        Player().next();
                      },
                    ),
                    const SizedBox(width: 20.0),
                    IconButton(
                      icon: Icon(
                        playerData["shuffle"] ? Icons.shuffle_on_outlined : Icons.shuffle,
                      ),
                      color: playerData["shuffle"]
                          ? CustomColors.primaryColor
                          : Colors.white,
                      onPressed: () {
                        Player().toggleShuffle();
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      secondsFormat(playerData["currentPosition"]),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 125,
                      child: Slider(
                        value: playerData["currentPosition"].toDouble(),
                        onChangeEnd: (double value) {
                          Player().seekToSecond(value.toInt());
                          stopUpdate = false;
                        },
                        onChangeStart: (double value) {
                          stopUpdate = true;
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withOpacity(0.5),
                        thumbColor: CustomColors.primaryColor,
                        min: 0.0,
                        max: playerData["duration"].toDouble(),
                        onChanged: (double value) {
                          setState(() {
                            playerData["currentPosition"] = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text(
                      secondsFormat(playerData["duration"]),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String secondsFormat(playerData) {
    final int seconds = playerData.toInt();
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }
}
