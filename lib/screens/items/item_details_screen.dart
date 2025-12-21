import 'package:flutter/material.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:frontend/widgets/user_item/user_item_detail_card.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatelessWidget {
  final String itemName;

  const ItemDetailsScreen({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    final userItemProvider = context.watch<UserItemProvider>();

    final groupedItem = userItemProvider.items.firstWhere(
      (element) => element.itemName == itemName,
      orElse: () => GroupedUserItem(
        itemName: itemName,
        type: '',
        amount: 0,
        earliestExpiration: DateTime.now(),
        allInstances: [],
      ),
    );

    if (groupedItem.allInstances.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pop(context));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: ResQFoodAppBar(
        onMenuTap: () {
          
        },
        onNotificationTap: () {

        },
        onUserTap: () {
          
        },
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: TextButton.icon(
                onPressed: () => {Navigator.pop(context)},
                icon: const Icon(Icons.arrow_back, color: Colors.black,),
                label: const Text("Go back", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupedItem.itemName,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _buildCommonField("Name", groupedItem.itemName),
                _buildCommonField("Category", groupedItem.type),
                _buildCommonField("Quantity", groupedItem.amount.toString()),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedItem.allInstances.length,
              itemBuilder: (context, index) {
                final item = groupedItem.allInstances[index];
                return UserItemDetailCard(
                  userItem: item,
                  index: index + 1,
                  onDelete: () {

                  },
                );
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 10),
            child: ResQFoodPrimaryButton(text: "Edit", onPressed: () => {}),
          )
        ],
      ),
    );
  }

  Widget _buildCommonField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
          const Divider(color: Colors.black, thickness: 1),
        ],
      ),
    );
  }
}