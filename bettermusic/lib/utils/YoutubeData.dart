import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/Constants.dart';
import 'GoogleAuth.dart';
import 'InternetCheck.dart';
import 'SharedPrefs.dart';

class YoutubeData {
  Future<Map<String, dynamic>?> getPlaylists() async {
    Map<String, dynamic>? videoData = <String, dynamic>{};
    if (await InternetCheck().canUseInternet()) {
      Object accessToken = await GoogleAuth().getAccessToken();
      final reponse = await http.get(
        Uri.parse(
            'https://www.googleapis.com/youtube/v3/playlistItems?playlistId=${Constants.PLAYLIST_ID}&access_token=$accessToken&key=${Constants.API_KEY}&part=id%2Csnippet&maxResults=50'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // Convert response.body to a Map
      Map<String, dynamic> value = json.decode(reponse.body);
      for (var i = 0; i < value['items'].length; i++) {
        if (value['items'][i]['snippet']['title'] != 'Deleted video') {
          videoData[value['items'][i]['snippet']['resourceId']['videoId']] = {
            'id': value['items'][i]['snippet']['resourceId']['videoId'],
            'position': value['items'][i]['snippet']['position'],
            'isHidden': await SharedPrefs()
                .isHidden(value['items'][i]['snippet']['resourceId']['videoId']),
            'title': value['items'][i]['snippet']['title'],
            'author': value['items'][i]['snippet']['videoOwnerChannelTitle'],
            'url':
                "https://www.youtube.com/watch?v=${value['items'][i]['snippet']['resourceId']['videoId']}",
            'thumbnail': value['items'][i]['snippet']['thumbnails']['high']['url']
          };
        }
      }
      SharedPrefs().updateDataMap(videoData, 'currentSongs');
    } else {
      videoData = (await SharedPrefs().getMapData()).cast<String, dynamic>();
    }
    return videoData;
  }
}
