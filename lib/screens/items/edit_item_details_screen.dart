import 'package:flutter/material.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/providers/notification/notification_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/screens/notifications/notifications_screen.dart';
import 'package:frontend/widgets/message_dialog.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditItemDetailsScreen extends StatefulWidget {
  final GroupedUserItem groupedUserItem;

  const EditItemDetailsScreen({super.key, required this.groupedUserItem});

  @override
  State<EditItemDetailsScreen> createState() => _EditItemDetailsScreenState();
}

class _EditItemDetailsScreenState extends State<EditItemDetailsScreen> {
  final List<String> _categories = [
    'FRUIT',
    'VEGETABLE',
    'GRAIN',
    'PROTEIN',
    'DAIRY',
    'SWEETS',
    'BEVERAGE',
    'READY_MEAL',
    'SPICE',
    'BAKING',
    'FROZEN',
    'CANNED',
    'PANTRY',
  ];

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late int _quantity;

  final List<TextEditingController> _expirationControllers = [];
  final List<TextEditingController> _openedDateControllers = [];
  final List<TextEditingController> _openedRuleControllers = [];
  final List<TextEditingController> _descriptionControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.groupedUserItem.itemName,
    );
    _categoryController = TextEditingController(
      text: widget.groupedUserItem.type,
    );
    _quantity = widget.groupedUserItem.amount;

    for (var item in widget.groupedUserItem.allInstances) {
      _addInstanceControllers(item);
    }
  }

  void _addInstanceControllers([UserItem? item]) {
    final dateformat = DateFormat('dd-MM-yyyy');
    _expirationControllers.add(
      TextEditingController(
        text: item != null ? dateformat.format(item.expirationDate) : '',
      ),
    );
    _openedDateControllers.add(
      TextEditingController(
        text: item?.openedDate != null
            ? dateformat.format(item!.openedDate!)
            : 'Unopened',
      ),
    );
    _openedRuleControllers.add(
      TextEditingController(
        text: item?.openedRule != null ? "${item!.openedRule} days" : "3 days",
      ),
    );
    _descriptionControllers.add(
      TextEditingController(text: item?.description ?? ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    for (var c in _expirationControllers) {
      c.dispose();
    }
    for (var c in _openedDateControllers) {
      c.dispose();
    }
    for (var c in _openedRuleControllers) {
      c.dispose();
    }
    for (var c in _descriptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userItemProvider = context.watch<UserItemProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    return Scaffold(
      appBar: ResQFoodAppBar(
        onMenuTap: () {},
        onNotificationTap: () {
          notificationProvider.setUnread(false);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationScreen()),
          );
        },
        onUserTap: () {},
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: TextButton.icon(
                  onPressed: () => {Navigator.pop(context)},
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: const Text(
                    "Go back",
                    style: TextStyle(color: Colors.black),
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
                    child: Text(
                      _nameController.text,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildEditField("Name", _nameController),
                  _buildCategoryDropdown(),

                  _buildQuantityRow(),

                  const SizedBox(height: 10),

                  for (int i = 0; i < _quantity; i++) ...[
                    Text(
                      "${_nameController.text} #${i + 1}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDateField(
                      "Expiration date",
                      _expirationControllers[i],
                    ),
                    _buildDateField(
                      "Opened date (opt)",
                      _openedDateControllers[i],
                    ),
                    _buildEditField(
                      "Opened rule (opt)",
                      _openedRuleControllers[i],
                    ),
                    _buildDescriptionBox(_descriptionControllers[i]),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (i < widget.groupedUserItem.allInstances.length) {
                            final instance =
                                widget.groupedUserItem.allInstances[i];
                            _showDeleteConfirmation(
                              context,
                              userItemProvider,
                              instance.id!,
                              "${_nameController.text} #${i + 1}",
                            );
                          } else {
                            setState(() {
                              _quantity--;
                              _expirationControllers.removeAt(i).dispose();
                              _openedDateControllers.removeAt(i).dispose();
                              _openedRuleControllers.removeAt(i).dispose();
                              _descriptionControllers.removeAt(i).dispose();
                            });
                          }
                        },
                        child: const Text(
                          "Remove this instance",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ResQFoodPrimaryButton(
                          text: "Save",
                          onPressed: () {
                            _handleSave();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Category", style: TextStyle(fontSize: 16)),
        DropdownButtonFormField<String>(
          key: ValueKey(_categoryController.text),
          initialValue: _categories.contains(_categoryController.text)
              ? _categoryController.text
              : null,
          items: _categories.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(
                category.replaceAll('_', ' '),
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _categoryController.text = newValue!;
            });
          },
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          hint: const Text("Select a category"),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildQuantityRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quantity", style: TextStyle(fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$_quantity", style: const TextStyle(fontSize: 14)),
            Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    _quantity++;
                    _addInstanceControllers();
                  }),
                  child: const Icon(Icons.keyboard_arrow_up),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    if (_quantity > 1) {
                      _quantity--;
                    }
                  }),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 1),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildDescriptionBox(TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description (opt)", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Colors.black,
              size: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  void _handleSave() async {
    List<UserItem> itemsToProcess = [];

    for (int i = 0; i < _quantity; i++) {
      final bool isExisting = i < widget.groupedUserItem.allInstances.length;
      final int? existingId = isExisting
          ? widget.groupedUserItem.allInstances[i].id
          : null;

      itemsToProcess.add(
        UserItem(
          id: existingId,
          itemId: widget.groupedUserItem.allInstances[0].itemId,
          itemName: _nameController.text,
          type: _categoryController.text,
          expirationDate: DateFormat(
            'dd-MM-yyyy',
          ).parse(_expirationControllers[i].text),
          openedDate: _openedDateControllers[i].text == 'Unopened'
              ? null
              : DateFormat('dd-MM-yyyy').parse(_openedDateControllers[i].text),
          openedRule: int.tryParse(
            _openedRuleControllers[i].text.split(' ')[0],
          ),
          description: _descriptionControllers[i].text,
        ),
      );
    }
    try {
      await context.read<UserItemProvider>().saveBatch(itemsToProcess);
      if (mounted) {
        MessageDialog.show(context, message: "Item(s) saved successfully!");

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving: $e")));
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    UserItemProvider provider,
    int id,
    String instanceTitle,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete $instanceTitle?"),
        content: const Text(
          "Are you sure you want to remove this specific instance?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await provider.deleteInstance(id);
                if (context.mounted) {
                  final updatedGroup = provider.items
                      .where(
                        (e) => e.itemName == widget.groupedUserItem.itemName,
                      )
                      .firstOrNull;

                  if (updatedGroup == null || updatedGroup.amount == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    setState(() {
                      _quantity = updatedGroup.amount;

                      for (var c in _expirationControllers) {
                        c.dispose();
                      }
                      for (var c in _openedDateControllers) {
                        c.dispose();
                      }
                      for (var c in _openedRuleControllers) {
                        c.dispose();
                      }
                      for (var c in _descriptionControllers) {
                        c.dispose();
                      }

                      _expirationControllers.clear();
                      _openedDateControllers.clear();
                      _openedRuleControllers.clear();
                      _descriptionControllers.clear();

                      for (var item in updatedGroup.allInstances) {
                        _addInstanceControllers(item);
                      }
                    });
                  }
                  MessageDialog.show(
                    context,
                    message: "Instance successfully removed!",
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Delete Failed")),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
