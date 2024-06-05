import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/home_page.dart';
import 'package:p_trade/login_page.dart';
import 'package:p_trade/my_elevated_button.dart';
import 'package:p_trade/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? dataStream;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null) {
      dataStream = db.collection('orders')
          .where('user_id', isEqualTo: user.uid)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          child: user == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are currently not Logged in!'),
              SizedBox(
                height: 20,
              ),
              MyElevatedButton(
                label: 'Login',
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ));
                },
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage:
                AssetImage('assets/images/icons/user_avtar.png'),
                radius: 38,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                user.displayName ?? 'User',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                user.email ?? 'example@example.com',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 6,
              ),
              MyElevatedButton(
                label: 'Log Out',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'My Orders',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (dataStream != null)
                StreamBuilder(
                  stream: dataStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator.adaptive();
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Text('No previous orders.');
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DocumentSnapshot order =
                        snapshot.data!.docs[index];
                        return Container(
                          child: Text(order.id),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
