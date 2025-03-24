import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:news_app_user/User/favorite_screen.dart';
import 'package:news_app_user/User/news_detail_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenUser extends StatefulWidget {
  @override
  _HomeScreenUserState createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  final List<String> categories = [
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
  final List<String> faculties = [
    'All',
    'Computer Science and Information Technology',
    'Economics of Innovations',
    'Cyber-physical systems',
    'Biotechnology and Ecology',
    'Chemistry and Nanotechnology'
  ];

  final Map<String, IconData> facultyIcons = {
    'All': Icons.school,
    'Computer Science and Information Technology': Icons.computer,
    'Economics of Innovations': Icons.attach_money,
    'Cyber-physical systems': Icons.memory,
    'Biotechnology and Ecology': Icons.eco,
    'Chemistry and Nanotechnology': Icons.science,
  };

  String selectedCategory = 'All';
  String selectedFaculty = 'All';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            _currentIndex == 0 ? 'Home' : 'Bookmarks',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromRGBO(123, 208, 185, 1.0)),
      drawer: _currentIndex == 0
          ? Drawer(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'assets/anim/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: Color.fromRGBO(123, 208, 185, 1.0),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      children: faculties.map((faculty) {
                        return ListTile(
                          leading: Icon(
                            facultyIcons[faculty] ?? Icons.school,
                            color: faculty == selectedFaculty
                                ? Color.fromRGBO(123, 208, 185, 1.0)
                                : Colors.grey,
                          ),
                          title: Text(
                            faculty,
                            style: TextStyle(
                              fontWeight: faculty == selectedFaculty
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: faculty == selectedFaculty
                                  ? Color.fromRGBO(123, 208, 185, 1.0)
                                  : Colors.black,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedFaculty = faculty;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: RefreshIndicator(
         onRefresh: () async {
          setState(() {});
        },
        child: _currentIndex == 0 ? buildHomeScreen() : FavoriteScreen()),
      bottomNavigationBar: Material(
        elevation: 8, // Adds elevation/shadow effect
        shadowColor: Colors.black.withOpacity(0.3), // Adjust shadow color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor:
                Color.fromRGBO(123, 208, 185, 1.0), // Selected item color
            unselectedItemColor: Colors.grey, // Unselected item color
            selectedFontSize: 14,
            unselectedFontSize: 12,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined), // Outlined for unselected
                activeIcon: Icon(Icons.home), // Solid for selected
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border), // Outlined for unselected
                activeIcon: Icon(Icons.bookmark), // Solid for selected
                label: 'Bookmarks',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHomeScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: buildBannerCarousel(),
        ),
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
                          ? const Color.fromRGBO(123, 208, 185, 1.0)
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Lottie.asset('assets/anim/no_data.json'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No news available for the selected filters.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 5),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(news: widget.news),
              ),
            );
          },
          child: Row(
            children: [
              // Image Section
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  widget.news['imageUrl'],
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.news['title'],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.news['date'].toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
