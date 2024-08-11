// lib/screens/video_list_screen.dart
import 'package:flutter/material.dart';
import '../services/video_api_service.dart';
import 'video_detail_screen.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final VideoApiService _apiService = VideoApiService();
  List<dynamic> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  void _fetchVideos() async {
    try {
      final videos = await _apiService.fetchVideos();
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Videos List'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          final video = _videos[index];
          return ListTile(
            title: Text(video['title']),
            subtitle: Text('Created At: ${video['createdAt']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoDetailScreen(videoId: video['_id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
