import 'package:flutter/material.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/items/manual_add_item_screen.dart';
import 'package:frontend/widgets/user_item/user_item_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isMenuOpen = false;

  void toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserItemProvider>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userItemProvider = context.watch<UserItemProvider>();

    return Scaffold(
      body: Stack(
        children: [
          userItemProvider.loading
            ? const Center(child: CircularProgressIndicator())
            : userItemProvider.items.isEmpty
              ? const Center(child: Text('No items found.'))
              : ListView.builder(
                itemCount: userItemProvider.items.length,
                itemBuilder: (context, index) {
                  final groupedItem = userItemProvider.items[index];
                  return UserItemBar(groupedItem: groupedItem);
                },
              ),
          
          if (_isMenuOpen)
            GestureDetector(
              onTap: toggleMenu,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isMenuOpen) _buildExpansionMenu(context),
          const SizedBox(height: 2),
          SizedBox(
            height: 60,
            width: 60,
            child: FloatingActionButton(
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              onPressed: toggleMenu,
              child: Icon(
                _isMenuOpen ? Icons.close : Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionMenu(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _menuItem("Barcode", () {
            // TODO
          }),
          const Divider(height: 1, color: Colors.black),
          _menuItem("Add Manually", () {
            toggleMenu();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ManualAddItemScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _menuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}