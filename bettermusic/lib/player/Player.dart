import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

bool _isPlaying = false;
AudioPlayer audioPlayer = AudioPlayer();
String lastSong = '';

class Player {
  String currentTitle = '';
  String currentAuthor = '';
  String currentThumbnailPath = '';
  Duration currentDuration = const Duration(seconds: 0);
  Duration currentPosition = const Duration(seconds: 0);

  void play(String path, String title, String author, String thumbnailPath) async {
    if (lastSong != path) {
      if (_isPlaying) {
        await stop();
      }

      // set up the player with metadata
      audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse("file://$path"),
            tag: MediaItem(
              id: "1",
              title: title,
              album: author,
              artUri: Uri.parse("file://$thumbnailPath"),
            )),
      );
      audioPlayer.play();
      _isPlaying = true;
    } else {
      if (_isPlaying) {
        audioPlayer.pause();
        _isPlaying = false;
      } else {
        audioPlayer.play();
        _isPlaying = true;
      }
    }
    lastSong = path;
    currentTitle = title;
    currentAuthor = author;
    currentThumbnailPath = thumbnailPath;
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    _isPlaying = false;
  }

  void updateCurrentSongInfo(String title, String author, String thumbnailPath) {
    currentTitle = title;
    currentAuthor = author;
    currentThumbnailPath = thumbnailPath;
    currentDuration = audioPlayer.duration!;
    currentPosition = audioPlayer.position;
  }
}
