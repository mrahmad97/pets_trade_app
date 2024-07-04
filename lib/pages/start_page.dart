import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:p_trade/pages/get_started_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  late List<ConnectivityResult> _connectivityResult;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    _connectivityResult = [];
    checkConnectivity();
    navigateToNextPage(context);
  }

  Future<void> checkConnectivity() async {
    List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      result = [ConnectivityResult.none];
    }

    setState(() {
      _connectivityResult = result;
    });

    if (_connectivityResult.contains(ConnectivityResult.none)) {
      showSnackbar();
    }
  }

  void showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Expanded(child: Text('Check your internet connection and Try Again')),
        duration: Duration(seconds: 10),
      ),
    );
  }

  Future<void> navigateToNextPage(BuildContext context) async {
    // Capture context synchronously
    final capturedContext = context;

    await Future.delayed(Duration(seconds: 5));

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    // if (isFirstLaunch) {
    //   // First time launch, navigate to the Get Started page
    Navigator.pushReplacement(
      capturedContext,
      MaterialPageRoute(
        builder: (context) => GetStartedPage(),
      ),
    );
    // Set isFirstLaunch to false for future launches
    //   prefs.setBool('isFirstLaunch', false);
    // } else {
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(
    //     builder: (context) => HomePage(),
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                        ],
                      ),
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
