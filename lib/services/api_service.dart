// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const _baseUrl = 'https://dummyjson.com';

  Future<List<dynamic>> fetchProducts() async {
    final response = await http.get(Uri.parse('$_baseUrl/products?limit=10'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['products'];
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<dynamic>> fetchPosts(int skip) async {
    final response = await http.get(Uri.parse('$_baseUrl/posts?skip=$skip&limit=4'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['posts'];
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<dynamic>> fetchComments(int postId) async {
    final response = await http.get(Uri.parse('$_baseUrl/comments/post/$postId?limit=10'));
    if (response.statusCode == 200) {
      return json.decode(response.body)['comments'];
    } else {
      throw Exception('Failed to load comments');
    }
  }
}
