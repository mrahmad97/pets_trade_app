import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:p_trade/cart_provider.dart';
import 'package:p_trade/my_elevated_button.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> breed;

  const ProductDetailPage({required this.breed, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

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
          ));
    }

    return Scaffold(
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
                      itemCount: widget.breed['imageURL'].length,
                      itemBuilder: (BuildContext context, int index) {
                        String imageUrl = widget.breed['imageURL'][index];
                        return Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Hero(
                            tag: 'breed-image-${widget.breed['id']}',
                            child: Image.asset(
                              imageUrl,
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
                Text(
                  widget.breed['description'],
                  style: TextStyle(fontSize: 16),
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
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: MyElevatedButton(
                    label: 'Buy Now',
                    onPressed: () {
                      context.read<CartProvider>().addPet(widget.breed);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
