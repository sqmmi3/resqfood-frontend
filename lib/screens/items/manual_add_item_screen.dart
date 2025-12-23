import 'package:flutter/material.dart';
import 'package:frontend/models/user_item.dart';
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
    return Scaffold(
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
                  onPressed: () => { Navigator.pop(context) },
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  label: const Text("Go back", style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text("Add Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28))),
                  const SizedBox(height: 20),
                  const Text("General Information", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
                  const SizedBox(height: 10),
                  _buildAddField("Product name", _nameController),
                  _buildCategoryDropDown(),

                  const SizedBox(height: 20),
                  const Text("Specific Information", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20)),
                  const SizedBox(height: 10),
                  _buildDateField("Expiry date", _expiryDateController),
                  _buildAddField("Opened rule (opt)", _openedRuleController, defaultValue: "3 days"),
                  _buildDescriptionField(),
                  ResQFoodPrimaryButton(text: "Add to Inventory", onPressed: _handleSave),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ]
        )
      )
    );
  }

  Widget _buildAddField(String label, TextEditingController controller, {String? defaultValue}) {
    if (defaultValue != null && controller.text.isEmpty) {
      controller.text = defaultValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        ResQFoodTextField(label: label, defaultValue: defaultValue, controller: controller),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildCategoryDropDown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Category", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedCategory),
          hint: const Text("Select a category"),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category.replaceAll('_', ' ')))).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
          decoration:  InputDecoration(
            labelText: "Product category",
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            floatingLabelStyle: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
            labelStyle: const TextStyle(color: Colors.black54),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.green, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.red, width: 2)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        ResQFoodTextField(
          label: "Product expiry date",
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(context, controller),
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
          child: child!
        );
      },
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Stack(
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 128,
              decoration: InputDecoration(
                labelText: "Product description",
                hintText: "Product description",
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                floatingLabelStyle: const TextStyle(
                  color: Colors.green, 
                  fontWeight: FontWeight.bold
                ),
                labelStyle: const TextStyle(color: Colors.black54),
                contentPadding: const EdgeInsets.fromLTRB(14, 18, 14, 30),
                
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.green, width: 1),
                ),
                counterText: "",
              ),
            ),
            Positioned(
              bottom: 12,
              right: 14,
              child: Text(
                "${_descriptionController.text.length}/128",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
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