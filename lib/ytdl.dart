library ytdl;

import 'dart:convert';
import 'dart:io';

import 'classes/editor.dart';
import 'classes/results.dart';
import 'package:http/http.dart' as http;

//downloader

class YoutubeDownloader {
  static const String agent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36";

  YoutubeResults? lastResult;

  Future<String> _getVideoKey(String id) async {
    final url =
        Uri.parse("https://www.youtube.com/watch?v=$id&bpctr=9999999999&hl=en");

    final headers = {
      "cookie": "CONSENT=YES+cb",
      "host": "www.youtube.com",
      "User-Agent": agent,
      "accept":
          "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "upgrade-insecure-requests": "1",
      "sec-gpc": "1",
      "sec-fetch-user": "?1",
      "sec-fetch-site": "none",
      "sec-fetch-mode": "navigate",
      "sec-fetch-dest": "document",
      "accept-language": "en-US,en;q=0.9",
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode != 200) {
        throw Exception("Request failed with status: ${response.statusCode}");
      }

      final apiKey = RegExp(r'"INNERTUBE_API_KEY":"(.+?)"')
          .firstMatch(utf8.decode(response.bodyBytes))!
          .group(1)!;

      return apiKey;
    } catch (e) {
      throw Exception("Failed to get video info: $e");
    }
  }

  Future<YoutubeResults> _fetchResults(String key, String id) async {
    final url = Uri.parse(
        "https://www.youtube.com/youtubei/v1/player?prettyPrint=false&key=$key");
    final body = jsonEncode({
      "context": {
        "client": {
          "clientName": "ANDROID_TESTSUITE",
          "clientVersion": "1.9",
          "androidSdkVersion": 30,
          "hl": "en",
          "gl": "US",
          "utcOffsetMinutes": 0
        }
      },
      "videoId": id
    });

    try {
      final response = await http.post(url, body: body, headers: {
        "Content-Type": "application/json",
        "User-Agent": agent,
      });

      if (response.statusCode != 200) {
        throw Exception("Request failed with status: ${response.statusCode}");
      }

      return YoutubeResults.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)));
    } catch (e) {
      throw Exception("Failed to get video formats: $e");
    }
  }

  List<YoutubeSource> _getAudioList(List<YoutubeSource> sources) {
    return sources.where((audio) => audio.mimeType.contains("audio")).toList();
  }

  List<YoutubeSource> _getVideoList(List<YoutubeSource> sources) {
    return sources.where((video) => video.mimeType.contains("video")).toList();
  }

  String _formatTitle(String title) {
    return title
        .replaceAll(RegExp(r'\(.+?\)'), "")
        .replaceAll(RegExp(r'\s{2,}'), " ")
        .replaceAll(RegExp(r'\[.*\]'), "")
        .trim();
  }

  Future<YoutubeResults> getResults(String id) async {
    try {
      final key = await _getVideoKey(id);
      final results = await _fetchResults(key, id);
      if (results == null) {
        throw Exception("Failed to retrieve results");
      }
      return results;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> downloadAudio(String id, String path,
      {bool fromVideo = false}) async {
    try {
      if (lastResult == null) {
        final key = await _getVideoKey(id);
        final results = await _fetchResults(key, id);

        if (results == null) {
          throw Exception("Failed to retrieve format data");
        }
        lastResult = results;
      }

      final title = _formatTitle(lastResult!.video.title);
      print("title: $title");
      final formats = _getAudioList(lastResult!.sources);

      if (formats.isEmpty) {
        throw Exception("No suitable formats found");
      }

      final selectedFormat = formats.first;

      final url = selectedFormat.url;
      final extension =
          RegExp(r'\/(\w+?);').firstMatch(selectedFormat.mimeType)?.group(1) ??
              'mp4';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to download video file");
      }
      String filePath = "$path/$title.$extension";
      if (fromVideo) {
        filePath = "$path/${title}_aux.$extension";
      }

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print("File downloaded to $filePath");
      return filePath;
    } catch (e) {
      print("Error: $e");
      return "";
    }
  }

  Future<void> downloadVideo(String id, String path) async {
    try {
      if (lastResult == null) {
        final key = await _getVideoKey(id);
        final results = await _fetchResults(key, id);

        if (results == null) {
          throw Exception("Failed to retrieve format data");
        }
        lastResult = results;
      }

      final title = _formatTitle(lastResult!.video.title);
      print("title: $title");
      final formats = _getVideoList(lastResult!.sources);

      if (formats.isEmpty) {
        throw Exception("No suitable formats found");
      }

      final selectedFormat = formats.first;

      final url = selectedFormat.url;
      final extension =
          RegExp(r'\/(\w+?);').firstMatch(selectedFormat.mimeType)?.group(1) ??
              'mp4';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to download video file");
      }
      final filePath = "$path/${title}_vid.$extension";

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print("File downloaded to $filePath");
      final auxPath = await downloadAudio(id, path, fromVideo: true);
      await _mergeMedia(filePath, auxPath, "$path/$title.$extension");
    } catch (e) {
      print("Error: $e");
    }
  }

  _mergeMedia(String vid, String aux, String out) async {
    await VideoEditor.mergeAudioWithVideo(
      vid,
      aux,
      out,
    );
    await File(vid).delete();
    await File(aux).delete();
  }
}
