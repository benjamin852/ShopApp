import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/widgets/products_grid.dart';
import 'package:shop_app/widgets/badge.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';

import 'package:shop_app/screens/cart_screen.dart';

enum FilterOptions {
  Favourites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavourites = false;
  var _isInit = true;
  var _isLoading = false;

  //no async await since no future returned
  void didChangeDependencies() {
    //check if running for first time
    if (_isInit) {
      setState(() => _isLoading = true);
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() => _isLoading = false);
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop App'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favourites) {
                  _showOnlyFavourites = true;
                } else {
                  _showOnlyFavourites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('only favourites'),
                value: FilterOptions.Favourites,
              ),
              PopupMenuItem(
                child: Text('show all'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            //automatically passed to ch
            //avoid uneccessary rebuild
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () =>
                  Navigator.of(context).pushNamed(CartScreen.routeName),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavourites),
    );
  }
}
