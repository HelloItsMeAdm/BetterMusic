import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';

import '../player/Player.dart';
import '../utils/Constants.dart';
import '../utils/CustomColors.dart';
import '../utils/DownloadManager.dart';
import '../utils/InternetCheck.dart';
import '../utils/SharedPrefs.dart';
import '../utils/Themes.dart';
import '../utils/YoutubeData.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.offlineMode});

  final bool offlineMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(offlineMode: offlineMode),
      theme: Themes.getDarkTheme(offlineMode: offlineMode),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool offlineMode;

  const MyHomePage({super.key, required this.offlineMode});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map videoData = <String, dynamic>{};
  double _opacity = 0.0;
  String basePath = '';

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    setState(() {
      _opacity = 1.0;
    });
  }

  Future getPlaylist() async {
    if (videoData.isNotEmpty) {
      return;
    }
    DownloadManager().getDownloadedFiles().then((files) {
      Constants().getAppSpecificFilesDir().then((path) async => {
            basePath = path,
            if (await InternetCheck().canUseInternet())
              {
                YoutubeData().getPlaylists().then((data) => {
                      videoData = data ?? {},
                      setState(() {
                        data?.forEach((key, value) async {
                          if (!files.containsKey("$key.mp3")) {
                            videoData[key]["downloadState"] = 1;
                            if (await InternetCheck().canUseInternet()) {
                              DownloadManager().download(key).then((_) => {
                                    setState(() {
                                      videoData[key]["downloadState"] = 2;
                                    })
                                  });
                            }
                          } else {
                            videoData[key]["downloadState"] = 2;
                          }
                        });
                      }),
                    }),
              }
            else
              {
                SharedPrefs().getMapData().then((data) => {
                      videoData = data,
                      setState(() {
                        data.forEach((key, value) async {
                          if (!files.containsKey("$key.mp3")) {
                            videoData[key]["downloadState"] = 0;
                          } else {
                            videoData[key]["downloadState"] = 2;
                          }
                        });
                      }),
                    }),
              },
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor:
              widget.offlineMode ? CustomColors.gray : CustomColors.primaryColor,
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
                  child: Text(
                    widget.offlineMode
                        ? "BetterMusic - Offline mode"
                        : "BetterMusic - Online mode!",
                    style: TextStyle(
                      color:
                          widget.offlineMode ? CustomColors.primaryColor : Colors.black,
                      fontSize: 20,
                    ),
                  )),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FutureBuilder(
                future: getPlaylist(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: videoData.length,
                      itemBuilder: (context, index) {
                        final String key = videoData.keys.elementAt(index);
                        final Map value = videoData[key];

                        // 0 Not downloaded
                        // 1 Downloading
                        // 2 Downloaded

                        if (value["downloadState"] == 2) {
                          return ListTile(
                            title: Text(value["title"]),
                            subtitle: Text("${value["author"]}"),
                            leading: SizedBox(
                              width: 95,
                              height: 110,
                              child: Stack(
                                children: [
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  Center(
                                    child: Opacity(
                                      opacity: _opacity,
                                      child: Image.file(
                                        basePath == ''
                                            ? File(value['thumbnail'])
                                            : File(
                                                "$basePath/thumbnails/${value['id']}.jpg"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Player().play(
                                  "$basePath/mp3/${value['id']}.mp3",
                                  value["title"],
                                  value["author"],
                                  "$basePath/thumbnails/${value['id']}.jpg");
                            },
                          );
                        } else if (value["downloadState"] == 0) {
                          return ListTile(
                            title: Text(value["title"],
                                style: const TextStyle(color: Colors.grey)),
                            subtitle: Text("${value["author"]}",
                                style: const TextStyle(color: Colors.grey)),
                            leading: SizedBox(
                              width: 95,
                              height: 110,
                              child: Center(
                                  child: RichText(
                                text: const TextSpan(
                                  text: "Not downloaded",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                textAlign: TextAlign.center,
                              )),
                            ),
                          );
                        } else {
                          return ListTile(
                              title: Text(value["title"]),
                              subtitle: Text("${value["author"]}"),
                              leading: const SizedBox(
                                width: 95,
                                height: 110,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ));
                        }
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ));
  }
}
