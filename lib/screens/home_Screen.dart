// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:nuna_tech_code_challange/screens/video_List_Screen.dart';
import '../services/api_service.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _products = [];
  List<dynamic> _posts = [];
  bool _isLoadingMore = false;
  bool _isLoadingInitial = true; // Track initial data loading state
  int _postSkip = 0;
  bool _hasMorePosts = true; // Track if more posts are available

  int _selectedIndex = 0; // Track selected page index

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _scrollController.addListener(_scrollListener);
  }

  void _fetchInitialData() async {
    try {
      final products = await _apiService.fetchProducts();
      final postsWithComments = await _fetchPostsAndComments(_postSkip);

      setState(() {
        _products = products;
        _posts.addAll(postsWithComments);
        _postSkip += postsWithComments.length;
        _isLoadingInitial = false; // Data has been loaded
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
      setState(() {
        _isLoadingInitial = false; // Ensure loading indicator hides if error occurs
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore) {
      _fetchMorePosts();
    }
  }

  Future<List<dynamic>> _fetchPostsAndComments(int skip) async {
    final posts = await _apiService.fetchPosts(skip);
    final postsWithComments = <Map<String, dynamic>>[];

    for (var post in posts) {
      final comments = await _apiService.fetchComments(post['id']);
      postsWithComments.add({
        'post': post,
        'comments': comments,
      });
    }

    return postsWithComments;
  }

  Future<void> _fetchMorePosts() async {
    if (!_hasMorePosts) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final morePostsWithComments = await _fetchPostsAndComments(_postSkip);

      setState(() {
        if (morePostsWithComments.isEmpty) {
          _hasMorePosts = false; // No more posts available
        } else {
          _posts.addAll(morePostsWithComments);
          _postSkip += morePostsWithComments.length;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      // Handle error
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products & Posts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      body: _selectedIndex == 0 ? _buildProductsAndComments() : VideoListScreen(), // Display based on selected index
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.teal,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  Widget _buildProductsAndComments() {
    return _isLoadingInitial
        ? Center(
      child: CircularProgressIndicator(),
    )
        : ListView.builder(
      controller: _scrollController,
      itemCount: _products.length + _posts.length + 1, // +1 for the loading indicator
      itemBuilder: (context, index) {
        if (index < _products.length) {
          // Display products
          final product = _products[index];
          return ProductCard(product: product);
        } else if (index < _products.length + _posts.length) {
          // Display posts with comments
          final postIndex = index - _products.length;
          final postWithComments = _posts[postIndex];
          final post = postWithComments['post'];
          final comments = postWithComments['comments'];
          return PostCard(post: post, comments: comments);
        } else {
          // Display loading indicator at the bottom
          return _isLoadingMore
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
              : SizedBox.shrink(); // Hide the indicator if not loading
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class ProductCard extends StatelessWidget {
  final dynamic product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 16 / 9, // Maintain a 16:9 aspect ratio for images
              child: Image.network(
                product['thumbnail'],
                fit: BoxFit.cover, // Ensure the image covers the entire box
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '\$${product['price']}',
                  style: TextStyle(fontSize: 16, color: Colors.teal),
                ),
                SizedBox(height: 8),
                Text(
                  product['description'],
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class PostCard extends StatefulWidget {
  final dynamic post;
  final List<dynamic> comments;

  const PostCard({Key? key, required this.post, required this.comments}) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final int previewLineCount = 3; // Number of lines to show before "Show More"

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post['title'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8), // Add space between title and body
            Text(
              widget.post['body'],
              style: TextStyle(color: Colors.black87),
              maxLines: _isExpanded ? null : previewLineCount,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (!_isExpanded)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                child: Text(
                  'Show More',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            if (_isExpanded)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                child: Text(
                  'Show Less',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            if (widget.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0), // Add space before comments
                child: ExpansionTile(
                  title: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
                  children: widget.comments.map((comment) {
                    return ListTile(
                      title: Text(comment['body']),
                      subtitle: Text('By ${comment['user']['username']}'),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

