import 'dart:convert';

import 'package:http/http.dart' as http;
import '../utils/Constants.dart';
import 'GoogleAuth.dart';

class YoutubeData {
  Future<Map> getPlaylists() async {
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
    Map<String, dynamic> map = json.decode(reponse.body);
    //map['items'].removeWhere((item) => item['snippet']['title'] == 'Deleted video');
    return map;
  }
}
