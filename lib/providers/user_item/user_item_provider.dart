import 'package:flutter/material.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/services/user_item/user_item_service.dart';

class UserItemProvider extends ChangeNotifier {
  final UserItemService _service = UserItemService();

  List<GroupedUserItem> _items = [];
  List<GroupedUserItem> get items => _items;

  bool loading = false;

  Future<void> fetchItems() async {
    loading = true;
    notifyListeners();

    try {
      List<UserItem> rawItems = await _service.getUserItems();
      _items = _service.groupUserItems(rawItems);
    } catch (e) {
      debugPrint("Error fetching items: $e");
    }

    if (hasListeners) {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> saveBatch(List<UserItem> itemsToSave) async {
    loading = true;
    notifyListeners();

    try {
      await _service.saveUserItemBatch(itemsToSave);
      await fetchItems();
    } catch (e) {
      debugPrint("Error saving batch: $e");
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInstance(int id) async {
    loading = true;
    notifyListeners();

    try {
      await _service.deleteUserItem(id);
      await fetchItems();
    } catch (e) {
      debugPrint("Error deleting instance: $e");
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void reset() {
  _items = [];
  loading = false;
  notifyListeners();
}
}