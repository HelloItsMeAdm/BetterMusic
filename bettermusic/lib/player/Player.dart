import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

AudioPlayer audioPlayer = AudioPlayer();
String lastSong = '';
bool _isPlaylistSet = false;
bool _isPlaying = false;

class Player {
  Future<void> stop() async {
    await audioPlayer.stop();
    _isPlaying = false;
  }

  void playlist(Map videoData, String path, int index) async {
    if (_isPlaying) {
      await stop();
    }

    // set up the player with metadata
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
  }

  void seekTo(int index, Map videoData, String path, BuildContext context) async {
    if (_isPlaylistSet) {
      if (lastSong != videoData.keys.elementAt(index)) {
        audioPlayer.seek(Duration.zero, index: (index));
        lastSong = videoData.keys.elementAt(index);
      } else {
        if (_isPlaying) {
          audioPlayer.pause();
          _isPlaying = false;
        } else {
          audioPlayer.play();
          _isPlaying = true;
        }
      }
    } else {
      playlist(videoData, path, index);
    }
  }
}
