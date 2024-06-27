import 'package:flutter/material.dart';



class CartProvider extends ChangeNotifier {

  List<Map<String, dynamic>> cartList = [];


  void addPet(Map<String, dynamic> breed) {
    // Check if the breed already exists in the cart
    bool alreadyExists = cartList.any((item) => item['id'] == breed['id']);

    if (!alreadyExists) {
      // Add the breed to the cart
      cartList.add(breed);
      notifyListeners(); // Notify listeners of change
    }
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