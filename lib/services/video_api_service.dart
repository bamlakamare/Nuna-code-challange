// lib/services/video_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoApiService {
  final String _baseUrl = 'https://nu-exercise-videos-api-93ee2892edae.herokuapp.com';
  final Map<String, String> _headers = {
    'x-apikey-header': 'api-access-key-5544',
  };

  Future<List<dynamic>> fetchVideos() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/videos'), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<dynamic> fetchVideoDetails(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/videos/$id'), headers: _headers);
    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load video details');
    }
  }
}
