import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/screens/add_item_screen.dart';
import 'package:frontend/screens/item_detail_screen.dart';
import 'package:frontend/services/items/item_service.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:frontend/widgets/nav/resqfood_bottomnavbar.dart';
import 'package:frontend/widgets/message_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> items = [];
  late ItemService _itemService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _itemService = ItemService();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      setState(() => _isLoading = true);
      final fetchedItems = await _itemService.fetchAllItems();
      setState(() {
        items = fetchedItems;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        MessageDialog.show(context, message: 'Failed to load items: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _addItem(Item newItem) async {
    try {
      final createdItem = await _itemService.postItem(newItem);
      setState(() => items.add(createdItem));
      if (mounted) {
        MessageDialog.show(context, message: '${newItem.name} successfully added');
      }
    } catch (e) {
      if (mounted) {
        MessageDialog.show(context, message: 'Failed to add item: $e');
      }
    }
  }

  Future<void> _updateItem(int index, Item updatedItem) async {
    try {
      final itemId = items[index].id;
      if (itemId == null) throw Exception('Item ID is missing');
      final result = await _itemService.updateItem(itemId, updatedItem);
      setState(() => items[index] = result);
      if (mounted) {
        MessageDialog.show(context, message: 'Item successfully updated');
      }
    } catch (e) {
      if (mounted) {
        MessageDialog.show(context, message: 'Failed to update item: $e');
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    try {
      final itemId = items[index].id;
      if (itemId == null) throw Exception('Item ID is missing');
      final itemName = items[index].name;
      await _itemService.deleteItem(itemId);
      setState(() => items.removeAt(index));
      if (mounted) {
        MessageDialog.show(context, message: '$itemName successfully deleted');
      }
    } catch (e) {
      if (mounted) {
        MessageDialog.show(context, message: 'Failed to delete item: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ResqfoodAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No items yet', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('Tap the + button to add an item', style: TextStyle(fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                  onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(
                            item: item,
                            onUpdate: (updatedItem) => _updateItem(index, updatedItem),
                            onDelete: () => _deleteItem(index),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.name),
                          Text(item.expirationDate ?? '-'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () async {
            final newItem = await Navigator.push<Item>(
              context,
              MaterialPageRoute(builder: (context) => const AddItemScreen()),
            );
            if (mounted && newItem != null) _addItem(newItem);
          },
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: ResqfoodBottomNavBar(
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }
}
