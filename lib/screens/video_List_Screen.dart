import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nuna_tech_code_challange/screens/video_Detail_Screen.dart';
import '../models/video.dart';

class VideoListScreen extends StatelessWidget {
  final String apiUrl = 'https://nu-exercise-videos-api-93ee2892edae.herokuapp.com/api/videos';
  final Map<String, String> headers = {
    'x-apikey-header': 'api-access-key-5544',
  };

  Future<List<Video>> fetchVideos() async {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<dynamic> data = jsonData['data'];
      return data.map((json) => Video.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video List'),
      ),
      body: FutureBuilder<List<Video>>(
        future: fetchVideos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final videos = snapshot.data ?? [];

            return ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return ListTile(
                  title: Text(video.title),
                  subtitle: Text('Created at: ${video.createdAt}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailScreen(videoId: video.id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
