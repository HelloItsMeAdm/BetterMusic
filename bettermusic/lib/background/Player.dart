import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../utils/SharedPrefs.dart';

AudioPlayer audioPlayer = AudioPlayer();
bool _isPlaylistSet = audioPlayer.audioSource != null;

class Player {
  Future<void> play(Map videoData, String path, int index) async {
    if (_isPlaylistSet) {
      if (index == audioPlayer.currentIndex) {
        audioPlayer.playing ? audioPlayer.pause() : audioPlayer.play();
      } else {
        audioPlayer.seek(Duration.zero, index: index);
        audioPlayer.play();
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
      if (audioPlayer.shuffleModeEnabled) {
        audioPlayer.shuffle();
      }
      audioPlayer.seek(Duration.zero, index: index);
      audioPlayer.play();

      _isPlaylistSet = true;
    }
  }

  void previous() async {
    await audioPlayer.seekToPrevious();
  }

  void next() async {
    await audioPlayer.seekToNext();
  }

  void pause() async {
    await audioPlayer.pause();
  }

  Future<Map<String, dynamic>> playPause(Map videoData, String basePath) async {
    play(videoData, basePath, audioPlayer.currentIndex ?? 0);

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
    _isPlaylistSet = false;
  }

  void seekToSecond(int second) {
    audioPlayer.seek(Duration(seconds: second));
    if (!audioPlayer.playing) {
      audioPlayer.play();
    }
  }

  int pauseType() {
    // 0 - playing
    // 1 - paused by user
    // 2 - stopped

    if (audioPlayer.playing) {
      return 0;
    } else if (audioPlayer.playing == false && _isPlaylistSet) {
      return 1;
    } else {
      return 2;
    }
  }
}
