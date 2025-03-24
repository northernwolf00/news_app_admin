import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteIds = prefs.getStringList('favorites') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('news').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final favoriteNews = snapshot.data!.docs
              .where((doc) => favoriteIds.contains(doc.id))
              .toList();

          if (favoriteNews.isEmpty) {
            return Center(child: Text('No favorites added yet.'));
          }

          return ListView.builder(
            itemCount: favoriteNews.length,
            itemBuilder: (context, index) {
              final news = favoriteNews[index];
              return ListTile(
                leading: Image.network(news['imageUrl'], width: 50, height: 50),
                title: Text(news['title']),
                subtitle: Text(news['description']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final favorites = prefs.getStringList('favorites') ?? [];
                    favorites.remove(news.id);
                    await prefs.setStringList('favorites', favorites);
                    setState(() {
                      favoriteIds.remove(news.id);
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}