import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p_trade/pages/home_page.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';

class OrderConfirmationPage extends StatefulWidget {
  final Map<String, dynamic>? orderData;
  final List<Map<String, dynamic>>? orderCartItems;

  const OrderConfirmationPage({
    super.key,
    required this.orderData,
    required this.orderCartItems,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isOrderSummaryExpanded = false;
  bool _isUserInfoExpanded = false;

  void _copyToClipboard(String orderId) {
    try {
      Clipboard.setData(ClipboardData(text: orderId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order ID copied to clipboard')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to copy order ID')),
      );
      print('Failed to copy order ID: $e');
    }
  }

  Widget _buildExpandableOrderSummary() {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 1,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isOrderSummaryExpanded = !_isOrderSummaryExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text('Total items: ${widget.orderCartItems!.length}'),
              // subtitle: Text(
              //     'Price: \$${item?['price']} \nAge: ${item?['age']} years'),
            );
          },
          body: Column(
            children: widget.orderCartItems!.map((item) {
              return ListTile(
                title: Text('Breed: ${item['breed']}'),
                subtitle: Text('Price: ${item['price']} \n Age: ${item['age']} Year'),
              );
            }).toList(),
          ),
          isExpanded: _isOrderSummaryExpanded,
        ),
      ],
    );
  }

  Widget _buildExpandableUserInfo() {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 1,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isUserInfoExpanded = !_isUserInfoExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                'User Information',
                style: TextStyle(fontSize: 20),
              ),
            );
          },
          body: Column(
            children: [
              ListTile(
                title: Text('Name: ${widget.orderData?['name']}'),
              ),
              ListTile(
                title: Text('Mobile No: ${widget.orderData?['mobile']}'),
              ),
              ListTile(
                title: Text('Delivery Address: ${widget.orderData?['address']}'),
              ),
              ListTile(
                title: Text('City: ${widget.orderData?['city']}'),
              ),

            ],
          ),
          isExpanded: _isUserInfoExpanded,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.copy,
                        color: Colors.blue,
                      ),
                      onTap: () {
                        _copyToClipboard(widget.orderData!['order_id']);
                      },
                    ),
                    SizedBox(width: 10),
                    Text('Order Id: ${widget.orderData!['order_id']}'),
                  ],
                ),
                Divider(height: 20, thickness: 2),
                _buildExpandableOrderSummary(),
                Divider(height: 20, thickness: 2),
                _buildExpandableUserInfo(),
                SizedBox(height: 20),
                // Add some space before the bottom content
                Icon(
                  Icons.check_circle_outline,
                  size: 90,
                  color: Colors.green,
                ),
                SizedBox(height: 12),
                Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 2),
                Text(
                  widget.orderData?['name'],
                  style: TextStyle(fontSize: 28),
                ),
                SizedBox(height: 10),
                Text(
                  'Your order will be delivered within 3 to 5 working days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 30),
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
