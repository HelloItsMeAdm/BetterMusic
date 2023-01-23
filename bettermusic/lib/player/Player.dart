import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../utils/SharedPrefs.dart';

AudioPlayer audioPlayer = AudioPlayer();
bool _isPlaylistSet = audioPlayer.audioSource != null;

class Player {
  Future<void> play(Map videoData, String path, int index, BuildContext context) async {
    String message = "";
    if (_isPlaylistSet) {
      if (index == audioPlayer.currentIndex) {
        if (audioPlayer.playing) {
          audioPlayer.pause();
          message = "Paused";
        } else {
          audioPlayer.play();
          message = "Resumed";
        }
      } else {
        audioPlayer.seek(Duration.zero, index: index);
        audioPlayer.play();
        message = "Seeked to $index";
      }
    } else {
      audioPlayer.setAudioSource(
        ConcatenatingAudioSource(
          children: videoData.entries.map((entry) {
            return AudioSource.uri(
              Uri.parse("file://$path/mp3/${entry.key}.mp3"),
              tag: MediaItem(
                id: entry.key,
                title: entry.value['title'],
                album: entry.value['author'],
                artUri: Uri.parse("file://$path/thumbnails/${entry.key}.jpg"),
              ),
            );
          }).toList(),
        ),
      );

      audioPlayer.setLoopMode(LoopMode.all);
      audioPlayer.setShuffleModeEnabled(await SharedPrefs().getBoolData("isShuffle", false));
      audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();

      _isPlaylistSet = true;
      message = "Set playlist and played $index";
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  void previous() async {
    await audioPlayer.seekToPrevious();
  }

  void next() async {
    await audioPlayer.seekToNext();
  }

  Future<Map<String, dynamic>> playPause(
      Map videoData, String basePath, BuildContext context) async {
    play(videoData, basePath, audioPlayer.currentIndex ?? 0, context);

    return getData(videoData, basePath);
  }

  void toggleShuffle() {
    SharedPrefs().getBoolData("isShuffle", false).then((value) {
      audioPlayer.setShuffleModeEnabled(!value);
      SharedPrefs().setBoolData("isShuffle", !value);
    });
  }

  void getShuffle() {
    SharedPrefs().getBoolData("isShuffle", false).then((value) {
      audioPlayer.setShuffleModeEnabled(value);
    });
  }

  Map<String, dynamic> getData(Map videoData, String basePath) {
    return {
      "title": videoData.entries.elementAt(audioPlayer.currentIndex ?? 0).value['title'],
      "author":
          videoData.entries.elementAt(audioPlayer.currentIndex ?? 0).value['author'],
      "thumbnail":
          "$basePath/thumbnails/${videoData.entries.elementAt(audioPlayer.currentIndex ?? 0).key}.jpg",
      "playPause": audioPlayer.playing,
      "shuffle": audioPlayer.shuffleModeEnabled,
      "currentPosition": audioPlayer.position.inSeconds,
      "duration": audioPlayer.duration?.inSeconds ?? 0,
      "index": audioPlayer.currentIndex ?? 0,
    };
  }

  void stop() {
    audioPlayer.stop();
  }

  void seekToSecond(int second) {
    audioPlayer.seek(Duration(seconds: second));
    if (!audioPlayer.playing) {
      audioPlayer.play();
    }
  }
}
