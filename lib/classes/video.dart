class YoutubeVideo {
  final String url;
  final String id;
  final String title;
  final String author;
  final String description;
  final Duration length;
  final List<String> keywords;
  final String channelId;
  final List<YoutubeThumbnail> thumbnails;
  final String views;
  final bool isPrivate;
  final bool isLiveContent;
  final bool isUnpluggedCorpus;
  final bool allowRatings;

  YoutubeVideo({
    required this.id,
    required this.url,
    required this.title,
    required this.author,
    required this.channelId,
    required this.thumbnails,
    required this.views,
    required this.length,
    required this.description,
    required this.keywords,
    required this.isLiveContent,
    required this.isPrivate,
    required this.isUnpluggedCorpus,
    required this.allowRatings,
  });

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    var thumbnailsJson = json['thumbnail']['thumbnails'] as List<dynamic>;
    List<YoutubeThumbnail> thumbnails = thumbnailsJson
        .map((e) => YoutubeThumbnail.fromJson(e as Map<String, dynamic>))
        .toList();
    List keywordsJson = json["keywords"];
    List<String> keywords = keywordsJson.map((e) => "$e",).toList();

    return YoutubeVideo(
      id: json["videoId"],
      url: "https://youtube.com/watch?v=${json["videoId"]}",
      title: json["title"],
      author: json["author"],
      channelId: json["channelId"],
      thumbnails: thumbnails,
      views: json["viewCount"],
      length: Duration(seconds: int.parse(json["lengthSeconds"])),
      description: json["shortDescription"],
      keywords: keywords,
      isLiveContent: json["isLiveContent"],
      isPrivate: json["isPrivate"],
      isUnpluggedCorpus: json["isUnpluggedCorpus"],
      allowRatings: json["allowRatings"],
    );
  }
}

class YoutubeThumbnail {
  final String url;
  final int width;
  final int height;

  YoutubeThumbnail({
    required this.url,
    required this.height,
    required this.width,
  });

  factory YoutubeThumbnail.fromJson(Map<String, dynamic> json) {
    return YoutubeThumbnail(
      url: json["url"],
      height: json["height"],
      width: json["width"],
    );
  }
}
