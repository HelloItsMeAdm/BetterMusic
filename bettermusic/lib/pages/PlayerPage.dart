import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../player/Player.dart';

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
  };

  @override
  void initState() {
    super.initState();
    updateUI();
  }

  void updateUI() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.videoData.isNotEmpty) {
        setState(() {
          playerData = Player().getData(widget.videoData, widget.basePath);
        });
      }
      updateUI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          //generate music player view
          body: Container(
            child: Column(
              children: <Widget>[
                //generate music player view
                Container(
                  height: 300,
                  width: double.infinity,
                  child: Image.file(
                    File(playerData["thumbnail"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          )
        );
      },
    );
  }
}
