import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'Constants.dart';

class DownloadManager {
  final YoutubeExplode yt = YoutubeExplode();

  Future<void> download(String id) async {
    String basePath = await Constants().getAppSpecificFilesDir();

    final String mp3Path = "$basePath/mp3/$id.mp3";
    final String thumbnailPath = "$basePath/thumbnails/$id.jpg";

    await createFolders(basePath);

    await downloadThumbnail(thumbnailPath, id);

    // Check if file already exists or if path is invalid
    if (basePath == "" || await File(mp3Path).exists()) {
      return;
    }

    if (kDebugMode) {
      print("Downloading mp3 for $id");
    }

    final manifest = await yt.videos.streamsClient.getManifest(id);
    final streamInfo = manifest.audioOnly.withHighestBitrate();

    var stream = yt.videos.streamsClient.get(streamInfo);

    // Open a file for writing.
    var file = File(mp3Path);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    if (kDebugMode) {
      print("Downloaded mp3 for $id");
    }
  }

  Future<Map> getDownloadedFiles() async {
    String basePath = await Constants().getAppSpecificFilesDir();
    await createFolders(basePath);
    final List<FileSystemEntity> files = Directory("$basePath/mp3").listSync();
    final Map<String, String> data = <String, String>{};
    for (final FileSystemEntity file in files) {
      if (!file.path.contains(".thumbnails")) {
        final String name = file.path.split("/").last;
        data[name] = file.path;
      }
    }
    return data;
  }

  Future<void> downloadThumbnail(String thumbnailPath, String id) async {
    if (kDebugMode) {
      print("Downloading thumbnail for $id");
    }
    if (await File(thumbnailPath).exists()) {
      return;
    }

    final HttpClientRequest request = await HttpClient()
        .getUrl(Uri.parse("https://i.ytimg.com/vi/$id/maxresdefault.jpg"));
    final HttpClientResponse response = await request.close();

    final File file = File(thumbnailPath);
    await file.writeAsBytes(await consolidateHttpClientResponseBytes(response));

    if (kDebugMode) {
      print("Downloaded thumbnail for $id");
    }

    return;
  }

  Future<void> createFolders(String path) async {
    final Directory mp3Dir = Directory("$path/mp3");
    final Directory thumbnailDir = Directory("$path/thumbnails");
    if (!await mp3Dir.exists()) {
      await mp3Dir.create(recursive: true);
    }
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
  }

  void removeOldFiles(Map videoData, String basePath) async {
    //get all files in mp3 folder and if it is not in videoData, delete mp3 and thumbnail
    //paths
    //$basePath/mp3/$id.mp3
    //$basePath/thumbnails/$id.jpg

    final List<FileSystemEntity> files = Directory("$basePath/mp3").listSync();
    for (final FileSystemEntity file in files) {
      final String name = file.path.split("/").last.replaceAll(".mp3", "");
      if (!videoData.containsKey(name)) {
        print("Deleting $basePath/mp3/$name.mp3");
        print("Deleting $basePath/thumbnails/$name.jpg");

        if (await File("$basePath/mp3/$name.mp3").exists()) {
          await File("$basePath/mp3/$name.mp3").delete();
        }
        if (await File("$basePath/thumbnails/$name.jpg").exists()) {
          await File("$basePath/thumbnails/$name.jpg").delete();
        }
        return;
      }
    }
  }
}
