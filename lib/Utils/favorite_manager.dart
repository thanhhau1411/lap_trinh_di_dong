import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchstore/models/data/product.dart';

class FavoriteManager {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  static const String _prefsKey = 'favorite_products';

  Future<void> loadFavorites(List<Product> allProducts) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_prefsKey) ?? [];
    _favorites = allProducts
        .where((product) => favoriteIds.contains(product.id))
        .toList();
  }

  Future<void> toggleFavorite(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favorites.any((p) => p.id == product.id)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }

    final ids = _favorites.map((p) => p.id!.toString()).toList();
    await prefs.setStringList(_prefsKey, ids);
  }

  bool isFavorite(Product product) {
    return _favorites.any((p) => p.id == product.id);
  }
}
