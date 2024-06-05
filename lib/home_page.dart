import 'package:flutter/material.dart';
import 'package:p_trade/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p_trade/cart_page.dart';
import 'package:p_trade/cart_provider.dart';
import 'package:p_trade/favorite_page.dart';
import 'package:p_trade/favorite_provider.dart';
import 'package:p_trade/product_detail_page.dart';
import 'package:p_trade/product_list_page.dart';
import 'package:p_trade/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isSearching = false;
  String _searchText = '';
  final List<Map<String, dynamic>> _searchedData = [];

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      _searchText = '';
      _searchedData.clear();
    });
  }

  Future<void> _search(String searchText) async {
    if (searchText.isNotEmpty) {
      final String searchKey = searchText.toLowerCase();
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('breeds')
          .where('breed', isGreaterThanOrEqualTo: searchKey)
          .where('breed', isLessThanOrEqualTo: searchKey + '\uf8ff')
          .get();

      setState(() {
        _searchedData.clear();
        for (var doc in result.docs) {
          _searchedData.add(doc.data() as Map<String, dynamic>);
        }
      });
    } else {
      setState(() {
        _searchedData.clear();
      });
    }
  }


  void _navigateToProductDetailPage(
      BuildContext context, Map<String, dynamic> breed) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(breed: breed),
      ),
    );
    if (result == 'back') {
      stopSearch();
      Navigator.popUntil(
          context, ModalRoute.withName(Navigator.defaultRouteName));
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final category = ['Dogs', 'Cats', 'Hens/Duck', 'Parrots', 'Others'];
  final categoryIcon = [
    'assets/images/icons/dog.png',
    'assets/images/icons/cat.png',
    'assets/images/icons/hen.png',
    'assets/images/icons/parrot.png',
    'assets/images/icons/other.png'
  ];

  final FirebaseFirestore db = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  _search(value);
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: InputBorder.none,
                ),
              )
            : Center(
                child: Text(
                  'PET TRADE',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
        leading: Builder(builder: (context) {
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu));
        }),
        actions: [
          IconButton(
            onPressed: () {
              if (isSearching) {
                stopSearch();
              } else {
                startSearch();
              }
            },
            icon: Icon(isSearching ? Icons.clear : Icons.search),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
              );
            },
            icon: Stack(
              children: [
                Container(
                  child: Icon(Icons.shopping_cart),
                ),
                Positioned(
                  bottom: 10,
                  left: 9,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        context
                            .watch<CartProvider>()
                            .cartList
                            .length
                            .toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      drawer: Drawer(
        child: Container(
          padding: EdgeInsets.zero,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                    ));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: UserAccountsDrawerHeader(
                          accountName: Text(
                            user?.displayName ?? 'User',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          accountEmail: Text(
                            user?.email ?? 'example@example.com',
                            style: TextStyle(color: Colors.black87),
                          ),
                          decoration: BoxDecoration(color: Colors.transparent),
                          currentAccountPicture: CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/icons/user_avtar.png'),
                          ),
                          currentAccountPictureSize: Size(35, 35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text('Favorite'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => FavoritePage(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Cart'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
                    ),
                  );
                },
              ),
              Divider(
                color: Colors.black87,
              ),
            ],
          ),
        ),
      ),
      body: isSearching
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView.builder(
                itemCount: _searchedData.length,
                itemBuilder: (context, index) {
                  final breed = _searchedData[index];
                  return GestureDetector(
                    onTap: () {
                      _navigateToProductDetailPage(context, breed);
                    },
                    child: buildCard(breed),
                  );
                },
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Image.asset(
                              "assets/images/ad_img/man and dog.png",
                              width: 200,
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Text(
                                "Pick up The Right Pet!",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Before buying the\n'
                                'pet, make sure that it\n'
                                'is the right one for\n'
                                'you!',
                                style: TextStyle(fontSize: 18),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: category.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProductListPage(
                                      category: category[index]),
                                ),
                              );
                            },
                            child: Container(
                              width: 95,
                              height: 95,
                              margin: EdgeInsets.fromLTRB(0, 0, 12, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    categoryIcon[index],
                                    width: 35,
                                    height: 35,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    category[index],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Take a Look',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: db.collection('breeds').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'An error occurred: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
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
                                var firstBreed = breeds[firstIndex].data()
                                    as Map<String, dynamic>;
                                var secondBreed = secondIndex < breeds.length
                                    ? breeds[secondIndex].data()
                                        as Map<String, dynamic>
                                    : null;

                                return Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductDetailPage(
                                                      breed: firstBreed),
                                            ),
                                          );
                                        },
                                        child: buildCard(firstBreed),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    // Add some space between cards
                                    secondBreed != null
                                        ? Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailPage(
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
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildCard(Map<String, dynamic> breed) {
    final favoriteBreeds = Provider.of<FavoriteProvider>(context);
    bool isFavorite = favoriteBreeds.favoriteBreeds
        .any((element) => element['id'] == breed['id']);
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
                  onPressed: () {
                    favoriteBreeds.toggleFavorite(context, breed);
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
