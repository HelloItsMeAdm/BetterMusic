import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

AudioPlayer audioPlayer = AudioPlayer();
int lastIndex = 0;
bool _isPlaylistSet = false;
bool _isPlaying = false;

class Player {
  void play(Map videoData, String path, int index, BuildContext context, bool useIndex) {
    index = useIndex ? index : lastIndex;
    String message = "";
    if (_isPlaylistSet) {
      if (index == lastIndex) {
        if (_isPlaying) {
          audioPlayer.pause();
          _isPlaying = false;
          message = "Paused";
        } else {
          audioPlayer.play();
          _isPlaying = true;
          message = "Resumed";
        }
      } else {
        audioPlayer.seek(Duration.zero, index: index);
        audioPlayer.play();
        _isPlaying = true;
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

      audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();

      _isPlaying = true;
      _isPlaylistSet = true;
      message = "Set playlist and played $index";
    }
    lastIndex = index;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    ));
  }
}
