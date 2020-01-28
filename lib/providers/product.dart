import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite; //not final because changeable after creation of product

  //named
  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  void setFavouriteValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  void toggleFavouriteStatus() async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url = 'https://shop-app-a0242.firebaseio.com/products/$id.json';
    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavourite': isFavourite,
        }),
      );
      if (response.statusCode >= 400) {
        setFavouriteValue(oldStatus);
      }
    } catch (error) {
      setFavouriteValue(oldStatus);
    }
  }
}
