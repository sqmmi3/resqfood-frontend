import 'package:flutter/material.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/services/user_item/user_item_service.dart';

class UserItemProvider extends ChangeNotifier {
  final UserItemService _serivce = UserItemService();

  List<GroupedUserItem> _items = [];
  List<GroupedUserItem> get items => _items;

  bool loading = false;

  Future<void> fetchItems() async {
    loading = true;
    notifyListeners();

    try {
      List<UserItem> rawItems = await _serivce.getUserItems();
      _items = _serivce.groupUserItems(rawItems);
    } catch (e) {
      debugPrint("Error fetching items: $e");
    }

    loading = false;
    notifyListeners();
  }
}