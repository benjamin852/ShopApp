import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import 'package:shop_app/screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  //need to pass context as param if stateless component
  Future<void> _refreshPorducuts(BuildContext context) async {
    await Provider.of<Products>(context).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'), //no rebuild
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add), //no rebuild
            onPressed: () =>
                Navigator.of(context).pushNamed(EditProductScreen.routeName),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshPorducuts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: productsData.items.length,
            // _ no context needed
            itemBuilder: (_, index) => Column(
              children: <Widget>[
                UserProductItem(
                  productsData.items[index].id,
                  productsData.items[index].title,
                  productsData.items[index].imageUrl,
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
