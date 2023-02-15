import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  Future<Map> getMapData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('currentSongs');
    if (data == null) {
      return <String, dynamic>{};
    }
    return json.decode(data);
  }

  void updateDataMap(Map data, String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(data));
  }

  void updateData(String data, String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, data);
  }

  Future<void> setDefaultValues() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isShuffle") == null) {
      prefs.setBool("isShuffle", false);
    }
  }

  Future<bool> getBoolData(String key, bool defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  void setBoolData(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  Future<bool> isHidden(String videoId) async {
    final data = await getMapData();
    if (data[videoId] == null) {
      return false;
    }
    return data[videoId]['isHidden'];
  }
}
