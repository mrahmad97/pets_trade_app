import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String tag;
  final String breed;

  FullScreenImage({
    required this.imageUrls,
    required this.initialIndex,
    required this.tag,
    required this.breed,
  });

  @override
  Widget build(BuildContext context) {
    PageController _pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Center(
                child: Hero(
                  tag: '$tag-$index',
                  child: Image.network(
                    imageUrls[index],
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Text(
              breed,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
