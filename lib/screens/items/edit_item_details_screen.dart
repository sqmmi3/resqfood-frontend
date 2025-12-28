import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/grouped_user_item.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/widgets/message_dialog.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_secondary_button.dart';
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
    'FRUIT', 'VEGETABLE', 'GRAIN', 'PROTEIN', 'DAIRY',
    'SWEETS', 'BEVERAGE', 'READY_MEAL', 'SPICE',
    'BAKING', 'FROZEN', 'CANNED', 'PANTRY'
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
    _nameController = TextEditingController(text: widget.groupedUserItem.itemName);
    _categoryController = TextEditingController(text: widget.groupedUserItem.type);
    _quantity = widget.groupedUserItem.amount;

    for (var item in widget.groupedUserItem.allInstances) {
      _addInstanceControllers(item);
    }
  }

  void _addInstanceControllers([UserItem? item]) {
    final dateformat = DateFormat('dd-MM-yyyy');
    _expirationControllers.add(TextEditingController(text: item != null ? dateformat.format(item.expirationDate) : ''));
    _openedDateControllers.add(TextEditingController(text: item?.openedDate != null ? dateformat.format(item!.openedDate!) : 'Unopened'));
    _openedRuleControllers.add(TextEditingController(text: item?.openedRule != null ? "${item!.openedRule} days" : "3 days"));
    _descriptionControllers.add(TextEditingController(text: item?.description ?? ''));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    for (var c in _expirationControllers) { c.dispose(); }
    for (var c in _openedDateControllers) { c.dispose(); }
    for (var c in _openedRuleControllers) { c.dispose(); }
    for (var c in _descriptionControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userItemProvider = context.watch<UserItemProvider>();
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final theme = Theme.of(context)

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      : theme.colorScheme.onSurface
                  ),
                  label: Text(
                    "Go back",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: highContrast ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Center(child: Text(_nameController.text, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 20),

                  _buildEditField("Name", _nameController, highContrast, isHapticsEnabled),
                  _buildCategoryDropdown(highContrast, isHapticsEnabled),

                  _buildQuantityRow(highContrast, isHapticsEnabled),

                  const SizedBox(height: 10),

                  for (int i = 0; i < _quantity; i++) ...[
                    Text("${_nameController.text} #${i + 1}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildDateField("Expiration date", _expirationControllers[i], highContrast, isHapticsEnabled),
                    _buildDateField("Opened date (opt)", _openedDateControllers[i], highContrast, isHapticsEnabled),
                    _buildEditField("Opened rule (opt)", _openedRuleControllers[i], highContrast, isHapticsEnabled),
                    _buildDescriptionBox(_descriptionControllers[i], highContrast, isHapticsEnabled),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (i < widget.groupedUserItem.allInstances.length) {
                            final instance = widget.groupedUserItem.allInstances[i];
                            _showDeleteConfirmation(
                              context,
                              userItemProvider,
                              instance.id!,
                              "${_nameController.text} #${i + 1}",
                              highContrast,
                              isHapticsEnabled
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
                          isHapticsEnabled ? HapticFeedback.lightImpact() : null;
                        },
                        child: Text(
                          "Remove this instance",
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: highContrast ? FontWeight.bold : FontWeight.normal,
                            fontSize: highContrast ? 14 : 12
                          )
                        )
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: ResQFoodSecondaryButton(
                          text: "Cancel",
                          onPressed: () => Navigator.pop(context)
                        )
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ResQFoodPrimaryButton(
                          text: "Save",
                          onPressed: () { _handleSave(); }
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ]
              )
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, bool highContrast, bool isHapticsEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        TextField(
          controller: controller,
          onTap: () { isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
          decoration: InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface)),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCategoryDropdown(bool highContrast, bool isHapticsEnabled) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
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
                style: TextStyle(fontSize: highContrast ? 16 : 14),
              ),
            );
          }).toList(),
          onTap: () { isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
          onChanged: (newValue) {
            setState(() {
              _categoryController.text = newValue!;
            });
          },
          decoration: InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: theme.colorScheme.onSurface)),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface),
          hint: const Text("Select a category"),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildQuantityRow(bool highContrast, bool isHapticsEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Quantity", style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$_quantity", style: TextStyle(fontSize: highContrast ? 16 : 14)),
            Column(
              children: [
                GestureDetector(onTap: () { setState(() { _quantity++; _addInstanceControllers(); }); isHapticsEnabled ? HapticFeedback.lightImpact() : null; }, child: const Icon(Icons.keyboard_arrow_up)),
                GestureDetector(onTap: () { setState(() { if (_quantity > 1) { _quantity--; } }); isHapticsEnabled ? HapticFeedback.lightImpact() : null; }, child: const Icon(Icons.keyboard_arrow_down)),
              ],
            )
          ],
        ),
        const Divider(color: Theme.of(context).dividerColor, thickness: highContrast ? 2 : 1),
        const SizedBox(height: 10)
      ],
    );
  }

  Widget _buildDescriptionBox(TextEditingController controller, bool highContrast, bool isHapticsEnabled) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description (opt)", style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.surface, width: highContrast ? 3.0 : 1.0), borderRadius: BorderRadius.circular( highContrast ? 8 : 15)),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(border: InputBorder.none),
            onTap: () { isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Widget _buildDateField(String label, TextEditingController controller, bool highContrast, bool isHapticsEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () { _selectDate(context, controller); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
          decoration: InputDecoration(
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.black, size: highContrast ? 16 : 14),
          ),
        ),
        const SizedBox(height: 10)
      ],
    );
  }

  void _handleSave() async {
    List<UserItem> itemsToProcess = [];

    for (int i = 0; i < _quantity; i++) {
      final bool isExisting = i < widget.groupedUserItem.allInstances.length;
      final int? existingId = isExisting ? widget.groupedUserItem.allInstances[i].id : null;

      itemsToProcess.add(UserItem(
        id: existingId,
        itemId: widget.groupedUserItem.allInstances[0].itemId,
        itemName: _nameController.text,
        type: _categoryController.text,
        expirationDate: DateFormat('dd-MM-yyyy').parse(_expirationControllers[i].text),
        openedDate: _openedDateControllers[i].text == 'Unopened'
            ? null
            : DateFormat('dd-MM-yyyy').parse(_openedDateControllers[i].text),
        openedRule: int.tryParse(_openedRuleControllers[i].text.split(' ')[0]),
        description: _descriptionControllers[i].text,
      ));
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context, UserItemProvider provider, int id, String instanceTitle, bool highContrast, bool isHapticsEnabled) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Delete $instanceTitle?"),
        content: const Text("Are you sure you want to remove this specific instance?"),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(dialogContext); isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              isHapticsEnabled ? HapticFeedback.lightImpact() : null;
              Navigator.pop(dialogContext);
              try {
                await provider.deleteInstance(id);
                if (context.mounted) {
                  final updatedGroup = provider.items
                    .where((e) => e.itemName == widget.groupedUserItem.itemName)
                    .firstOrNull;
                  
                  if (updatedGroup == null || updatedGroup.amount == 0) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } else {
                    setState(() {
                      _quantity = updatedGroup.amount;

                      for (var c in _expirationControllers) { c.dispose(); }
                      for (var c in _openedDateControllers) { c.dispose(); }
                      for (var c in _openedRuleControllers) { c.dispose(); }
                      for (var c in _descriptionControllers) { c.dispose(); }

                      _expirationControllers.clear();
                      _openedDateControllers.clear();
                      _openedRuleControllers.clear();
                      _descriptionControllers.clear();

                      for (var item in updatedGroup.allInstances) {
                        _addInstanceControllers(item);
                      }
                    });
                  }
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
            child: Text("Delete", style: TextStyle(color: highContrast ? Colors.black : Colors.red)),
          ),
        ],
      ),
    );
  }
}