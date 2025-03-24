import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:news_app_oguz/Admin/edit_news.dart';
import 'package:news_app_oguz/Admin/login_firebase.dart';
import 'add_news_screen.dart'; // Import your AddNewsScreen

class NewsHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final storage = FlutterSecureStorage();
              await FirebaseAuth.instance.signOut();
              await storage.delete(key: 'firebase_token');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('news').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No news added yet.'));
          }

          final newsList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              final news = newsList[index];
              final newsId = news.id;
              final newsData = news.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: newsData['imageUrl'] != null
                      ? Image.network(newsData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50),
                  title: Text(newsData['title'] ?? 'No Title', style: TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,),
                  subtitle: Text(newsData['date'] ?? 'No Description'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navigate to AddNewsScreen with pre-filled data for editing
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNews(
                                newsId: newsId,
                                existingData: newsData,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance.collection('news').doc(newsId).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('News deleted successfully.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewsScreen()),
          );
        },
      ),
    );
  }
}
