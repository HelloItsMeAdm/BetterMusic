import 'dart:core';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bettermusic/widgets/Snacker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../background/Player.dart';
import '../utils/Constants.dart';
import '../utils/CustomColors.dart';
import '../utils/SharedPrefs.dart';
import '../utils/Themes.dart';

class HiddenSongs extends StatelessWidget {
  const HiddenSongs(
      {super.key,
      required this.videoData,
      required this.offlineMode,
      required this.basePath});

  final Map videoData;
  final bool offlineMode;
  final String basePath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHiddenSongs(
          videoData: videoData, offlineMode: offlineMode, basePath: basePath),
      theme: Themes.getDarkTheme(),
      title: Constants.APP_NAME,
    );
  }
}

class MyHiddenSongs extends StatefulWidget {
  final Map videoData;
  final bool offlineMode;
  final String basePath;

  const MyHiddenSongs(
      {super.key,
      required this.videoData,
      required this.offlineMode,
      required this.basePath});

  @override
  State<MyHiddenSongs> createState() => _MyHiddenSongsState();
}

class _MyHiddenSongsState extends State<MyHiddenSongs> {
  Map<String, dynamic> navbar = <String, dynamic>{
    'title': 'Better Music',
    'subtitle': 'Loading...',
  };

  @override
  void initState() {
    super.initState();

    navbar = {
      'title': 'Hidden Songs',
      'subtitle':
          'Hiding ${widget.videoData.values.where((element) => element['isHidden']).length} songs',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor:
              widget.offlineMode ? CustomColors.gray : CustomColors.primaryColor,
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/images/youtubevanced.png',
              ),
              onPressed: () {
                Uri uri = Uri.parse(
                    "https://www.youtube.com/playlist?list=${Constants.PLAYLIST_ID}");
                AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    data: uri.toString(),
                    package: 'com.google.android.apps.youtube.app');
                intent.launch();
              },
            ),
          ],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: widget.offlineMode
                    ? Container(
                        foregroundDecoration: const BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.saturation,
                        ),
                        child: Image.asset(
                          'assets/images/logo_round.png',
                          fit: BoxFit.contain,
                          height: 32,
                        ),
                      )
                    : Image.asset(
                        'assets/images/logo_round.png',
                        fit: BoxFit.contain,
                        height: 32,
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Better",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: widget.offlineMode
                              ? CustomColors.primaryColor
                              : Colors.black,
                          fontSize: 20,
                        ),
                      ),
                      TextSpan(
                        text: "Music",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: widget.offlineMode
                              ? CustomColors.primaryColor
                              : Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(children: [
          Column(
            children: [
              const SizedBox(height: 10),
              Text(
                navbar['title'],
                style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                navbar['subtitle'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.videoData.length,
                itemBuilder: (context, index) {
                  final String key = widget.videoData.keys.elementAt(index);
                  final Map value = widget.videoData[key];

                  if (!value["isHidden"]) {
                    return Container();
                  } else {
                    return Slidable(
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              icon: Icons.visibility,
                              backgroundColor: Colors.green,
                              onPressed: (BuildContext context) {
                                widget.videoData[key]["isHidden"] = false;
                                SharedPrefs()
                                    .updateDataMap(widget.videoData, "currentSongs");
                                Map tempData = Map.from(widget.videoData);
                                tempData.removeWhere((key, value) => value["isHidden"]);
                                Player()
                                    .updatePlaylist(tempData, widget.basePath);
                                setState(() {
                                  widget.videoData;
                                  navbar = {
                                    'title': 'Hidden Songs',
                                    'subtitle':
                                    'Hiding ${widget.videoData.values.where((element) => element['isHidden']).length} songs',
                                  };
                                });
                                Snacker().show(
                                  context: context,
                                  contentType: ContentType.success,
                                  title: 'Song unhidden',
                                  message: 'Song unhidden successfully',
                                );
                              },
                            )
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            value["title"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text("${value["author"]}"),
                          leading: SizedBox(
                            width: 90,
                            height: 90,
                            child: Image.file(
                              widget.basePath == ''
                                  ? File(value['thumbnail'])
                                  : File(
                                      "${widget.basePath}/thumbnails/${value['id']}.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ));
                  }
                }),
          ),
        ]));
  }
}
