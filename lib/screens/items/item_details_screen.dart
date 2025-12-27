import 'package:flutter/material.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/items/edit_item_details_screen.dart';
import 'package:frontend/widgets/message_dialog.dart';
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
      body: 
        SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: TextButton.icon(
                    onPressed: () => {Navigator.pop(context)},
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface,),
                    label: Text("Go back", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(groupedItem.itemName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 20),

                    _buildCommonField(context, "Name", groupedItem.itemName),
                    _buildCommonField(context, "Category", groupedItem.type),
                    _buildCommonField(context, "Quantity", groupedItem.amount.toString()),
                    
                    const SizedBox(height: 10),

                    for (int i = 0; i < groupedItem.allInstances.length; i++)
                      UserItemDetailCard(
                        userItem: groupedItem.allInstances[i],
                        index: i + 1,
                        onDelete: () {
                          _showDeleteConfirmation(context, userItemProvider, groupedItem.allInstances[i].id!, "${groupedItem.itemName.toString()} #${i + 1}");
                        }
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 10),
                child: ResQFoodPrimaryButton(text: "Edit", onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => EditItemDetailsScreen(groupedUserItem: groupedItem)))}),
              )
            ],
          ),
        ),
        
    );
  }

  Widget _buildCommonField(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
          Divider(color: Theme.of(context).dividerColor, thickness: 1),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserItemProvider provider, int id, String instanceTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $instanceTitle?"),
        content: const Text("Are you sure you want to remove this specific instance?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.deleteInstance(id);
                if (context.mounted) {
                  MessageDialog.show(context, message: "Instance successfully removed!");
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Delete Failed")),
                  );
                }
              }
            },
            child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}