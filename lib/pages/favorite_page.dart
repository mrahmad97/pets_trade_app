import 'package:flutter/material.dart';
import 'package:p_trade/pages/product_detail_page.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteBreeds = Provider.of<FavoriteProvider>(context);
    final favoriteList = favoriteBreeds.favoriteBreeds;
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Breeds'),
      ),
      body: favoriteList.isEmpty
          ? Center(
              child: Text('No favorite breeds yet.'),
            )
          : ListView.builder(
              itemCount: favoriteList.length,
              itemBuilder: (context, index) {
                final breed = favoriteList[index];
                return ListTile(
                  title: Text(breed['breed'].toString()),
                  subtitle: Text('\$ ${breed['price'].toString()}'),
                  leading: Hero(
                    tag: 'breed-image-${breed['id']}',
                    child: Image.asset(
                      breed['imageURL'][0],
                      height: 60,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductDetailPage(breed: breed),
                    ));
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () {
                      favoriteBreeds.toggleFavorite(context, breed);
                    },
                  ),
                );
              },
            ),
    );
  }
}
