import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/home_page.dart';
import 'package:p_trade/login_page.dart';
import 'package:p_trade/my_elevated_button.dart';
import 'package:p_trade/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? dataStream;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      dataStream = db
          .collection('orders')
          .where('user_id', isEqualTo: user.uid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: user == null
                ? _buildLoginWidget(context)
                : _buildProfileWidget(context, userProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('You are currently not logged in!'),
          SizedBox(height: 20),
          MyElevatedButton(
            label: 'Login',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoginPage(),
              ));
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
    if (dataStream != null) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: dataStream!,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator.adaptive();
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No previous orders.');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              DocumentSnapshot<Map<String, dynamic>> order =
                  snapshot.data!.docs[index];
              var orderData = order.data();

              if (orderData == null) {
                return Text('Order data is missing.');
              }

              List<dynamic> items = orderData['items'] ?? [];

              if (items.isEmpty) {
                return Text('No items in this order.');
              }

              return Column(
                children: items.map<Widget>((item) {
                  String imageUrls = item['imageURL'][0] ?? '';
                  String createdDate =
                      orderData['created_date'] ?? 'Unknown Date';
                  String createdTime =
                      orderData['created_time'] ?? 'Unknown Time';

                  return Container(
                    margin: EdgeInsets.all(0),
                    child: Card(
                      color: Theme.of(context).colorScheme.background,
                      elevation: 4,
                      child: ListTile(
                        leading: imageUrls.isNotEmpty
                            ? Image.network(
                                imageUrls,
                                width: 70,
                                height: 70,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    imageUrls,
                                    width: 70,
                                    height: 70,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/default_image.png',
                                width: 70,
                                height: 70,
                              ),
                        title: Text(
                          item['name'] ?? 'Unknown Name',
                        ),
                        subtitle: Text(
                            'Breed: ${item['breed'] ?? 'Unknown Category'} \nPrice: \$${item['price'] ?? 'Unknown'} \nAge: ${item['age']} '),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Date: $createdDate'),
                            Text('Time: $createdTime'),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
