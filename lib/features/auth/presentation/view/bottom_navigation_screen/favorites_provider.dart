import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favoriteGuitars = [];

  List<Map<String, dynamic>> get favoriteGuitars =>
      List.unmodifiable(_favoriteGuitars);

  void addFavorite(Map<String, dynamic> guitar) {
    if (!_favoriteGuitars.any((g) => g['id'] == guitar['id'])) {
      _favoriteGuitars.add(guitar);
      notifyListeners();
    }
  }

  void removeFavorite(String guitarId) {
    _favoriteGuitars.removeWhere((g) => g['id'] == guitarId);
    notifyListeners();
  }

  bool isFavorite(String guitarId) {
    return _favoriteGuitars.any((g) => g['id'] == guitarId);
  }
}
