import 'package:flutter/material.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/widgets/user_item/user_item_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: userItemProvider.loading
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
    );
  }
}