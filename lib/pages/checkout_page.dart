import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p_trade/data/cities_data.dart';
import 'package:p_trade/pages/order_confirmation_page.dart';
import 'package:p_trade/providers/cart_provider.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final String? selectedCity;
  final String? currentAddress;

  const CheckoutPage({
    Key? key,
    required this.cartItems,
    required this.selectedCity,
    required this.currentAddress,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  List<Map<String, dynamic>> orderCartItems = []; // Add this line
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    _addressController = TextEditingController(text: widget.currentAddress);
    _cityController = TextEditingController(text: widget.selectedCity);
    orderCartItems.addAll(widget.cartItems);
    _loadPhoneNumber();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }
  Future<void> _loadPhoneNumber() async {
    String? phoneNumber = await getPhoneNumber();
    if (phoneNumber != null) {
      phoneController.text = phoneNumber;
    }
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPhoneNumber', phoneNumber);
  }

  Future<String?> getPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPhoneNumber');
  }


  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      emailController.text = user.email ?? '';
      nameController.text = user.displayName ?? '';
    }
  }

  final now = DateTime.now();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('HH:mm:ss');

  Future<Map<String, dynamic>?> saveOrderDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle user not logged in scenario
      return null;
    }
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection('orders');

    // Generate a new document reference for the order
    DocumentReference newOrderRef = ordersRef.doc();

    // Get the newly generated document ID
    String orderId = newOrderRef.id;

    final orderData = {
      'user_id': user.uid,
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'mobile': phoneController.text.trim(),
      'city': _cityController.text.trim(),
      'address': _addressController.text.trim(),
      'created_date': dateFormat.format(now),
      'created_time': timeFormat.format(now),
      'items': widget.cartItems, // Save cart items
      'order_id': orderId,
    };

    // Save order data to Firestore
    await newOrderRef.set(orderData);

    return orderData;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter an email";
    }
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegExp.hasMatch(value)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter a phone number";
    }
    final RegExp phoneRegExp = RegExp(
      r"^(?:\+92|0)?3[0-9]{2}[0-9]{7}$",
    );
    if (!phoneRegExp.hasMatch(value)) {
      return "Please enter a valid Pakistani phone number";
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your full name";
    }
    final RegExp nameRegExp = RegExp(
      r"^[a-zA-Z\s]+$",
    );
    if (!nameRegExp.hasMatch(value)) {
      return "Name can only contain letters and spaces";
    }
    return null;
  }

  String? findMatchingCity(String? selectedCity, List<String> cities) {
    if (selectedCity == null || selectedCity.isEmpty) {
      return null;
    }

    // Normalize the selected city by removing spaces and converting to lowercase
    final normalizedSelectedCity =
        selectedCity.replaceAll(' ', '').toLowerCase();

    // Find a city in the list that matches approximately
    for (String city in cities) {
      final normalizedCity = city.replaceAll(' ', '').toLowerCase();
      if (normalizedCity == normalizedSelectedCity) {
        return city;
      }
    }

    return null; // Return null if no approximate match is found
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  keyboardType: TextInputType.name,
                  controller: nameController,
                  validator: validateFullName,
                  decoration: InputDecoration(
                    label: Text('Full Name'),
                    hintText: 'Enter Your Full Name',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    icon: Icon(Icons.person_2_outlined),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  validator: validatePhoneNumber,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: Text('Mobile Number'),
                    hintText: 'Enter Your Phone Number',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    icon: Icon(Icons.phone_android_outlined),
                  ),
                ),
                SizedBox(height: 12),
                TextFormField(
                  readOnly: true, // Set email field as read-only
                  controller: emailController,
                  validator: validateEmail,
                  decoration: InputDecoration(
                    label: Text('Email Address'),
                    hintText: 'Loading...',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    icon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'City',
                    icon: Icon(Icons.location_city_outlined),
                  ),
                  value: findMatchingCity(widget.selectedCity, cities),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Select City'),
                    ),
                    ...cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _cityController.text = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a city';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Enter address"
                      : null,
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    label: Text('Address'),
                    hintText:
                        'Colony XYZ, Block ABC, Street No x, House No XYZ',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    icon: Icon(Icons.pin_drop_outlined),
                  ),
                ),
                SizedBox(height: 20),
                Text('Order Summary',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                SizedBox(height: 50),
                Center(
                  child: isLoading
                      ? CircularProgressIndicator.adaptive()
                      : MyElevatedButton(
                          label: 'Place Order',
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              final orderData = await saveOrderDetails();
                              await savePhoneNumber(phoneController.text);

                              setState(() {
                                isLoading = false;
                              });

                              if (orderData != null) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => OrderConfirmationPage(
                                      orderData: orderData,
                                      orderCartItems: orderCartItems,
                                    ),
                                  ),
                                );

                                // Clear the cart
                                context.read<CartProvider>().clearCart();
                              }
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
