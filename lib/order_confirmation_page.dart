import 'package:flutter/material.dart';
import 'package:p_trade/cart_provider.dart';
import 'package:p_trade/home_page.dart';
import 'package:p_trade/my_elevated_button.dart';
import 'package:provider/provider.dart';


class OrderConfirmationPage extends StatefulWidget {

  final String name;
  final String mobile;
  final String city;
  final String address;

  const OrderConfirmationPage({super.key,required this.name,
    required this.mobile,
    required this.city,
    required this.address,});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 90,
                  color: Colors.green,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  widget.name,
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your order will be delivered within 3 to 5 '
                      'working days to city: ${widget.city} at'
                      ' address: ${widget.address}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                MyElevatedButton(label: 'Go To Home Page', onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePage(),), (
                      route) => false);
                },)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
