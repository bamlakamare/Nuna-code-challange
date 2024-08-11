import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isFullScreen = false; // Track full-screen state

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

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }

    // Use Navigator to remove and add the route to force the layout update
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoDetailScreen(videoId: widget.videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null // Hide the AppBar in full-screen mode
          : AppBar(
        title: Text('Video Details'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<void>(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
