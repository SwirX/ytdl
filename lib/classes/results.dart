import 'video.dart';

class YoutubeResults {
  final YoutubeVideo video;
  final List<YoutubeSource> sources;

  YoutubeResults({required this.video, required this.sources});

  factory YoutubeResults.fromJson(Map<String, dynamic> json) {
    print(json);
    final List sourcesJson = json["streamingData"]["adaptiveFormats"];
    final List<YoutubeSource> sources =
        sourcesJson.map((e) => YoutubeSource.fromJson(e)).toList();
    return YoutubeResults(
      video: YoutubeVideo.fromJson(json["videoDetails"]),
      sources: sources,
    );
  }
}

class YoutubeSource {
  final int itag;
  final String url;
  final String mimeType;
  final int bitrate;
  final int width;
  final int height;
  final int contentLength;
  final String quality;
  final int fps;
  final String qualityLabel;

  YoutubeSource({
    required this.itag,
    required this.url,
    required this.mimeType,
    required this.bitrate,
    required this.width,
    required this.height,
    required this.contentLength,
    required this.quality,
    required this.qualityLabel,
    required this.fps,
  });
  factory YoutubeSource.fromJson(Map<String, dynamic> json) {
    return YoutubeSource(
      itag: json["itag"],
      url: json["url"],
      mimeType: json["mimeType"],
      bitrate: json["bitrate"],
      width: json["width"] ?? 0,
      height: json["height"] ?? 0,
      contentLength: int.parse(json["contentLength"]),
      quality: json["quality"],
      qualityLabel: json["qualityLabel"] ?? "",
      fps: json["fps"] ?? 0,
    );
  }
}
