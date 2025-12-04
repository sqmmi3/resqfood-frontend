import 'package:flutter/material.dart';
import 'package:frontend/models/item.dart';
import 'package:frontend/services/items/item_service.dart';
import 'package:frontend/widgets/message_dialog.dart';

class EditItemScreen extends StatefulWidget {
  final Item item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemService = ItemService();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _expirationDateController;
  late TextEditingController _openedDateController;
  late TextEditingController _descriptionController;

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

  late String _selectedCategory;

  String _convertDateYYYYMMDDToDDMMYYYY(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
    }
    return dateStr;
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(text: widget.item.quantity?.toString() ?? '');
    _expirationDateController = TextEditingController(
      text: _convertDateYYYYMMDDToDDMMYYYY(widget.item.expirationDate),
    );
    _openedDateController = TextEditingController(
      text: _convertDateYYYYMMDDToDDMMYYYY(widget.item.openedDate),
    );
    _descriptionController = TextEditingController(text: widget.item.description ?? '');
  }

  void _initializeCategory() {
    String category = (widget.item.category == null || widget.item.category!.isEmpty) ? 'None' : widget.item.category!;
    _selectedCategory = _categories.contains(category) ? category : 'None';
  }

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeCategory();
  }

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
      final parts = value.contains('-') ? value.split('-') : value.split('/');
      if (parts.length != 3) {
        return 'Expiration date format must be DD/MM/YYYY.';
      }
      
      if (value.contains('-')) {
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      } else {
        DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      return 'Expiration date format must be DD/MM/YYYY.';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
      return 'Quantity must be a number';
    }
    return null;
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

  void _showEditConfirmation() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Save changes?'),
          content: const Text('Are you sure you want to save these changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _submitForm();
              },
              child: const Text('Save', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    }
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
    if (_selectedCategory == 'None') {
      return null;
    }
    return _selectedCategory.isEmpty ? null : _selectedCategory;
  }

  void _submitForm() async {
    final updatedItem = Item(
      id: widget.item.id,
      name: _nameController.text,
      category: _getSelectedCategory(),
      quantity: int.tryParse(_quantityController.text),
      expirationDate: _getFormattedExpirationDate(),
      openedDate: _getFormattedOpenedDate(),
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    await _updateItemOnBackend(updatedItem);
  }

  Future<void> _updateItemOnBackend(Item updatedItem) async {
    try {
      if (updatedItem.id == null) {
        throw Exception('Item ID is missing');
      }
      final result = await _itemService.updateItem(updatedItem.id!, updatedItem);
      if (mounted) {
        MessageDialog.show(context, message: '${result.name} successfully updated');
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context, result);
        });
      }
    } catch (e) {
      if (mounted) {
        MessageDialog.show(context, message: 'Failed to update item: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logo'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Edit item',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Name', style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextFormField(
                controller: _nameController,
                validator: _validateName,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Category (opt)', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Category', style: TextStyle(color: Colors.grey, fontSize: 12)),
              DropdownButtonFormField<String>(
                initialValue: _categories.contains(_selectedCategory) ? _selectedCategory : 'None',
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? 'None';
                  });
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  isDense: true,
                  hintText: 'Select a category',
                ),
              ),
              const SizedBox(height: 20),
              const Text('Quantity (opt)', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Quantity', style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: _validateQuantity,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(Icons.lock, color: Colors.grey[400], size: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Expiration date', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Expiration date', style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextFormField(
                controller: _expirationDateController,
                validator: _validateExpirationDate,
                readOnly: true,
                onTap: () => _selectDate(_expirationDateController, futureOnly: false),
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  isDense: true,
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Opened date (opt)', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('Opened date', style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextFormField(
                controller: _openedDateController,
                readOnly: true,
                onTap: () => _selectDate(_openedDateController),
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Description (opt)', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _showEditConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
