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
        leading: BackButton(),
        title: Text('Search'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StorySearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
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
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomCenter,
        child: Container(
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class StorySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the AppBar
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the AppBar
    return BackButton();
  }

  @override
  Widget buildResults(BuildContext context) {
    // Show some result based on the selection
    return StoriesDisplayScreen(genre: query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show when someone searches for something
    // Placeholder for suggestions, you can implement actual search suggestions here
    return ListView(
      children: query.isEmpty
          ? []
          : ListTile.divideTiles(
        context: context,
        tiles: [
          ListTile(
            title: Text('Suggestion 1 for "$query"'),
            onTap: () {
              query = 'Suggestion 1 for "$query"';
              showResults(context);
            },
          ),
          ListTile(
            title: Text('Suggestion 2 for "$query"'),
            onTap: () {
              query = 'Suggestion 2 for "$query"';
              showResults(context);
            },
          ),
          // Add more suggestions here
        ],
      ).toList(),
    );
  }
}
