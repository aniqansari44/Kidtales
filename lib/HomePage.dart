import 'package:flutter/material.dart';
import 'SearchScreen.dart'; // Ensure this file exists with the SearchScreen class
import 'SettingsScreen.dart'; // Ensure this file exists with the SettingsScreen class
import 'HistoryScreen.dart'; // Ensure this file exists with the HistoryScreen class
import 'InputScreen.dart';
import 'SaveStoryScreen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KidTales', style: TextStyle(fontFamily: 'ComicSans', fontSize: 24, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.purple[400],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/home.png'), // Replace with your logo asset
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Categories',
                    style: TextStyle(fontFamily: 'ComicSans', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple[400]),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  children: <Widget>[
                    CategoryCard(
                      imagePath: 'assets/images/generate.png', // Replace with your asset
                      label: 'Generate New Stories',
                    ),
                    CategoryCard(
                      imagePath: 'assets/images/history.png', // Replace with your asset
                      label: 'View Listened Stories',
                    ),
                    CategoryCard(
                      imagePath: 'assets/images/listen.png', // Replace with your asset
                      label: 'Listen to Stories',
                    ),
                    // Add more categories as needed
                  ],
                ),
              ],
            ),
          ),
          SearchScreen(), // Your actual search screen widget
          SettingsScreen(), // Your actual settings screen widget
        ],
        physics: NeverScrollableScrollPhysics(), // Disable swiping
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        backgroundColor: Colors.purple[200],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String imagePath;
  final String label;

  const CategoryCard({required this.imagePath, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: InkWell(
        onTap: () {
          // Check the label and navigate accordingly
          switch (label) {
            case 'View Listened Stories':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
              break;
            case 'Generate New Stories':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InputScreen()), // Make sure InputScreen is defined
              );
              break;
            case 'Listen to Stories':
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SaveStoryScreen()), // Make sure SaveStoryScreen is defined
              );
              break;
          // Add more cases as needed for other categories
          }
        },
        child: GridTile(
          footer: Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.black.withOpacity(0.5),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'ComicSans'),
              textAlign: TextAlign.center,
            ),
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
