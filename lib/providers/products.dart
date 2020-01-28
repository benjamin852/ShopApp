import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop_app/providers/product.dart';
import 'package:shop_app/models/http_exception.dart';

class Products with ChangeNotifier {
  //not final as we replace with list from server

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((product) => product.isFavourite).toList();
  }

  Product findById(String id) {
    return items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://shop-app-a0242.firebaseio.com/products.json';
    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      responseData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavourite: productData['isFavourite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    const url = 'https://shop-app-a0242.firebaseio.com/products.json';
    try {
      //convert hard coded map to JSON
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavourite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      //throw makes error available in editProductScreen
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      final url = 'https://shop-app-a0242.firebaseio.com/products/$id.json';

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    }
  }

  // void deleteProduct(String id) {
  //   // _items.removeWhere((product) => product.id == id);
  //   final existingProductIndex =
  //       _items.indexWhere((product) => product.id == id);
  //   var existingProduct = _items[existingProductIndex];
  //   http.delete(url).then((response) {
  //     print(response.statusCode);
  //     if (response.statusCode >= 400) {}
  //     existingProduct = null;
  //   }).catchError((_) {
  //     _items.insert(existingProductIndex, existingProduct);
  //     notifyListeners();
  //   });
  //   items.removeAt(existingProductIndex);
  //   notifyListeners();
  // }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-app-a0242.firebaseio.com/products/$id';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
