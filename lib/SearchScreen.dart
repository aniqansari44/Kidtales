import 'package:flutter/material.dart';
import 'StoriesDisplayScreen.dart'; // Import the StoriesDisplayScreen

class SearchScreen extends StatelessWidget {
  final List<Map<String, String>> genres = [
    {'name': 'Adventure', 'image': 'assets/images/adventure.png'},
    {'name': 'Fantasy', 'image': 'assets/images/fantasy.png'},
    {'name': 'Sci-Fi', 'image': 'assets/images/sci-fi.png'},
    {'name': 'Mystery', 'image': 'assets/images/historical.png'},
    {'name': 'Comedy', 'image': 'assets/images/comedy.png'},
    {'name': 'Tale', 'image': 'assets/images/drama.png'},
    {'name': 'Horror', 'image': 'assets/images/horror.png'},
    {'name': 'Fiction', 'image': 'assets/images/romance.png'},
    // ... other genres ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Genres',
          style: TextStyle(fontFamily: 'ComicSans', fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[400],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: genres.length,
        itemBuilder: (BuildContext context, int index) {
          var genre = genres[index];
          return GenreButton(
            genre: genre['name']!,
            image: genre['image']!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoriesDisplayScreen(genre: genre['name']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GenreButton extends StatelessWidget {
  final String genre;
  final String image;
  final VoidCallback onTap;

  const GenreButton({
    Key? key,
    required this.genre,
    required this.image,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: GridTile(
          footer: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            child: Text(
              genre,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'ComicSans', fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
