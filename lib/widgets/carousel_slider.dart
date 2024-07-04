import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselSliderWidget extends StatefulWidget {
  final List<String> imageUrls; // List of image URLs
  final bool autoPlay;
  final int autoPlayInterval;
  final double imageHeight; // Custom image height
  final double imageWidth; // Custom image width

  const CarouselSliderWidget({
    required this.imageUrls,
    this.autoPlay = true,
    this.autoPlayInterval = 5000,
    this.imageHeight = 400.0,
    this.imageWidth = double.infinity,
  });

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: widget.imageHeight,
            aspectRatio: widget.imageWidth / widget.imageHeight,
            viewportFraction: 0.8,
            initialPage: _currentIndex,
            enableInfiniteScroll: true,
            autoPlay: widget.autoPlay,
            autoPlayInterval: Duration(milliseconds: widget.autoPlayInterval),
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Image.asset(
                  imageUrl,
                  fit: BoxFit.cover, // Adjust as needed
                  width: widget.imageWidth,
                  height: widget.imageHeight,
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
                (index) => buildDot(index),
          ),
        ),
      ],
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _currentIndex == index ? 12.0 : 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
    );
  }
}
