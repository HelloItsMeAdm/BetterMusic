import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../widgets/Snacker.dart';
import 'Constants.dart';

class DownloadManager {
  final YoutubeExplode yt = YoutubeExplode();

  Future<void> download(String id, BuildContext context, String title) async {
    String basePath = await Constants().getAppSpecificFilesDir();

    final String mp3Path = "$basePath/mp3/$id.mp3";
    final String thumbnailPath = "$basePath/thumbnails/$id.jpg";

    await createFolders(basePath);

    await downloadThumbnail(thumbnailPath, id);

    // Check if file already exists or if path is invalid
    if (basePath == "" || await File(mp3Path).exists()) {
      return;
    }

    final manifest = await yt.videos.streamsClient.getManifest(id);
    final streamInfo = manifest.audioOnly.withHighestBitrate();

    var stream = yt.videos.streamsClient.get(streamInfo);

    // Open a file for writing.
    var file = File(mp3Path);
    var fileStream = file.openWrite();

    Snacker().show(
        context: context,
        contentType: ContentType.warning,
        title: "Downloading started...",
        message: title);

    // Write the stream to the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    //wait for the thumbnail to be downloaded and then show the snackbar
    while (!await File(thumbnailPath).exists()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    Snacker().show(
        context: context,
        contentType: ContentType.success,
        title: "Download complete!",
        message: title);
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
    if (await File(thumbnailPath).exists()) {
      return;
    }

    final HttpClientRequest request = await HttpClient()
        .getUrl(Uri.parse("https://i.ytimg.com/vi/$id/maxresdefault.jpg"));
    final HttpClientResponse response = await request.close();

    final File file = File(thumbnailPath);
    await file.writeAsBytes(await consolidateHttpClientResponseBytes(response));

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

  void removeOldFiles(Map videoData, String basePath, BuildContext context) async {
    final List<FileSystemEntity> files = Directory("$basePath/mp3").listSync();
    for (final FileSystemEntity file in files) {
      final String name = file.path.split("/").last.replaceAll(".mp3", "");
      if (!videoData.containsKey(name)) {
        Snacker().show(
            context: context,
            contentType: ContentType.failure,
            title: "Removed old file!",
            message: "$name.mp3");

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
