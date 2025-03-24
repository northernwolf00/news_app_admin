import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_oguz/Admin/add_baner_screen.dart';

class BannerListScreen extends StatelessWidget {
  Future<void> _deleteBanner(String bannerId) async {
    try {
      // Delete the banner document from Firestore
      await FirebaseFirestore.instance
          .collection('banners')
          .doc(bannerId)
          .delete();

      debugPrint('Banner deleted successfully');
    } catch (e) {
      debugPrint('Error deleting banner: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banners'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('banners').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No banners available'));
          }

          final banners = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              final bannerId = banner.id;
              final imageUrl = banner['imageUrl'];

              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Uploaded: ${banner['uploadedAt'].toDate()}',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Confirm before deleting
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Delete Banner'),
                              content: Text(
                                  'Are you sure you want to delete this banner?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          await _deleteBanner(bannerId);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBannerScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
