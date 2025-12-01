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
  final _openedRuleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'None',
    'Fruit',
    'Vegetable',
    'Grain',
    'Protein',
    'Fish',
    'Dairy',
    'Sweets',
    'Beverage',
    'Ready_meal',
    'Spice',
    'Baking',
    'Frozen',
    'Canned',
    'Pantry',
  ];

  String? _selectedCategory = 'None';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _expirationDateController.dispose();
    _openedDateController.dispose();
    _openedRuleController.dispose();
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
      return 'Expiration date is required and must be in the future.';
    }
    try {
      // Parse DD/MM/YYYY format
      final parts = value.split('/');
      if (parts.length != 3) {
        return 'Expiration date is required and must be in the future.';
      }
      final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      if (date.isBefore(DateTime.now())) {
        return 'Expiration date is required and must be in the future.';
      }
    } catch (e) {
      return 'Expiration date is required and must be in the future.';
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
        controller.text = '$day/$month/$year'; // Format as DD/MM/YYYY
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final item = Item(
        name: _nameController.text,
        category: _selectedCategory == 'None' ? '' : (_selectedCategory ?? ''),
        quantity: _quantityController.text,
        expirationDate: _expirationDateController.text,
        openedDate: _openedDateController.text.isEmpty ? null : _openedDateController.text,
        openedRule: _openedRuleController.text.isEmpty ? null : _openedRuleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );
      Navigator.pop(context, item);
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
                  'Add item',
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
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
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
                onTap: () => _selectDate(_expirationDateController, futureOnly: true),
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
              const Text('Opened rule (opt)', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('2 days', style: TextStyle(color: Colors.grey, fontSize: 12)),
              TextFormField(
                controller: _openedRuleController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  isDense: true,
                  suffixIcon: Icon(Icons.lock, color: Colors.grey[400], size: 18),
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
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Add',
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
