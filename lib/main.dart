import 'package:flutter/material.dart';
import 'package:p_trade/cart_provider.dart';
import 'package:p_trade/favorite_provider.dart';
import 'package:p_trade/start_page.dart';
import 'package:p_trade/theme_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:p_trade/user_provider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => FavoriteProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => ThemeModel(ThemeData.from(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF2E8B57),
                background: Colors.white,
                primary: Color(0xFF2E8B57),
                primaryContainer: Color(0xFFC6EED8)),
          )),
        ),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeModel.themeData,
            home: StartPage(),
          );
        },
      ),
    );
  }
}
