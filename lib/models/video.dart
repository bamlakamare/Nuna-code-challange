class Video {
  final String id;
  final String title;
  final String createdAt;

  Video({required this.id, required this.title, required this.createdAt});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'],
      title: json['title'],
      createdAt: json['createdAt'],
    );
  }
}

class VideoDetails {
  final String id;
  final String title;
  final String videoUrl;

  VideoDetails({
    required this.id,
    required this.title,
    required this.videoUrl,
  });

  factory VideoDetails.fromJson(Map<String, dynamic> json) {
    return VideoDetails(
      id: json['data']['_id'],
      title: json['data']['title'],
      videoUrl: json['data']['videoUrl'],
    );
  }
}
