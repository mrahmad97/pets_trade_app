import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favoriteBreeds = [];

  List<Map<String, dynamic>> get favoriteBreeds => _favoriteBreeds;

  FavoriteProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favoritesString = prefs.getString('favoriteBreeds');
    if (favoritesString != null) {
      List<dynamic> favoriteList = jsonDecode(favoritesString);
      _favoriteBreeds = favoriteList.map((e) => e as Map<String, dynamic>).toList();
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(BuildContext context, Map<String, dynamic> breed) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_favoriteBreeds.any((element) => element['id'] == breed['id'])) {
      _favoriteBreeds.removeWhere((element) => element['id'] == breed['id']);
    } else {
      _favoriteBreeds.add(breed);
    }

    String encodedData = jsonEncode(_favoriteBreeds);
    await prefs.setString('favoriteBreeds', encodedData);

    notifyListeners();
  }
}
