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
import '../widgets/PlayerBar.dart';

bool oneRun = false;

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.offlineMode});

  final bool offlineMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(offlineMode: offlineMode),
      theme: Themes.getDarkTheme(),
      title: Constants.APP_NAME,
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
  Icon playPauseIcon = const Icon(Icons.play_arrow);
  String loadingStatus = 'Searching for files...';
  Map<String, dynamic> navbar = <String, dynamic>{
    'title': 'Better Music',
    'subtitle': 'Loading...',
  };

  @override
  void initState() {
    super.initState();
    _loadImage();
    Player().getShuffle();
  }

  void _loadImage() async {
    setState(() {
      _opacity = 1.0;
    });
  }

  Future getPlaylist() async {
    if (oneRun) {
      return;
    }
    oneRun = true;
    DownloadManager().getDownloadedFiles().then((files) {
      setState(() {
        loadingStatus = 'Found ${files.length} files';
      });
      Constants().getAppSpecificFilesDir().then((path) async => {
            basePath = path,
            if (await InternetCheck().canUseInternet())
              {
                setState(() {
                  loadingStatus = 'Downloading online playlist...';
                }),
                YoutubeData().getPlaylists().then((data) => {
                      if (videoData.isEmpty)
                        {
                          setState(() {
                            loadingStatus = 'Finishing...';
                            navbar = {
                              'title':
                                  widget.offlineMode ? 'Offline Mode' : 'Online Mode',
                              'subtitle': 'Found ${data?.length} songs',
                            };
                            videoData = data ?? {};
                            data?.forEach((key, value) async {
                              if (!files.containsKey("$key.mp3")) {
                                videoData[key]["downloadState"] = 1;
                                DownloadManager().download(key).then((_) => {
                                      setState(() {
                                        videoData[key]["downloadState"] = 2;
                                        navbar = {
                                          'title': widget.offlineMode
                                              ? 'Offline Mode'
                                              : 'Online Mode',
                                          'subtitle': 'Found ${data.length} songs',
                                        };
                                      })
                                    });
                              } else {
                                videoData[key]["downloadState"] = 2;
                              }
                            });
                            DownloadManager().removeOldFiles(videoData, basePath);
                          })
                        }
                    }),
              }
            else
              {
                setState(() {
                  loadingStatus = 'Loading offline playlist...';
                }),
                SharedPrefs().getMapData().then((data) => {
                      videoData = data,
                      setState(() {
                        loadingStatus = 'Finishing...';
                        data.forEach(
                          (key, value) async {
                            if (!files.containsKey("$key.mp3")) {
                              videoData[key]["downloadState"] = 0;
                            } else {
                              videoData[key]["downloadState"] = 2;
                            }
                          },
                        );
                        navbar = {
                          'title': widget.offlineMode ? 'Offline Mode' : 'Online Mode',
                          'subtitle': 'Found ${data.length} songs',
                        };
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: widget.offlineMode ? CustomColors.primaryColor : Colors.black,
            onPressed: () {
              setState(() {
                videoData = <String, dynamic>{};
                oneRun = false;
                getPlaylist();
              });
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
                        color:
                            widget.offlineMode ? CustomColors.primaryColor : Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: "Music",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color:
                            widget.offlineMode ? CustomColors.primaryColor : Colors.black,
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
      body: Column(
        children: [
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
            child: FutureBuilder(
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
                          title: Text(
                            value["title"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text("${value["author"]}"),
                          leading: SizedBox(
                            width: 90,
                            height: 90,
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
                            Player().play(videoData, basePath, index, context);
                          },
                        );
                      } else if (value["downloadState"] == 0) {
                        return ListTile(
                          title: Text(value["title"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.grey)),
                          subtitle: Text("${value["author"]}",
                              style: const TextStyle(color: Colors.grey)),
                          leading: SizedBox(
                            width: 90,
                            height: 90,
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
                            title: Text(
                              value["title"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text("${value["author"]}"),
                            leading: const SizedBox(
                              width: 90,
                              height: 90,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ));
                      }
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const CircularProgressIndicator(),
                        const Text(
                          "Welcome!",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        Text(loadingStatus,
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w300)),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: PlayerBar(videoData: videoData, basePath: basePath),
    );
  }
}
