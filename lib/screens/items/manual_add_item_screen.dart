import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/user_item.dart';
import 'package:frontend/providers/auth/auth_provider.dart';
import 'package:frontend/providers/user_item/user_item_provider.dart';
import 'package:frontend/widgets/message_dialog.dart';
import 'package:frontend/widgets/nav/resqfood_appbar.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_primary_button.dart';
import 'package:frontend/widgets/resqfood_custom/resqfood_text_field.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ManualAddItemScreen extends StatefulWidget {
  const ManualAddItemScreen({super.key});

  @override
  State<ManualAddItemScreen> createState() => _ManualAddItemScreenState();
}

class _ManualAddItemScreenState extends State<ManualAddItemScreen> {
  final dateformat = DateFormat('dd-MM-yyyy');
  late TextEditingController _nameController;
  String? _selectedCategory;

  final List<String> _categories = [
    'FRUIT', 'VEGETABLE', 'GRAIN', 'PROTEIN', 'DAIRY',
    'SWEETS', 'BEVERAGE', 'READY_MEAL', 'SPICE',
    'BAKING', 'FROZEN', 'CANNED', 'PANTRY'
  ];

  late TextEditingController _expiryDateController;
  late TextEditingController _openedRuleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
   super.initState();
   _nameController = TextEditingController();
   _expiryDateController = TextEditingController();
   _openedRuleController = TextEditingController();
   _descriptionController = TextEditingController();
   _descriptionController.addListener(() {
    setState(() {});
   });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _expiryDateController.dispose();
    _openedRuleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = context.watch<AuthProvider>().highContrast;
    final isHapticsEnabled = context.watch<AuthProvider>().hapticsEnabled;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                      : theme.colorScheme.primary
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
                  Center(child: Text("Add Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: highContrast ? (isDark ? Colors.white : Colors.black) : theme.colorScheme.primary))),
                  const SizedBox(height: 30),
                  _buildSectionLabel("General Information", highContrast, theme),
                  _buildAddField("Product name", _nameController, highContrast),
                  _buildCategoryDropDown(highContrast, isHapticsEnabled, theme),

                  const SizedBox(height: 30),
                  _buildSectionLabel("Specific Information", highContrast, theme),
                  _buildDateField("Expiry date", _expiryDateController, highContrast),
                  _buildAddField("Opened rule (opt)", _openedRuleController, highContrast, defaultValue: "3 days"),
                  _buildDescriptionField(highContrast, isHapticsEnabled, theme),
                  ResQFoodPrimaryButton(text: "Add to Inventory", onPressed: _handleSave),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ]
        )
      )
    );
  }

  Widget _buildSectionLabel(String text, bool highContrast, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(text, 
        style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 20,
          color: theme.colorScheme.onSurface,
          decoration: highContrast ? TextDecoration.underline : null,
        )
      ),
    );
  }

  Widget _buildAddField(String label, TextEditingController controller, bool highContrast, {String? defaultValue}) {
    if (defaultValue != null && controller.text.isEmpty) {
      controller.text = defaultValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 20),
        ResQFoodTextField(label: label, defaultValue: defaultValue, controller: controller),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCategoryDropDown(bool highContrast, bool isHapticsEnabled, ThemeData theme) {
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedCategory),
          hint: const Text("Select a category"),
          dropdownColor: highContrast
            ? (theme.brightness == Brightness.dark ? Colors.black : Colors.white)
            : theme.colorScheme.surface,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
          items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category.replaceAll('_', ' ')))).toList(),
          onTap: () { isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
          onChanged: (value) => setState(() => _selectedCategory = value),
          decoration:  InputDecoration(
            labelText: "Product category",
            floatingLabelBehavior: highContrast ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
            floatingLabelStyle: TextStyle(
              color: highContrast ? colorScheme.onSurface : colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            labelStyle: TextStyle(color: highContrast ? Colors.black : Colors.black54),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
              borderSide: BorderSide(color: highContrast ? colorScheme.onSurface : (isDark ? Colors.white70 :Colors.grey), width: highContrast ? 2.0 : 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
              borderSide: BorderSide(color: highContrast ? colorScheme.onSurface : colorScheme.primary, width: highContrast ? 3.0 : 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(highContrast? 8 : 15),
              borderSide: BorderSide(color: highContrast? colorScheme.onSurface : colorScheme.error, width: highContrast ? 2.5 : 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
              borderSide: BorderSide(color: highContrast ? colorScheme.onSurface : colorScheme.error, width: highContrast ? 3.0 : 2.0)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, bool highContrast) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 20),
        ResQFoodTextField(
          label: "Product expiry date",
          controller: controller,
          readOnly: true,
          onTap: () { _selectDate(context, controller); },
        ),
        const SizedBox(height: 10),
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

  Widget _buildDescriptionField(bool highContrast, bool isHapticsEnabled, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: TextStyle(fontSize: highContrast ? 18 : 16, fontWeight: highContrast ? FontWeight.bold : FontWeight.normal)),
        const SizedBox(height: 10),
        Stack(
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 128,
              onTap: () { isHapticsEnabled ? HapticFeedback.lightImpact() : null; },
              decoration: InputDecoration(
                labelText: "Product description",
                hintText: "Enter Product description",
                floatingLabelStyle: TextStyle(
                  color: highContrast ? theme.colorScheme.onSurface : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(color: highContrast ? Colors.black : Colors.black54),
                contentPadding: const EdgeInsets.fromLTRB(14, 18, 14, 30),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
                  borderSide: BorderSide(color: highContrast ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white70 : Colors.grey), width: highContrast ? 2.0 : 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(highContrast ? 8 : 15),
                  borderSide: BorderSide(color: highContrast ? (isDark ? Colors.white : Colors.black) : theme.colorScheme.primary, width: highContrast ? 3.0 : 1.0),
                ),
                counterText: "",
              ),
            ),
            Positioned(
              bottom: 12,
              right: 14,
              child: Text(
                "${_descriptionController.text.length}/128",
                style: TextStyle(
                  color: highContrast ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.white70 :Colors.grey),
                  fontSize: highContrast ? 14 : 10,
                  fontWeight: highContrast ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _handleSave() async {
    try {
      _validateFields();

      int rule = int.tryParse(_openedRuleController.text.split(' ')[0]) ?? 3;

      final newItem = UserItem(
        itemName: _nameController.text.trim(),
        type: _selectedCategory!,
        expirationDate: DateFormat('dd-MM-yyyy').parse(_expiryDateController.text),
        openedRule: rule,
        description: _descriptionController.text.trim(),
      );

      debugPrint(newItem.toString());

      await context.read<UserItemProvider>().saveBatch([newItem]);

      if (mounted) {
        MessageDialog.show(context, message: "Item successfully added!");
        Future.delayed(const Duration(milliseconds: 1000), () => Navigator.pop(context));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _validateFields() {
    if (_nameController.text.trim().isEmpty) {
      throw Exception("Product name is required.");
    }

    if (_selectedCategory == null) {
      throw Exception("Please select a product category.");
    }

    if (_expiryDateController.text.isEmpty) {
      throw Exception("Expiry date is required.");
    }

    DateTime expiry = DateFormat('dd-MM-yyyy').parse(_expiryDateController.text);
    if (expiry.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw Exception("The expiry date cannot be in the past.");
    }

    if (_openedRuleController.text.isNotEmpty) {
      int? rule = int.tryParse(_openedRuleController.text.split(' ')[0]);
      if (rule == null || rule <= 0) {
        throw Exception("Opened rule must be a positive number of days.");
      }
    }
  }
}