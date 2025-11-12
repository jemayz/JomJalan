import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:jomjalan/screens/ai_planner_page.dart';
import 'package:jomjalan/screens/home_page.dart';
import 'package:jomjalan/screens/jomclone_page.dart';
import 'package:jomjalan/screens/map_page.dart';
import 'package:jomjalan/screens/profile_page.dart';
import 'package:jomjalan/main.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({Key? key}) : super(key: key);

  @override
  _MainNavScreenState createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomePage(),
    MapPage(),
    AiPlannerPage(),
    JomClonePage(),
    const ProfilePage(),
  ];
  // ---------------------

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        backgroundColor: backgroundColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,

        showSelectedLabels: true,
        showUnselectedLabels: true,

        currentIndex: _selectedIndex,

        onTap: _onItemTapped,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Ionicons.home_outline),
            activeIcon: Icon(Ionicons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.search_outline),
            activeIcon: Icon(Ionicons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.sparkles_outline),
            activeIcon: Icon(Ionicons.sparkles),
            label: "AI Planner",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.copy_outline),
            activeIcon: Icon(Ionicons.copy),
            label: "JomClone",
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.person_outline),
            activeIcon: Icon(Ionicons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
