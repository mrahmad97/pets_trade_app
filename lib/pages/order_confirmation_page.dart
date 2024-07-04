import 'package:flutter/material.dart';
import 'package:p_trade/pages/home_page.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Map<String, dynamic>? orderData;

  const OrderConfirmationPage({
    super.key,
    required this.orderData,
  });

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
                  widget.orderData?['name'],
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Your order will be delivered within 3 to 5 '
                  'working days to city: ${widget.orderData?['city']} at'
                  ' address: ${widget.orderData?['address']}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 30,
                ),
                MyElevatedButton(
                  label: 'Go To Home Page',
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => HomePage(),
                        ),
                        (route) => false);
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
