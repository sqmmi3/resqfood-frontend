import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/screens/add_item_screen.dart';
import 'package:frontend/screens/item_detail_screen.dart';
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

  void _addItem(Item newItem) {
    setState(() => items.add(newItem));
    MessageDialog.show(context, message: '${newItem.name} successfully added');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ResqfoodAppBar(),
      body: items.isEmpty
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
                      final itemName = item.name;
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailScreen(
                            item: item,
                            onUpdate: (updatedItem) => setState(() => items[index] = updatedItem),
                            onDelete: () {
                              setState(() => items.removeAt(index));
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) MessageDialog.show(context, message: '$itemName successfully deleted');
                              });
                            },
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
                          Text(item.expirationDate),
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
