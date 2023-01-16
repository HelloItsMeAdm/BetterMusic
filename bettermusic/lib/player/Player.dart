import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

AudioPlayer audioPlayer = AudioPlayer();
int lastIndex = 0;
bool _isPlaylistSet = audioPlayer.audioSource != null;

class Player {
  void play(Map videoData, String path, int index, BuildContext context, bool useIndex) {
    index = useIndex ? index : lastIndex;
    String message = "";
    if (_isPlaylistSet) {
      if (index == lastIndex) {
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
      audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();

      _isPlaylistSet = true;
      message = "Set playlist and played $index";
    }
    lastIndex = index;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }

  bool isPlaying() {
    return audioPlayer.playing;
  }

  bool isShuffle() {
    return audioPlayer.shuffleModeEnabled;
  }

  void previous() async {
    await audioPlayer.seekToPrevious();
    lastIndex = audioPlayer.currentIndex!;
  }

  void next() async{
    await audioPlayer.seekToNext();
    lastIndex = audioPlayer.currentIndex!;
  }

  Future<Map<String, dynamic>> playPause(
      Map videoData, String basePath, BuildContext context) async {
    play(videoData, basePath, lastIndex, context, false);

    return {
      "title": videoData.entries.elementAt(lastIndex).value['title'],
      "author": videoData.entries.elementAt(lastIndex).value['author'],
      "thumbnail":
          "$basePath/thumbnails/${videoData.entries.elementAt(lastIndex).key}.jpg",
      "playPause": audioPlayer.playing,
      "shuffle": audioPlayer.shuffleModeEnabled,
    };
  }

  Future<bool> shuffle() async {
    if (audioPlayer.shuffleModeEnabled) {
      audioPlayer.setShuffleModeEnabled(false);
    } else {
      audioPlayer.setShuffleModeEnabled(true);
    }
    return audioPlayer.shuffleModeEnabled;
  }

  Map<String, dynamic> getData(Map videoData, String basePath) {
    return {
      "title": videoData.entries.elementAt(lastIndex).value['title'],
      "author": videoData.entries.elementAt(lastIndex).value['author'],
      "thumbnail":
          "$basePath/thumbnails/${videoData.entries.elementAt(lastIndex).key}.jpg",
      "playPause": audioPlayer.playing,
      "shuffle": audioPlayer.shuffleModeEnabled,
    };
  }
}
