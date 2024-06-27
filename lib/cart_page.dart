import 'package:flutter/material.dart';
import 'package:p_trade/cart_provider.dart';
import 'package:p_trade/checkout_page.dart';
import 'package:p_trade/login_page.dart';
import 'package:p_trade/my_elevated_button.dart';
import 'package:p_trade/user_provider.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: context.watch<CartProvider>().cartList.isEmpty
            ? []
            : [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        surfaceTintColor: Colors.transparent,
                        title: Text('Confirmation'),
                        content: Text('Do you Want to clear cart?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.black87),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<CartProvider>().clearCart();
                            },
                            child: Text('Yes'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.blue),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Clear Cart',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
      ),
      body: context.watch<CartProvider>().cartList.isEmpty
          ? Center(
              child: Text('Cart is Empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: context.watch<CartProvider>().cartList.length,
                    itemBuilder: (context, index) {
                      final product =
                          context.watch<CartProvider>().cartList[index];

                      return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          context.read<CartProvider>().removePet(product);
                        },
                        background: Container(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                              child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ),
                        confirmDismiss: (direction) {
                          return showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              surfaceTintColor: Colors.transparent,
                              title: Text('Confirmation'),
                              content: Text(
                                  'Do you Want to remove this pet from cart?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('No'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.black87),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context
                                        .read<CartProvider>()
                                        .removePet(product);
                                  },
                                  child: Text('Yes'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                          child: Card(
                            color: Theme.of(context).colorScheme.background,
                            elevation: 4,
                            child: ListTile(
                              leading: Image.asset(
                                product['imageURL'][0],
                                width: 70,
                                height: 70,
                              ),
                              title: Text(
                                product['breed'],
                              ),
                              subtitle: Text('Price: \$ ${product['price']} '
                                  '\n Age: ${product['age']} years'),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      surfaceTintColor: Colors.transparent,
                                      title: Text('Confirmation'),
                                      content: Text(
                                          'Do you Want to remove this pet from cart?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('No'),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.black87),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            context
                                                .read<CartProvider>()
                                                .removePet(product);
                                          },
                                          child: Text('Yes'),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.blue),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Total: \$${getTotalBill().toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        MyElevatedButton(
                          label: 'Proceed To Checkout',
                          onPressed: () async {
                            if (user == null) {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ));

                              if (user != null) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    cartItems:
                                        context.read<CartProvider>().cartList,
                                  ),
                                ));
                              }
                            } else {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  cartItems: context.read<CartProvider>().cartList,
                                ),
                              ));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  double getTotalBill() {
    double total = 0;
    final cartList = context.read<CartProvider>().cartList;
    for (var element in cartList) {
      total = total + double.parse(element['price'].toString());
    }
    return total;
  }
}
