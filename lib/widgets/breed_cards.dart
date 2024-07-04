import 'package:flutter/material.dart';
import 'package:p_trade/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BreedCard extends StatefulWidget {
  final Map<String, dynamic> breed;

  const BreedCard({Key? key, required this.breed}) : super(key: key);

  @override
  _BreedCardState createState() => _BreedCardState();
}

class _BreedCardState extends State<BreedCard> {
  bool isImageLoading = true;

  @override
  Widget build(BuildContext context) {
    final favoriteBreeds = Provider.of<FavoriteProvider>(context);
    bool isFavorite = favoriteBreeds.favoriteBreeds
        .any((element) => element['id'] == widget.breed['id']);
    List<String> imageUrls = List<String>.from(widget.breed['imageURL']);

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Stack(
        children: [
          _buildLoadedCard(context, isFavorite, imageUrls),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: MediaQuery.of(context).size.height *
            1 /
            5, // Adjust height to cover image and icon
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoadedCard(
      BuildContext context, bool isFavorite, List<String> imageUrls) {
    final favoriteBreeds = Provider.of<FavoriteProvider>(context);

    return Card(
      elevation: 4,
      shadowColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  favoriteBreeds.toggleFavorite(context, widget.breed);
                },
              ),
            ],
          ),
          Center(
            child: Hero(
              tag: 'breed-image-${widget.breed['id']}',
              child: Stack(
                children: [
                  Image.network(
                    imageUrls[0],
                    height: MediaQuery.of(context).size.height * 1 / 5,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          if (mounted) {
                            // Check if the widget is still mounted
                            setState(() {
                              isImageLoading = false;
                            });
                          }
                        });
                        return child;
                      } else {
                        return _buildShimmerCard(context);
                      }
                    },
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        if (mounted) {
                          // Check if the widget is still mounted
                          setState(() {
                            isImageLoading = false;
                          });
                        }
                      });
                      return _buildShimmerCard(
                          context); // Placeholder for error case
                    },
                  ),
                  if (isImageLoading) _buildShimmerCard(context),
                  // Show shimmer while loading
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.breed['breed'].toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$ ${widget.breed['price'].toString()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
