import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_trade/cart_provider.dart';
import 'package:p_trade/my_elevated_button.dart';
import 'package:p_trade/order_confirmation_page.dart';
import 'package:p_trade/cities_data.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {


  String? selectedCity;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    fetchUserName();
  }

  Future<void> fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        setState(() {
          emailController.text = userEmail;
        });
      }
    }
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userName = user.displayName;
      if (userName != null) {
        setState(() {
          nameController.text = userName;
        });
      }
    }
  }

  final now = DateTime.now();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('HH:mm:ss');

  Future<void> saveOrderDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in scenario
      return;
    }

    final orderData = {
      'user_id': user.uid,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'mobile': mobileController.text.trim(),
      'city': selectedCity,
      'address': addressController.text.trim(),
      'created_date': dateFormat.format(now),
      'created_time': timeFormat.format(now),
      'items': widget.cartItems, // Save cart items
    };

    await FirebaseFirestore.instance.collection('orders').add(orderData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: nameController,
                  // validator: (value) {
                  //   if (value == null || value
                  //       .trim()
                  //       .isEmpty) {
                  //     return "Please Enter Your Name";
                  //   } else {
                  //     return null;
                  //   }
                  // },
                  decoration: InputDecoration(
                    label: Text('Full Name'),
                    hintText: 'Enter Your Full Name',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    floatingLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    icon: Icon(Icons.person_2_outlined),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: mobileController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Please Enter Phone Number"
                      : null,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: Text('Mobile Number'),
                    hintText: 'Enter Your Phone Number',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    floatingLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    icon: Icon(Icons.phone_android_outlined),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  readOnly: true, // Set email field as read-only
                  controller: emailController,
                  decoration: InputDecoration(
                    label: Text('Email Address'),
                    hintText: 'Loading...',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    floatingLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    icon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    label: Text('City'),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    floatingLabelStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    icon: Icon(Icons.location_city_outlined),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Select City" : null,
                  isExpanded: true,
                  value: selectedCity,
                  hint: Text('Select City'),
                  items: cities
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        selectedCity = value;
                      }
                    });
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Enter address"
                      : null,
                  controller: addressController,
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    label: Text('Address'),
                    hintText:
                        'Colony XYZ, Block ABC, Street No x, House No XYZ',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    floatingLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    icon: Icon(Icons.pin_drop_outlined),
                  ),
                ),
                SizedBox(height: 20),
                Text('Order Summary',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = widget.cartItems[index];
                    return ListTile(
                      title: Text(item['breed']),
                      subtitle: Text(
                          'Price: \$${item['price']} \nAge: ${item['age']} years'),
                    );
                  },
                ),
                SizedBox(height: 50),
                MyElevatedButton(
                  label: 'Place Order',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await saveOrderDetails();

                      String name = nameController.text.trim();
                      String address = addressController.text.trim();
                      String mobile = mobileController.text.trim();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrderConfirmationPage(
                            name: name,
                            mobile: mobile,
                            city: selectedCity!,
                            address: address,
                          ),
                        ),
                      );
                      context.read<CartProvider>().clearCart();

                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
