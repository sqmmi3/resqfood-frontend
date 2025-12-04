import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _expirationDateController = TextEditingController();
  final _openedDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'None',
    'FRUIT',
    'VEGETABLE',
    'GRAIN',
    'PROTEIN',
    'FISH',
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

  String? _selectedCategory = 'None';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expirationDateController.dispose();
    _openedDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }
    return null;
  }

  String? _validateExpirationDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Expiration date is required.';
    }
    try {
      final parts = value.split('/');
      if (parts.length != 3) {
        return 'Expiration date is required.';
      }
      final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      if (date.isBefore(DateTime.now())) {
        return 'Expiration date must be in the future.';
      }
    } catch (e) {
      return 'Expiration date is required.';
    }
    return null;
  }

  String _convertDateDDMMYYYYToYYYYMMDD(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      // If conversion fails, return as is
    }
    return dateStr;
  }

  String? _getFormattedExpirationDate() {
    final text = _expirationDateController.text;
    return text.isEmpty ? null : _convertDateDDMMYYYYToYYYYMMDD(text);
  }

  String? _getFormattedOpenedDate() {
    final text = _openedDateController.text;
    return text.isEmpty ? null : _convertDateDDMMYYYYToYYYYMMDD(text);
  }

  String? _getSelectedCategory() {
    if (_selectedCategory == null || _selectedCategory == 'None') {
      return null;
    }
    return _selectedCategory;
  }

  Future<void> _selectDate(TextEditingController controller, {bool futureOnly = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: futureOnly ? DateTime.now() : DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year;
        controller.text = '$day/$month/$year';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        name: _nameController.text,
        category: _getSelectedCategory(),
        quantity: int.tryParse(_quantityController.text),
        expirationDate: _getFormattedExpirationDate(),
        openedDate: _getFormattedOpenedDate(),
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );
      Navigator.pop(context, item);
    }
  }

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon != null 
              ? Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(suffixIcon, color: Colors.grey[400], size: 20),
                )
              : null,
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          items: _categories
              .map((category) => DropdownMenuItem(value: category, child: Text(category)))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
          decoration: InputDecoration(
            hintText: 'Select a category',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.black, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                label: 'Name *',
                hint: 'Enter item name',
                controller: _nameController,
                validator: _validateName,
              ),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'Expiration date *',
                hint: 'DD/MM/YYYY',
                controller: _expirationDateController,
                validator: _validateExpirationDate,
                readOnly: true,
                onTap: () => _selectDate(_expirationDateController, futureOnly: true),
                suffixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 24),
              _buildCategoryDropdown(),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'Quantity',
                hint: 'Enter quantity in grams',
                controller: _quantityController,
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Quantity must be a number';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                suffixIcon: Icons.inventory_2,
              ),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'Opened date',
                hint: 'DD/MM/YYYY',
                controller: _openedDateController,
                readOnly: true,
                onTap: () => _selectDate(_openedDateController),
                suffixIcon: Icons.calendar_today,
              ),
              const SizedBox(height: 24),
              _buildFormField(
                label: 'Description',
                hint: 'Add notes about this item...',
                controller: _descriptionController,
                maxLines: 4,
              ),
              const SizedBox(height: 40),
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
