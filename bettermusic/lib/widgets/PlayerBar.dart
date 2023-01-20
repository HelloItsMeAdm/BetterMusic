import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../pages/PlayerPage.dart';
import '../player/Player.dart';
import '../utils/CustomColors.dart';

class PlayerBar extends StatefulWidget {
  const PlayerBar({super.key, required this.videoData, required this.basePath});

  final Map videoData;
  final String basePath;

  @override
  _PlayerBarState createState() => _PlayerBarState();
}

class _PlayerBarState extends State<PlayerBar> {
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
        return GestureDetector(
          onTap: () {
            // Open PlayerPage.dart
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerPage(
                  videoData: widget.videoData,
                  basePath: widget.basePath,
                ),
              ),
            );
          },
          child: ColoredBox(
            color: CustomColors.lightGray,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      playerData['title'] != ""
                          ? Image.file(
                              File(playerData['thumbnail']),
                              width: 65,
                              height: 65,
                            )
                          : const Icon(
                              Icons.music_note,
                              size: 65,
                              color: CustomColors.darkGray,
                            ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 65,
                          width: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                                child: Marquee(
                                  text: playerData['title'] != ""
                                      ? playerData['title']
                                      : "Playlist has not been loaded yet",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  blankSpace: 40.0,
                                  velocity: 50.0,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                playerData['author'] != ""
                                    ? playerData['author']
                                    : "No author",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: playerData["playPause"]
                      ? const Icon(Icons.pause, color: CustomColors.primaryColor)
                      : const Icon(Icons.play_arrow, color: CustomColors.primaryColor),
                  onPressed: () {
                    Player()
                        .playPause(widget.videoData, widget.basePath, context)
                        .then((value) {
                      setState(() {
                        playerData = value;
                      });
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: CustomColors.primaryColor),
                  onPressed: () => Player().next(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
