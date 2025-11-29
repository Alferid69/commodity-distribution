import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Assuming you have your commodity model available
import 'package:public_commodity_distribution/models/commodities_model.dart';
import 'package:public_commodity_distribution/models/customer_model.dart';

/// A modal bottom sheet for adding a new transaction.
class AddTransactionSheet extends StatefulWidget {
  // Prefilled customer (optional)
  final Customer? prefilledCustomer;
  // Pass in the list of available commodities
  final List<Commodity> commodities;
  // A callback function to pass the new transaction data back
  final Function(
    String name,
    String houseNumber,
    String woreda,
    Commodity selectedCommodity,
    double quantity,
  ) onCreate;

  const AddTransactionSheet({
    super.key,
    required this.commodities,
    required this.onCreate,
    this.prefilledCustomer,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _woredaController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  Commodity? _selectedCommodity;

  @override
  void initState() {
    super.initState();
    // Prefill from provided customer if available
    final c = widget.prefilledCustomer;
    if (c != null) {
      _nameController.text = c.name;
      _houseNumberController.text = c.houseNo;
      _woredaController.text = c.woreda.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _houseNumberController.dispose();
    _woredaController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Validate the form
    if (_formKey.currentState!.validate() && _selectedCommodity != null) {
      // If valid, call the onCreate callback
      widget.onCreate(
        _nameController.text,
        _houseNumberController.text,
        _woredaController.text,
        _selectedCommodity!,
        double.parse(_quantityController.text),
      );
      // Close the modal
      Navigator.of(context).pop();
    } else if (_selectedCommodity == null) {
      // Show a snackbar if no commodity is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a commodity.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      child: Container(
        // White background with rounded top corners
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Padding(
          // Add padding for the keyboard
          padding: EdgeInsets.fromLTRB(
            24.0,
            24.0,
            24.0,
            MediaQuery.of(context).viewInsets.bottom + 24.0,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit content vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Transaction',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
      
                // Form Fields
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Enter full name',
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _houseNumberController,
                  label: 'House Number',
                  hint: 'Enter house number',
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _woredaController,
                  label: 'Woreda',
                  hint: 'Enter woreda',
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  context: context,
                  label: 'Commodity',
                  value: _selectedCommodity,
                  hint: 'Select a commodity',
                  // Create DropdownMenuItem for each commodity
                  items: widget.commodities.map((Commodity commodity) {
                    return DropdownMenuItem<Commodity>(
                      value: commodity,
                      child: Text(commodity.name),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCommodity = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _quantityController,
                  label: 'Quantity',
                  hint: 'e.g. 5',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 32),
      
                // Create Transaction Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Create Transaction',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for text fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Helper for dropdown
  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required Commodity? value,
    required String hint,
    required List<DropdownMenuItem<Commodity>> items,
    required ValueChanged<Commodity?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Commodity>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          // We don't use the form's validator, we check in _handleSubmit
        ),
      ],
    );
  }
}