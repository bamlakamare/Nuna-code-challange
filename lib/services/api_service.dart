import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  final String baseUrl = 'https://dummyjson.com';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['products'] as List;
      return data.map((json) => Product.fromJson(json)).toList().take(10).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['posts'] as List;
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Comment>> fetchComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/post/$postId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['comments'] as List;
      return data.map((json) => Comment.fromJson(json)).toList().take(10).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }
}
