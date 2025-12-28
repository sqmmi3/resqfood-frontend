import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
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
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      backgroundColor: highContrast 
        ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
        : theme.colorScheme.surface,
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
                    onPressed: () { Navigator.pop(context); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
                    icon: Icon(
                      Icons.arrow_back,
                      color: highContrast 
                      ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black)
                      : theme.colorScheme.onSurface,
                    ),
                    label: Text(
                      "Go back",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: highContrast ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(groupedItem.itemName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: highContrast ? (isDark ? Colors.white :Colors.black) : theme.colorScheme.primary)),
                    ),
                    const SizedBox(height: 30),

                    _buildCommonField(context, "Name", groupedItem.itemName, highContrast),
                    _buildCommonField(context, "Category", groupedItem.type, highContrast),
                    _buildCommonField(context, "Quantity", groupedItem.amount.toString(), highContrast),
                    
                    const SizedBox(height: 10),

                    for (int i = 0; i < groupedItem.allInstances.length; i++)
                      UserItemDetailCard(
                        userItem: groupedItem.allInstances[i],
                        index: i + 1,
                        onDelete: () {
                          _showDeleteConfirmation(context, userItemProvider, groupedItem.allInstances[i].id!, "${groupedItem.itemName.toString()} #${i + 1}", isHapticsEnabled, highContrast);
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

  Widget _buildCommonField(BuildContext context, String label, String value, bool highContrast) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: highContrast ? 18 : 16,
              fontWeight: highContrast ? FontWeight.bold : FontWeight.normal,
              color: theme.colorScheme.onSurface.withValues(alpha:0.8),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: highContrast ? 16 : 14,
              fontWeight: highContrast ? FontWeight.w700 : FontWeight.w300,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Divider(
            color: highContrast
              ? (theme.brightness == Brightness.dark ? Colors.white : Colors.black)
              : theme.dividerColor,
            thickness: highContrast ? 2 : 1
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserItemProvider provider, int id, String instanceTitle, bool isHapticsEnabled, bool highContrast) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: highContrast ? (isDark ? Colors.black : Colors.white) : theme.colorScheme.surface,
        shape: Border.all(
          color: highContrast ? (isDark ? Colors.white : Colors.black) : Colors.transparent
        ),
        title: Text("Delete $instanceTitle?"),
        content: const Text("Are you sure you want to remove this specific instance?"),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
            child: Text("Cancel", style: TextStyle(color: highContrast ? (isDark ? Colors.white : Colors.black) : theme.colorScheme.primary)),
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
              isHapticsEnabled ? HapticFeedback.mediumImpact() : null;
            },
            child: Text("Delete", style: TextStyle(color: highContrast ? (isDark ? Colors.white : Colors.black) : theme.colorScheme.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}