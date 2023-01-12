import 'dart:core';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../utils/Constants.dart';
import '../utils/DownloadManager.dart';
import '../utils/InternetCheck.dart';
import '../utils/Themes.dart';
import '../utils/YoutubeData.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(title: 'Welcome!'),
      theme: Themes.getDarkTheme(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
      YoutubeData().getPlaylists().then((data) => {
            Constants().getAppSpecificFilesDir().then((path) => {
                  videoData = data ?? {},
                  basePath = path,
                  setState(() {
                    data?.forEach((key, value) async {
                      if (!files.containsKey("$key.mp3")) {
                        videoData[key]["downloadState"] = 0;
                        if (await InternetCheck().canUseInternet()) {
                          DownloadManager().download(key).then((_) => {
                                setState(() {
                                  videoData[key]["downloadState"] = 2;
                                })
                              });
                          videoData[key]["downloadState"] = 1;
                        }
                      } else {
                        videoData[key]["downloadState"] = 2;
                      }
                    });
                  })
                })
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
                              final player = AudioPlayer();
                              String path = "$basePath/mp3/${value['id']}.mp3";
                              player.play(DeviceFileSource(path));
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
