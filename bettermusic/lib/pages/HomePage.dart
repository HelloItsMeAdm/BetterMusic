import 'dart:core';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:bettermusic/widgets/Snacker.dart';
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
import 'LoadingScreen.dart';

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

class _MyHomePageState extends State<MyHomePage> with AutomaticKeepAliveClientMixin {
  bool canShow = false;
  Map videoData = <String, dynamic>{};
  double _opacity = 0.0;
  String basePath = '';
  Icon playPauseIcon = const Icon(Icons.play_arrow);
  Map<String, dynamic> navbar = <String, dynamic>{
    'title': 'Better Music',
    'subtitle': 'Loading...',
  };

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadImage();
    Player().getShuffle();
    checkForUpdates();
  }

  void _loadImage() async {
    setState(() {
      _opacity = 1.0;
    });
  }

  void checkForUpdates() async {
    if (!await InternetCheck().canUseInternet()) {
      return;
    }
    // Every 3 seconds, check for updates
    Future<void>.delayed(const Duration(seconds: 3), () async {
      if (await InternetCheck().canUseInternet()) {
        YoutubeData().getPlaylists().then((value) {
          if (value != null && value.length != videoData.length) {
            videoData = <String, dynamic>{};
            oneRun = false;
            canShow = false;
            getPlaylist();
          }
          checkForUpdates();
        });
      }
    });
  }

  Future getPlaylist() async {
    if (oneRun) {
      return;
    }
    oneRun = true;
    DownloadManager().getDownloadedFiles().then((files) {
      Constants().getAppSpecificFilesDir().then((path) async => {
            basePath = path,
            if (await InternetCheck().canUseInternet())
              {
                YoutubeData().getPlaylists().then((data) => {
                      if (videoData.isEmpty)
                        {
                          setState(() {
                            navbar = {
                              'title':
                                  widget.offlineMode ? 'Offline Mode' : 'Online Mode',
                              'subtitle': 'Found ${data?.length} songs',
                            };
                            videoData = data ?? {};
                            data?.forEach((key, value) async {
                              if (!files.containsKey("$key.mp3")) {
                                videoData[key]["downloadState"] = 1;
                                DownloadManager()
                                    .download(key, context, videoData[key]["title"])
                                    .then((_) => {
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
                            DownloadManager()
                                .removeOldFiles(videoData, basePath, context);
                            canShow = true;
                          })
                        }
                    }),
              }
            else
              {
                SharedPrefs().getMapData().then((data) => {
                      videoData = data,
                      setState(() {
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
                        canShow = true;
                      }),
                    }),
              },
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: getPlaylist(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && canShow) {
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
                    if (widget.offlineMode) {
                      setState(() {
                        videoData = <String, dynamic>{};
                        oneRun = false;
                        canShow = false;
                        getPlaylist();
                      });
                    } else {
                      Snacker().show(
                          context: context,
                          contentType: ContentType.failure,
                          title: 'No internet connection',
                          message:
                              'Please connect to the internet to refresh the playlist');
                    }
                  },
                ),
                IconButton(
                  icon: Image.asset(
                    'assets/images/youtubevanced.png',
                  ),
                  onPressed: () {
                    Uri uri = Uri.parse("https://www.youtube.com/playlist?list=${Constants.PLAYLIST_ID}");
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: uri.toString(),
                      package: 'com.google.android.apps.youtube.app'
                    );
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
                  child: ListView.builder(
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
                  ),
                ),
              ],
            ),
            bottomNavigationBar: PlayerBar(videoData: videoData, basePath: basePath),
          );
        }
        return const LoadingScreen();
      },
    );
  }
}
