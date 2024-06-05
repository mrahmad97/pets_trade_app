import 'package:flutter/material.dart';



class CartProvider extends ChangeNotifier {

  List<Map<String, dynamic>> cartList = [];


  void addPet(Map<String, dynamic> product) {
    cartList.add(product);
    notifyListeners();
  }

  void removePet(Map<String, dynamic> product) {
    cartList.remove(product);
    notifyListeners();
  }

  void clearCart() {
    cartList.clear();
    notifyListeners();
  }
}