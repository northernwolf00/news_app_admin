import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsDetailScreen extends StatefulWidget {
  final QueryDocumentSnapshot news;

  NewsDetailScreen({required this.news});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  void _checkFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.news.id);
    });
  }

  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favorites.remove(widget.news.id);
    } else {
      favorites.add(widget.news.id);
    }

    await prefs.setStringList('favorites', favorites);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'share') {
                Share.share(widget.news['imageUrl']);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'share', child: Text('Share')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Image.network(widget.news['imageUrl']),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.news['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.news['description']),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            label: Text('Share'),
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(widget.news['imageUrl']);
            },
          ),
          FloatingActionButton.extended(
            label: Text(isFavorite ? 'Unfavorite' : 'Favorite'),
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
    );
  }
}