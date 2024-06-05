import 'package:flutter/material.dart';
import 'package:p_trade/get_started_page.dart';
import 'package:p_trade/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    navigateToNextPage(context);
  }

  Future<void> navigateToNextPage(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      // First time launch, navigate to the Get Started page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GetStartedPage()),
      );
      // Set isFirstLaunch to false for future launches
      prefs.setBool('isFirstLaunch', false);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/app_logo.png',
                      width: MediaQuery.of(context).size.width * 16 / 40,
                      height: MediaQuery.of(context).size.width * 16 / 40,
                    ),
                    Text(
                      'P Trade',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: Offset(4.0, 4.0),
                              blurRadius: 8.0,
                              color: Colors.grey,
                            ),
                          ]),
                    ),
                    Text(
                      'Pets waiting for a new home!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CircularProgressIndicator(
                      color: Colors.black87,
                      valueColor: AlwaysStoppedAnimation(Colors.black87),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 30 / 100,
                ),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                        child: Image.asset(
                          'assets/images/icons/parrot---.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Image.asset(
                        'assets/images/icons/hen.png',
                        width: MediaQuery.of(context).size.width * 6 / 40,
                        height: MediaQuery.of(context).size.width * 6 / 40,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Image.asset(
                        'assets/images/icons/dog.png',
                        width: MediaQuery.of(context).size.width * 14 / 40,
                        height: MediaQuery.of(context).size.width * 14 / 40,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 10 / 40,
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/icons/cat.png',
                        width: MediaQuery.of(context).size.width * 9 / 40,
                        height: MediaQuery.of(context).size.width * 9 / 40,
                      ),
                      Image.asset(
                        'assets/images/icons/wall.png',
                        width: MediaQuery.of(context).size.width * 20 / 40,
                        height: MediaQuery.of(context).size.width * 20 / 40,
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
