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

  Future<String> getRootData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<void> setDefaultData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currentSongs', json.encode(<String, dynamic>{}));
    prefs.setString('folderPath', '/storage/emulated/0/BetterMusic');
  }
}