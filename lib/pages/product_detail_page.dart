import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/providers/cart_provider.dart';
import 'package:p_trade/widgets/full_screen_image.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';
import 'package:p_trade/widgets/shimmer_widget.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> breed;
  final Map<String, dynamic>? orderData;
  final bool isFromProfile;

  const ProductDetailPage({
    required this.breed,
    this.orderData,
    this.isFromProfile = false, // Default value is false
    super.key,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    // Check if the product is already in the cart
    bool alreadyExists = context
        .read<CartProvider>()
        .cartList
        .any((item) => item['id'] == widget.breed['id']);
    if (alreadyExists) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildDots() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.breed['imageURL'].length,
              (index) => Container(
            margin: EdgeInsets.all(5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade400,
            ),
          ),
        ),
      );
    }

    List<String> imageUrls = List<String>.from(widget.breed['imageURL']);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('Details')),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breed : ${widget.breed['breed']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Name : ${widget.breed['name']}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Price : \$ ${widget.breed['price']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 3 / 5,
                  child: Center(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (BuildContext context, int index) {
                        String imageUrl = imageUrls[index];
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(
                                    imageUrls: imageUrls,
                                    initialIndex: index,
                                    tag: 'breed-image-${widget.breed['id']}',
                                    breed: widget.breed['breed'],
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'breed-image-${widget.breed['id']}-$index',
                              child: Image.network(
                                imageUrl,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return ImageDetailShimmer();
                                  }
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return ImageDetailShimmer();
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildDots(),
                Text(
                  'Description :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDescriptionExpanded = !_isDescriptionExpanded;
                    });
                  },
                  child: Text(
                    _isDescriptionExpanded
                        ? widget.breed['description']
                        : widget.breed['description'].length > 100
                        ? widget.breed['description'].substring(0, 100) +
                        '...'
                        : widget.breed['description'],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Text(
                  'Health Status :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.breed['health_status'],
                  style: TextStyle(fontSize: 16),
                ),
                if (widget.isFromProfile) ...[
                  SizedBox(height: 20),
                  Text(
                    'Order Details:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Order Id: ${widget.orderData?['order_id'] ?? 'Unknown Time'}'),
                  Text('Order Time: ${widget.orderData?['created_time'] ?? 'Unknown Time'}'),
                  Text('Order Date: ${widget.orderData?['created_date'] ?? 'Unknown Date'}'),
                  Text('User Name: ${widget.orderData?['name'] ?? 'Unknown Name'}'),
                  Text('City: ${widget.orderData?['city'] ?? 'Unknown City'}'),
                  Text('Address: ${widget.orderData?['address'] ?? 'Unknown Address'}'),
                  Text('Phone Number: ${widget.orderData?['mobile'] ?? 'Unknown Phone Number'}'),
                  Text('Email: ${widget.orderData?['email'] ?? 'Unknown Email'}'),

                ],
                SizedBox(height: 20),
                if (!widget.isFromProfile)
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      bool alreadyExists = cartProvider.cartList
                          .any((item) => item['id'] == widget.breed['id']);
                      return Center(
                        child: AnimatedSwitcher(
                          duration: Duration(seconds: 1),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: alreadyExists
                              ? ElevatedButton(
                            key: ValueKey('AddedToCart'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    AlertDialog(
                                      title: Text('Already in Cart'),
                                      content: Text(
                                          'This breed is already in your cart.\n Do you want to remove from cart?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            cartProvider
                                                .removePet(widget.breed);
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Added to Cart',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          )
                              : MyElevatedButton(
                            key: ValueKey('BuyNow'),
                            label: 'Buy Now',
                            onPressed: () {
                              cartProvider.addPet(widget.breed);
                              setState(() {});
                            },
                          ),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
