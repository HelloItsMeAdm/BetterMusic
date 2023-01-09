import 'dart:core';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/Constants.dart';
import '../utils/YoutubeData.dart';

bool gotData = false;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(title: 'Test'),
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
  final videoTitle = <String>[];
  final videoAuthor = <String>[];
  final videoUrl = <String>[];
  final videoThubnail = <String>[];

  Future getPlaylist() async {
    if (gotData) {
      return;
    }
    YoutubeData().getPlaylists().then((value) => {
          setState(() {
            if (gotData) {
              return;
            }
            // Remove every item that has title "Deleted video"
            for (var i = 0; i < value['items'].length; i++) {
              if (value['items'][i]['snippet']['title'] != 'Deleted video') {
                videoTitle.add(value['items'][i]['snippet']['title']);
                videoAuthor.add(value['items'][i]['snippet']['channelTitle']);
                videoUrl.add(
                    "https://www.youtube.com/watch?v=${value['items'][i]['snippet']['resourceId']['videoId']}");
                videoThubnail.add(
                    value['items'][i]['snippet']['thumbnails']['high']['url']);
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
                      itemCount: videoTitle.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(videoTitle[index]),
                          subtitle: Text(videoAuthor[index]),
                          leading: Image.network(videoThubnail[index]),
                          onTap: () {
                            launchUrl(Uri.parse(videoUrl[index]));
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
