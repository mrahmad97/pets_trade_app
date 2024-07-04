import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:p_trade/pages/home_page.dart';
import 'package:p_trade/widgets/carousel_slider.dart';
import 'package:p_trade/widgets/my_elevated_button.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final List<String> carouselItem = [
    'assets/images/ad_img/man dog wbg.png',
    'assets/images/ad_img/man and dog.png',
    'assets/images/ad_img/man and dog.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CarouselSliderWidget(
                  imageUrls: carouselItem,
                  imageHeight: 400,
                  autoPlay: true,
                  imageWidth: MediaQuery.of(context).size.width,
                ),
                Text(
                  "Seek, Discover, Adore",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary),
                ),
                Text(
                  "Your New Pet Awaits to Bring\n Happiness into Your Life.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                MyElevatedButton(
                  label: 'Get Started',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
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
