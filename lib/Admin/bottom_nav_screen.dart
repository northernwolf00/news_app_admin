import 'package:flutter/material.dart';
import 'package:news_app_oguz/Admin/home_fireabse.dart';
import 'package:news_app_oguz/Admin/list_banners_screen.dart';

class BottomNavScreen extends StatefulWidget {
  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;
  final _screens = [
    NewsHome(),
    BannerListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.image), label: 'Banners'),
        ],
      ),
    );
  }
}
