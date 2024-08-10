import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import '../models/video.dart';

class VideoDetailScreen extends StatefulWidget {
  final String videoId;

  VideoDetailScreen({required this.videoId});

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoPlayerController _controller;
  Future<VideoDetails>? _videoDetails;

  @override
  void initState() {
    super.initState();
    _videoDetails = fetchVideoDetails(widget.videoId);
  }

  Future<VideoDetails> fetchVideoDetails(String videoId) async {
    final String detailsUrl =
        'https://nu-exercise-videos-api-93ee2892edae.herokuapp.com/api/videos/$videoId';
    final Map<String, String> headers = {
      'x-apikey-header': 'api-access-key-5544',
    };

    final response = await http.get(Uri.parse(detailsUrl), headers: headers);

    if (response.statusCode == 200) {
      return VideoDetails.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load video details');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.teal,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('Video Player', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        ),
        body: FutureBuilder<VideoDetails>(
          future: _videoDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final videoDetails = snapshot.data!;
              final videoUrl = videoDetails.videoUrl;
      
              // Initialize the video player controller
              _controller = VideoPlayerController.network(videoUrl)
                ..initialize().then((_) {
                  setState(() {});
                });
      
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    _controller.value.isInitialized
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    )
                        : Center(child: CircularProgressIndicator(color: Colors.teal,)),
      
                    SizedBox(height: 16),

                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.teal,
                        bufferedColor: Colors.tealAccent.withOpacity(0.5),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                      ),
                    ),
      
                    SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.replay_10,
                          onPressed: () {
                            final newPosition =
                                _controller.value.position - Duration(seconds: 10);
                            _controller.seekTo(
                                newPosition > Duration.zero ? newPosition : Duration.zero);
                          },
                        ),
                        _buildControlButton(
                          icon: _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          onPressed: () {
                            setState(() {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            });
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.forward_10,
                          onPressed: () {
                            final newPosition =
                                _controller.value.position + Duration(seconds: 10);
                            _controller.seekTo(newPosition);
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.speed,
                          onPressed: () {
                            final newSpeed =
                            _controller.value.playbackSpeed == 1.0 ? 1.5 : 1.0;
                            _controller.setPlaybackSpeed(newSpeed);
                          },
                        ),
                      ],
                    ),
      
                    SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        videoDetails.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon),
      color: Colors.teal,
      iconSize: 32,
      onPressed: onPressed,
    );
  }
}
