import 'dart:core';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/YoutubeData.dart';

bool gotData = false;

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
  final Map videoData = <String, dynamic>{};
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    // Load image from network
    setState(() {
      _opacity = 1.0;
    });
  }

  Future getPlaylist() async {
    if (gotData) {
      return;
    }
    YoutubeData().getPlaylists().then((value) => {
          setState(() {
            if (gotData) {
              return;
            }
            for (var i = 0; i < value['items'].length; i++) {
              if (value['items'][i]['snippet']['title'] != 'Deleted video') {
                videoData[value['items'][i]['snippet']['resourceId']['videoId']] = {
                  'id': value['items'][i]['snippet']['resourceId']['videoId'],
                  'position': value['items'][i]['snippet']['position'],
                  'title': value['items'][i]['snippet']['title'],
                  'author': value['items'][i]['snippet']['videoOwnerChannelTitle'],
                  'url':
                      "https://www.youtube.com/watch?v=${value['items'][i]['snippet']['resourceId']['videoId']}",
                  'thumbnail': value['items'][i]['snippet']['thumbnails']['high']['url']
                };
              }
            }
            gotData = true;
          })
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
                          subtitle: Text(videoData.values.elementAt(index)['author']),
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
                                    child: Image.network(
                                      videoData.values.elementAt(index)['thumbnail'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            launchUrl(Uri.parse(videoData.values.elementAt(index)['url']));
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
