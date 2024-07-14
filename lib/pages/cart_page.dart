import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:p_trade/pages/checkout_page.dart';
import 'package:p_trade/pages/login_page.dart';
import 'package:p_trade/pages/product_detail_page.dart';
import 'package:p_trade/providers/cart_provider.dart';
import 'package:p_trade/providers/user_provider.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String? selectedCity;
  String? currentAddress;
  bool isLocationFetched = false;
  bool isLoading = false;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      await _getAddressFromLatLng(position);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching location: $e'),
        ),
      );
      setState(() {
        isLocationFetched = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          currentAddress =
              "${placemark.name ?? placemark.locality}, ${placemark.locality}";
          selectedCity = placemark.locality;
          isLocationFetched = true;
        });
      } else {
        throw 'No placemarks found';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching address: $e'),
        ),
      );
      setState(() {
        isLocationFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: cartProvider.cartList.isEmpty
            ? []
            : [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirmation'),
                        content: Text('Do you want to clear cart?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                            ),
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<CartProvider>().clearCart();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                            child: Text('Yes'),
                          )
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
      body: cartProvider.cartList.isEmpty
          ? Center(
              child: Text('Cart is Empty'),
            )
          : Column(
              children: [
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return ListView.builder(
                        itemCount: cartProvider.cartList.length,
                        itemBuilder: (context, index) {
                          final product = cartProvider.cartList[index];

                          return Dismissible(
                            key: Key(product['id'].toString()),
                            onDismissed: (direction) {
                              context.read<CartProvider>().removePet(product);
                            },
                            background: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              color: Colors.red,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirmation'),
                                  content: Text(
                                      'Do you want to remove this item from cart?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                      ),
                                      child: Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                      ),
                                      child: Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(breed: product),
                                ));
                              },
                              child: ListTile(
                                leading: Image.network(
                                  product['imageURL'][0],
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
                                ),
                                title: Text(product['breed']),
                                subtitle: Text(
                                    'Price: \$${product['price']} \n Age: ${product['age']} years'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Confirmation'),
                                        content: Text(
                                            'Do you want to remove this item from cart?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black87,
                                            ),
                                            child: Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              context
                                                  .read<CartProvider>()
                                                  .removePet(product);
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.blue,
                                            ),
                                            child: Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: \$${getTotalBill(cartProvider.cartList).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        MyElevatedButton(
                          label:
                              isLoading ? 'Loading...' : 'Proceed To Checkout',
                          onPressed: () async {
                            setState(() {
                              isLoading =
                                  true; // Set isLoading to true when starting async operations
                            });

                            // Perform async operation to determine position
                            await _determinePosition();


                            if (user == null) {
                              // Navigate to LoginPage
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(),
                                ),
                              );

                              // Check if the widget is still mounted before proceeding
                              if (!mounted) {
                                return; // Exit early if the widget is not mounted
                              }
                            }

                            // Check if user is logged in after navigation
                            if (context.read<UserProvider>().user != null) {
                              // User is logged in, navigate to CheckoutPage if location is fetched
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                    cartItems: cartProvider.cartList,
                                    selectedCity: selectedCity,
                                    currentAddress: currentAddress,
                                  ),
                                ),
                              );
                            }

                            // After completing async operations, set isLoading back to false
                            setState(() {
                              isLoading = false;
                            });
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

  double getTotalBill(List<Map<String, dynamic>> cartItems) {
    double totalBill = 0.0;
    for (var product in cartItems) {
      totalBill += product['price'];
    }
    return totalBill;
  }
}
