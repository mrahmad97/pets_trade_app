import 'package:flutter/material.dart';
import 'package:p_trade/pages/product_detail_page.dart';

class MultiItemOrderCard extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final List<dynamic> items;

  const MultiItemOrderCard({
    required this.orderData,
    required this.items,
  });

  @override
  _MultiItemOrderCardState createState() => _MultiItemOrderCardState();
}

class _MultiItemOrderCardState extends State<MultiItemOrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String createdDate = widget.orderData['created_date'] ?? 'Unknown Date';
    String createdTime = widget.orderData['created_time'] ?? 'Unknown Time';

    return Card(
      color: Theme.of(context).colorScheme.background,
      elevation: 4,
      child: ExpansionTile(
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        title: Text(_isExpanded
            ? '${widget.items.length} items'
            : 'Order contains ${widget.items.length} items'),
        subtitle: _isExpanded
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Date: $createdDate'),
                  Text('Time: $createdTime'),
                ],
              ),
        children: widget.items.map<Widget>((item) {
          String imageUrls = item['imageURL'][0] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProductDetailPage(breed: item,orderData: widget.orderData,isFromProfile: true,),
              ));
            },
            child: ListTile(
              leading: imageUrls.isNotEmpty
                  ? Image.network(
                      imageUrls,
                      width: 70,
                      height: 70,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          imageUrls,
                          width: 70,
                          height: 70,
                        );
                      },
                    )
                  : Image.asset(
                      imageUrls,
                      width: 70,
                      height: 70,
                    ),
              title: Text(
                item['name'] ?? 'Unknown Name',
              ),
              subtitle: Text(
                  'Breed: ${item['breed'] ?? 'Unknown Category'} \nPrice: \$${item['price'] ?? 'Unknown'} \nAge: ${item['age']} '),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Date: $createdDate'),
                  Text('Time: $createdTime'),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
