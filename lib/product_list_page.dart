import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/favorite_provider.dart';
import 'package:p_trade/product_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListPage extends StatefulWidget {
  final String category;

  const ProductListPage({required this.category, Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  ScrollController _scrollController = ScrollController();

  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String categoryFilter = widget.category.toLowerCase().replaceAll('s', '');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
            stream: db
                .collection('breeds')
                .where('category', isEqualTo: categoryFilter)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('An error occurred: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No breeds found.'));
              } else {
                var breeds = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: (breeds.length / 2).ceil(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    int firstIndex = index * 2;
                    int secondIndex = firstIndex + 1;
                    var firstBreed =
                        breeds[firstIndex].data() as Map<String, dynamic>;
                    var secondBreed = secondIndex < breeds.length
                        ? breeds[secondIndex].data() as Map<String, dynamic>
                        : null;

                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(breed: firstBreed),
                                ),
                              );
                            },
                            child: buildCard(firstBreed),
                          ),
                        ),
                        SizedBox(width: 8), // Add some space between cards
                        secondBreed != null
                            ? Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                            breed: secondBreed),
                                      ),
                                    );
                                  },
                                  child: buildCard(secondBreed),
                                ),
                              )
                            : SizedBox(),
                      ],
                    );
                  },
                );
              }
            }),
      ),
    );
  }

  Widget buildCard(Map<String, dynamic> breed) {
    final favoriteBreeds = Provider.of<FavoriteProvider>(context);
    bool isFavorite = favoriteBreeds.favoriteBreeds.any((element) => element['id'] == breed['id']);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Card(
        color: Theme.of(context).colorScheme.background,
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
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await favoriteBreeds.toggleFavorite(context, breed);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You need to log in first'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            Center(
              child: Hero(
                tag: 'breed-image-${breed['id']}',
                child: Image.asset(
                  breed['imageURL'][0],
                  height: MediaQuery.of(context).size.height * 1 / 5,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(12))),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    breed['breed'].toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$ ${breed['price'].toString()}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}