import 'package:shared_preferences/shared_preferences.dart';
import 'package:watchstore/controllers/product_controller.dart';
import 'package:watchstore/models/data/product.dart';

class FavoriteManager {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  static const String _prefsKey = 'favorite_product_ids';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _prefsInstance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<String>> _getFavoriteIds() async {
    final prefs = await _prefsInstance;
    return prefs.getStringList(_prefsKey) ?? [];
  }

  Future<void> toggleFavorite(Product product) async {
    final prefs = await _prefsInstance;
    final ids = prefs.getStringList(_prefsKey) ?? [];
    final idStr = product.id.toString();

    if (ids.contains(idStr)) {
      ids.remove(idStr);
    } else {
      ids.add(idStr);
    }

    await prefs.setStringList(_prefsKey, ids);
  }

  Future<bool> isFavorite(Product product) async {
    final ids = await _getFavoriteIds();
    return ids.contains(product.id.toString());
  }

  Future<List<Product>> loadFavorites() async {
    final ids = await _getFavoriteIds();
    final controller = ProductController();

    final products = await Future.wait(
      ids.map((id) => controller.getProductById(int.parse(id))),
    );

    return products.whereType<Product>().toList();
  }
}
