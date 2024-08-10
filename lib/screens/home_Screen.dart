import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nuna_tech_code_challange/screens/video_List_Screen.dart';
import '../models/product.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class home_Screen extends StatefulWidget {
  @override
  _home_ScreenState createState() => _home_ScreenState();
}

class _home_ScreenState extends State<home_Screen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> products;
  late Future<List<Post>> posts;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    products = apiService.fetchProducts();
    posts = apiService.fetchPosts();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      print('Token: $token');
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHome();
      case 1:
        return _buildVideos();
      default:
        return _buildHome();
    }
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text('Products and Posts with Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),

            FutureBuilder<List<Product>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return ProductList(products: snapshot.data!);
                }
              },
            ),
            FutureBuilder<List<Post>>(
              future: posts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return PostList(posts: snapshot.data!, apiService: apiService);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideos() {
    return VideoListScreen();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _buildPage(),
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
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class ProductList extends StatelessWidget {
  final List<Product> products;

  ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(product.thumbnail),
            ),
            title: Text(
              product.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '\$${product.price}',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  product.description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
            onExpansionChanged: (bool expanded) {
              if (expanded) {
              }
            },
            initiallyExpanded: false,
            iconColor: Colors.teal,
            collapsedIconColor: Colors.grey,
            backgroundColor: Colors.white.withOpacity(0.9),
          ),
        );
      },
    );
  }
}

class PostList extends StatelessWidget {
  final List<Post> posts;
  final ApiService apiService;

  PostList({required this.posts, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ExpansionTile(
            title: Text(
              post.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  post.body,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              FutureBuilder<List<Comment>>(
                future: apiService.fetchComments(post.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error loading comments');
                  } else {
                    return Column(
                      children: snapshot.data!
                          .map((comment) => ListTile(
                        title: Text(comment.body),
                        leading: Icon(Icons.comment),
                      ))
                          .toList(),
                    );
                  }
                },
              ),
            ],
            initiallyExpanded: false,
            iconColor: Colors.blue,
            collapsedIconColor: Colors.grey,
            backgroundColor: Colors.white.withOpacity(0.9),
          ),
        );
      },
    );
  }
}
