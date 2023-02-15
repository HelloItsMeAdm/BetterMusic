import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';

import '../background/Player.dart';
import '../pages/PlayerPage.dart';
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
    "currentPosition": 0,
    "duration": 0,
    "index": 0,
  };
  late Future _playerPageFuture;

  @override
  void initState() {
    super.initState();
    _playerPageFuture = _loadPlayerPage();
    updateUI();
  }

  void updateUI() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.videoData.isNotEmpty && mounted) {
        setState(() {
          playerData = Player().getData(widget.videoData, widget.basePath);
        });
      }
      updateUI();
    });
  }

  Future _loadPlayerPage() async {
    if (Navigator.canPop(context)) {
      return Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PlayerPage(
            videoData: widget.videoData,
            basePath: widget.basePath,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                  Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.ease))),
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _playerPageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => PlayerPage(
                        videoData: widget.videoData,
                        basePath: widget.basePath,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                              Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                                  .chain(CurveTween(curve: Curves.ease))),
                          child: child,
                        );
                      },
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
                            playerData["thumbnail"] == ""
                                ? Lottie.asset('assets/lotties/not_found.json',
                                    width: 65, height: 65, fit: BoxFit.cover)
                                : Image.file(
                                    File(playerData["thumbnail"]),
                                    width: 65,
                                    height: 65,
                                  ),
                            playerData["thumbnail"] == ""
                                ? const SizedBox(width: 10)
                                : const SizedBox(
                                    width: 20,
                                  ),
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
                            : const Icon(Icons.play_arrow,
                                color: CustomColors.primaryColor),
                        onPressed: () {
                          Player()
                              .playPause(widget.videoData, widget.basePath)
                              .then((value) {
                            setState(() {
                              playerData = value;
                            });
                          });
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.skip_next, color: CustomColors.primaryColor),
                        onPressed: () => Player().next(),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
