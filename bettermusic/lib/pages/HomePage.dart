import 'dart:core';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/DownloadManager.dart';
import '../utils/SharedPrefs.dart';
import '../utils/YoutubeData.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Welcome!'),
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
            SharedPrefs().getRootData('folderPath').then((folderPath) {
              videoData = data ?? {};
              basePath = folderPath;
              setState(() {
                data?.forEach((key, value) {
                  if (!files.containsKey("$key.mp3")) {
                    DownloadManager().download(key);
                  }
                });
              });
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
                        return ListTile(
                          title: Text(videoData.values.elementAt(index)['title']),
                          subtitle: Text(
                              "${videoData.values.elementAt(index)['author']} - ${videoData.values.elementAt(index)['id']}"),
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
                                          ? File(videoData.values
                                              .elementAt(index)['thumbnail'])
                                          : File(
                                              "$basePath/thumbnails/${videoData.values.elementAt(index)['id']}.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            final player = AudioPlayer();
                            String path = "$basePath/mp3/${videoData.values.elementAt(index)['id']}.mp3";
                            player.play(DeviceFileSource(path));
                          },
                        );
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
