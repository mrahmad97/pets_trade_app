import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  ThemeData _themeData;

  ThemeModel(this._themeData);

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
