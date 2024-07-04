import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p_trade/pages/home_page.dart';
import 'package:p_trade/pages/login_page.dart';
import 'package:p_trade/pages/product_detail_page.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';
import 'package:p_trade/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:p_trade/widgets/multi_order_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:p_trade/widgets/shimmer_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? dataStream;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      setState(() {
        isLoading = true;
      });

      // Simulate delay to show CircularProgressIndicator
      await Future.delayed(Duration(seconds: 4));

      dataStream = db
          .collection('orders')
          .where('user_id', isEqualTo: user.uid)
          .orderBy('created_date', descending: true)
          .orderBy('created_time', descending: true)
          .snapshots();

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserData();
  }

  void _handleLogin() {
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          // Added to ensure scroll works with RefreshIndicator
          child: Center(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              child: user == null
                  ? _buildLoginWidget(context, _handleLogin)
                  : _buildProfileWidget(context, userProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginWidget(BuildContext context, Function() onLogin) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You are currently not logged in!'),
          SizedBox(height: 20),
          MyElevatedButton(
            label: 'Login',
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ))
                  .then((_) => onLogin());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileWidget(BuildContext context, UserProvider userProvider) {
    final user = userProvider.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage('assets/images/icons/user_avtar.png'),
          radius: 38,
        ),
        SizedBox(height: 8),
        Text(
          user?.displayName ?? 'User',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          user?.email ?? 'example@example.com',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        MyElevatedButton(
          label: 'Log Out',
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        Text(
          'My Orders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        _buildOrderList(),
      ],
    );
  }

  Widget _buildOrderList() {
    if (isLoading) {
      return OrderShimmerWidget();
    } else if (dataStream != null) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: dataStream!,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return OrderShimmerWidget();
          } else if (snapshot.hasError) {
            return OrderShimmerWidget();
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No previous orders.');
          }

          var sortedOrders = snapshot.data!.docs;
          sortedOrders.sort((a, b) {
            var dateA = a['created_date'];
            var dateB = b['created_date'];
            var timeA = a['created_time'];
            var timeB = b['created_time'];
            return '$dateB $timeB'.compareTo('$dateA $timeA');
          });

          return ListView.builder(
            itemCount: sortedOrders.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> order =
                  sortedOrders[index];
              var orderData = order.data();

              if (orderData == null) {
                return Text('Order data is missing.');
              }

              List<dynamic> items = orderData['items'] ?? [];

              if (items.isEmpty) {
                return Text('No items in this order.');
              }

              String createdDate = orderData['created_date'] ?? 'Unknown Date';
              String createdTime = orderData['created_time'] ?? 'Unknown Time';

              if (items.length == 1) {
                var item = items[0];
                String imageUrls = item['imageURL'][0] ?? '';

                return Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            breed: item,
                            orderData: orderData,
                            isFromProfile: true,
                          ),
                        ));
                      },
                      child: ListTile(
                        leading: imageUrls.isNotEmpty
                            ? Image.network(
                                imageUrls,
                                width: 70,
                                height: 70,
                                errorBuilder: (context, error, stackTrace) {
                                  return Shimmer.fromColors(
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                  );
                                },
                              )
                            : Shimmer.fromColors(
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                              ),
                        title:
                            Text('Breed: ${item['breed'] ?? 'Unknown Category'}'
                                ' \nPrice: \$${item['price'] ?? 'Unknown'} '
                                '\nAge: ${item['age']} '),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$createdDate'),
                            Text('$createdTime'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return MultiItemOrderCard(orderData: orderData, items: items);
              }
            },
          );
        },
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
