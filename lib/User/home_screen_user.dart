import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_oguz/User/favorite_screen.dart';
import 'package:news_app_oguz/User/news_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreenUser extends StatefulWidget {
  @override
  _HomeScreenUserState createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  final List<String> categories =  [
    'All',
  'Politics',
  'Sports',
  'Technology',
  'Health',
  'Business',
  'Science',
  'Entertainment',
  'Travel',
  'Education',
  'Environment',
];
  final List<String> faculties = ['All','Computer Science and Information Technology',
   'Economics of Innovations', 'Cyber-physical systems', 'Biotechnology and Ecology', 'Chemistry and Nanotechnology'];


  String selectedCategory = 'All';
  String selectedFaculty = 'All';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0 ? 'Home' : 'Favorites',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: _currentIndex == 0
          ? Drawer(
              child: ListView(
                children: faculties
                    .map((faculty) => ListTile(
                          title: Text(faculty),
                          onTap: () {
                            setState(() {
                              selectedFaculty = faculty;
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ),
            )
          : null,
      body: _currentIndex == 0 ? buildHomeScreen() : FavoriteScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }

  Widget buildHomeScreen() {
    return Column(
      children: [
        buildBannerCarousel(),
        SizedBox(height: 10),
        buildCategories(),
        Expanded(child: buildNewsList()),
      ],
    );
  }

  Widget buildBannerCarousel() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('banners').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final banners = snapshot.data!.docs;

        if (banners.isEmpty) {
          return Center(child: Text('No banners available.'));
        }

        return CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: Duration(seconds: 3),
          ),
          items: banners.map((doc) {
            final imageUrl = doc['imageUrl'];
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map((category) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedCategory == category
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: selectedCategory == category
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildNewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: getFilteredNewsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final newsList = snapshot.data!.docs;

        if (newsList.isEmpty) {
          return Center(
            child: Text('No news available for the selected filters.'),
          );
        }

        return ListView.builder(
          itemCount: newsList.length,
          itemBuilder: (context, index) {
            final news = newsList[index];
            return NewsListItem(news: news);
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> getFilteredNewsStream() {
    CollectionReference newsRef = FirebaseFirestore.instance.collection('news');

    if (selectedCategory == 'All' && selectedFaculty == 'All') {
      return newsRef.snapshots();
    } else if (selectedCategory == 'All') {
      return newsRef.where('faculty', isEqualTo: selectedFaculty).snapshots();
    } else if (selectedFaculty == 'All') {
      return newsRef.where('category', isEqualTo: selectedCategory).snapshots();
    } else {
      return newsRef
          .where('category', isEqualTo: selectedCategory)
          .where('faculty', isEqualTo: selectedFaculty)
          .snapshots();
    }
  }
}



class NewsListItem extends StatefulWidget {
  final QueryDocumentSnapshot news;

  NewsListItem({required this.news});

  @override
  _NewsListItemState createState() => _NewsListItemState();
}

class _NewsListItemState extends State<NewsListItem> {
  late bool isFavorite = false; // Provide a default value

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
    return ListTile(
      leading: Image.network(widget.news['imageUrl'], width: 50, height: 50),
      title: Text(widget.news['title']),
      subtitle: Text(widget.news['description']),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : null,
        ),
        onPressed: _toggleFavorite,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(news: widget.news),
          ),
        );
      },
    );
  }
}






