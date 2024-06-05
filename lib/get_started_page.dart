import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:p_trade/home_page.dart';
import 'package:p_trade/login_page.dart';
import 'package:p_trade/my_elevated_button.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icons/app_logo.png',
                  width: MediaQuery.of(context).size.width * 10 / 40,
                  height: MediaQuery.of(context).size.width * 10 / 40,
                ),
                Image.asset(
                  "assets/images/ad_img/man dog wbg.png",
                  height: MediaQuery.of(context).size.height * 2 / 5,
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
