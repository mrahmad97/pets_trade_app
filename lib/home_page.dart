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
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> allBreeds;
  List<Map<String, dynamic>> filteredBreeds = [];
  bool isSearching = false;
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _fetchBreeds();
  }

  @override
  void dispose() {
    searchController.dispose();
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

  void _fetchBreeds() async {
    final snapshot = await db.collection('breeds').get();
    setState(() {
      allBreeds = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search breeds...',
                  hintStyle: TextStyle(color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      filteredBreeds.clear();
                    } else {
                      filteredBreeds = filteredSearchResults(value);
                    }
                  });
                },
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
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  filteredBreeds.clear();
                }
              });
            },
            icon: Icon(isSearching ? Icons.close : Icons.search),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isSearching
                  ? Center(
                      child: Text(
                        'Search Results',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                                        category: category[index],
                                      ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
              StreamBuilder<QuerySnapshot>(
                stream: db.collection('breeds').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('An error occurred: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No breeds found.'));
                  } else {
                    var breeds = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();
                    if (isSearching) {
                      breeds = filteredBreeds;
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: (breeds.length / 2).ceil(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        int firstIndex = index * 2;
                        int secondIndex = firstIndex + 1;
                        var firstBreed = breeds[firstIndex];
                        var secondBreed = secondIndex < breeds.length
                            ? breeds[secondIndex]
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
                },
              ),
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
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
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

  List<Map<String, dynamic>> filteredSearchResults(String query) {
    List<Map<String, dynamic>> searchResults = [];
    if (allBreeds.isNotEmpty) {
      searchResults = allBreeds.where((breed) {
        String breedName = breed['breed'].toString().toLowerCase();
        String category = breed['category'].toString().toLowerCase();
        return breedName.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase());
      }).toList();
    }
    return searchResults;
  }
}
