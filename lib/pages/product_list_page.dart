import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/pages/product_detail_page.dart';
import 'package:p_trade/widgets/breed_cards.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                            child: BreedCard(breed:firstBreed),
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
                                  child: BreedCard(breed: secondBreed),
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


}