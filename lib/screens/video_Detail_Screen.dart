import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_api_service.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoId;

  const VideoDetailScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final VideoApiService _apiService = VideoApiService();
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isLoading = true;
  double _playbackSpeed = 1.0; // Default playback speed

  @override
  void initState() {
    super.initState();
    _fetchVideoDetails();
  }

  void _fetchVideoDetails() async {
    try {
      final videoDetails = await _apiService.fetchVideoDetails(widget.videoId);
      final videoUrl = videoDetails['videoUrl'].replaceAll('view?usp=drive_link', 'preview'); // Adjust URL for direct streaming

      _videoPlayerController = VideoPlayerController.network(videoUrl);
      _initializeVideoPlayerFuture = _videoPlayerController.initialize();
      _videoPlayerController.setLooping(true);

      setState(() {
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
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _videoPlayerController.setPlaybackSpeed(_playbackSpeed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Details'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                  SizedBox(height: 16),
                  VideoProgressIndicator(
                    _videoPlayerController,
                    allowScrubbing: true,
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.replay_10),
                        onPressed: () {
                          _videoPlayerController.seekTo(
                            _videoPlayerController.value.position - Duration(seconds: 10),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_videoPlayerController.value.isPlaying) {
                              _videoPlayerController.pause();
                            } else {
                              _videoPlayerController.play();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.forward_10),
                        onPressed: () {
                          _videoPlayerController.seekTo(
                            _videoPlayerController.value.position + Duration(seconds: 10),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => _changePlaybackSpeed(0.5),
                        child: Text('0.5x'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _changePlaybackSpeed(1.0),
                        child: Text('1.0x'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _changePlaybackSpeed(1.5),
                        child: Text('1.5x'),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _changePlaybackSpeed(2.0),
                        child: Text('2.0x'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
