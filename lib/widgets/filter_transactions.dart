import 'package:flutter/material.dart';

/// A modal bottom sheet for filtering transactions.
///
/// This widget is now stateful and accepts initial filter values
/// and callbacks to apply or clear filters.
class FilterTransactionsSheet extends StatefulWidget {
  final String initialCommodity;
  final String initialStatus;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?, String, String) onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterTransactionsSheet({
    super.key,
    required this.initialCommodity,
    required this.initialStatus,
    this.initialStartDate,
    this.initialEndDate,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<FilterTransactionsSheet> createState() =>
      _FilterTransactionsSheetState();
}

class _FilterTransactionsSheetState extends State<FilterTransactionsSheet> {
  // Local state for the filters
  late String _selectedCommodity;
  late String _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize local state from widget properties
    _selectedCommodity = widget.initialCommodity;
    _selectedStatus = widget.initialStatus;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    if (_startDate != null) {
      _startDateController.text =
          "${_startDate!.month}/${_startDate!.day}/${_startDate!.year}";
    }
    if (_endDate != null) {
      _endDateController.text =
          "${_endDate!.month}/${_endDate!.day}/${_endDate!.year}";
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          _startDateController.text =
              "${picked.month}/${picked.day}/${picked.year}";
        } else {
          _endDate = picked;
          _endDateController.text =
              "${picked.month}/${picked.day}/${picked.year}";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24.0,
          24.0,
          24.0,
          // Add padding for the keyboard
          MediaQuery.of(context).viewInsets.bottom + 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fit content vertically
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Transactions',
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

            // Date Pickers
            Row(
              children: [
                _buildDatePickerField(
                  context: context,
                  label: 'Start Date',
                  controller: _startDateController,
                  onTap: () => _selectDate(context, true),
                ),
                const SizedBox(width: 16),
                _buildDatePickerField(
                  context: context,
                  label: 'End Date',
                  controller: _endDateController,
                  onTap: () => _selectDate(context, false),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Commodities Filter
            _buildDropdown(
              context: context,
              label: 'Commodities Filter',
              value: _selectedCommodity,
              items: const [
                DropdownMenuItem(value: "all", child: Text("All Commodities")),
                DropdownMenuItem(value: "sugar", child: Text("Sugar")),
                DropdownMenuItem(value: "oil", child: Text("Oil")),
                // Add other commodities as needed
              ],
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCommodity = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),

            // Status Filter
            _buildDropdown(
              context: context,
              label: 'Status Filter',
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: "all", child: Text("All Statuses")),
                DropdownMenuItem(value: "success", child: Text("Success")),
                DropdownMenuItem(value: "pending", child: Text("Pending")),
                DropdownMenuItem(value: "failed", child: Text("Failed")),
              ],
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClearFilters, // Use callback
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApplyFilters(
                      _startDate,
                      _endDate,
                      _selectedCommodity,
                      _selectedStatus,
                    ), // Use callback
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
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to build dropdowns
  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
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
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
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
        ),
      ],
    );
  }

  /// Helper to build the date text fields
  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
    required TextEditingController controller,
  }) {
    return Expanded(
      child: Column(
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
          TextField(
            controller: controller,
            readOnly: true,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: 'Select date',
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: Icon(Icons.calendar_today_outlined,
                  color: Colors.grey[600], size: 20),
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
          ),
        ],
      ),
    );
  }
}