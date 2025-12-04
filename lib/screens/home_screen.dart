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
  static const _bottomNavPadding = EdgeInsets.only(bottom: 70);
  static const _itemListPadding = EdgeInsets.all(16);
  static const _itemCardPadding = EdgeInsets.only(bottom: 12);

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

  Future<void> _addItem(Item newItem) async {
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

  void _navigateToItemDetail(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          item: items[index],
          onUpdate: (updatedItem) => _updateItem(index, updatedItem),
          onDelete: () => _deleteItem(index),
        ),
      ),
    );
  }

  Future<void> _navigateToAddItem() async {
    final newItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );
    if (mounted && newItem != null) _addItem(newItem);
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No items yet', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Text('Tap the + button to add an item', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item, int index) {
    return Padding(
      padding: _itemCardPadding,
      child: GestureDetector(
        onTap: () => _navigateToItemDetail(index),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(item.expirationDate ?? '-', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      padding: _itemListPadding,
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildItemCard(items[index], index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ResqfoodAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? _buildEmptyState()
          : _buildItemsList(),
      floatingActionButton: Padding(
        padding: _bottomNavPadding,
        child: FloatingActionButton(
          onPressed: _navigateToAddItem,
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
