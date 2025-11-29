import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_shop_model.dart';
import 'package:public_commodity_distribution/models/transaction_model.dart';
import 'package:public_commodity_distribution/screens/qr_scanner.dart';
import 'package:public_commodity_distribution/widgets/filter_transactions.dart';

/// A dynamic screen that displays and filters transactions
/// using the clean dashboard UI.
class ShopTransactionsScreen extends StatefulWidget {
  final RetailerCooperativeShop shop;
  final List<Transaction> allTransactions;

  const ShopTransactionsScreen({
    super.key,
    required this.shop,
    required this.allTransactions,
  });

  @override
  State<ShopTransactionsScreen> createState() => _ShopTransactionsScreenState();
}

class _ShopTransactionsScreenState extends State<ShopTransactionsScreen> {
  // --- State Variables ---

  // Filter state
  String _searchText = "";
  String _selectedCommodity = "all";
  String _selectedStatus = "all";
  DateTime? _startDate;
  DateTime? _endDate;

  // Derived state (calculated from filters)
  List<Transaction> _filteredData = [];
  int _totalTransactions = 0;
  double _totalQuantitySold = 0.0;
  double _totalRevenue = 0.0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Run initial filter on the full dataset
    _runFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Runs all filter logic and updates the UI state
  void _runFilters() {
    List<Transaction> data = widget.allTransactions;

    // Filter by date (if applied)
    data = data.where((transaction) {
      if (_startDate != null && transaction.createdAt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null) {
        // Add 1 day to endDate to make it inclusive
        final inclusiveEndDate = _endDate!.add(const Duration(days: 1));
        if (transaction.createdAt.isAfter(inclusiveEndDate)) {
          return false;
        }
      }
      return true;
    }).toList();

    // Filter by search, commodity, and status
    data = data.where((transaction) {
      final matchesSearch = _searchText.isEmpty ||
          transaction.customer.name
              .toLowerCase()
              .contains(_searchText.toLowerCase());
      final matchesCommodity = _selectedCommodity == "all" ||
          transaction.commodity.name.toLowerCase() == _selectedCommodity;
      final matchesStatus = _selectedStatus == "all" ||
          transaction.status.toLowerCase() == _selectedStatus;

      return matchesSearch && matchesCommodity && matchesStatus;
    }).toList();

    // Sort by date (newest first)
    data.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Calculate summaries
    final int totalTransactions = data.length;
    final double totalQuantitySold = data.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );
    final double totalRevenue = data.fold(
      0.0,
      (sum, t) => sum + (t.amount * t.commodity.price),
    );

    // Update the state to rebuild the UI
    setState(() {
      _filteredData = data;
      _totalTransactions = totalTransactions;
      _totalQuantitySold = totalQuantitySold;
      _totalRevenue = totalRevenue;
    });
  }

  bool get _isAnyFilterApplied =>
      _searchText.isNotEmpty ||
      _selectedCommodity != "all" ||
      _selectedStatus != "all" ||
      _startDate != null ||
      _endDate != null;

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // Use a back button instead of dashboard icon
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.shop.name), // Show shop name in AppBar
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.grey[700]),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.person_outline_rounded, color: Colors.grey[700]),
            onPressed: () {
              // Handle profile
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards (now dynamic)
              _buildStatsRow(context, textTheme),
              const SizedBox(height: 24),

              // Search Bar (now dynamic)
              _buildSearchBar(context, textTheme),
              const SizedBox(height: 24),

              // Recent Transactions Header
              _buildSectionHeader(context, textTheme, 'All Transactions', 'Export'),
              const SizedBox(height: 16),

              // Transaction List (now dynamic)
              _buildTransactionList(context, textTheme),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => QRScannerScreen(),
            ),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  // --- Helper Widgets ---

  /// Builds the row of three statistics cards
  Widget _buildStatsRow(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        _buildStatCard(
          context,
          title: 'Transactions',
          value: _totalTransactions.toString(), // Dynamic data
          textTheme: textTheme,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          title: 'Qty Sold',
          value: _totalQuantitySold.toStringAsFixed(2), // Dynamic data
          textTheme: textTheme,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          context,
          title: 'Revenue',
          value: _totalRevenue.toStringAsFixed(2), // Dynamic data
          textTheme: textTheme,
        ),
      ],
    );
  }

  /// Helper widget for a single statistic card
  Widget _buildStatCard(BuildContext context,
      {required String title,
      required String value,
      required TextTheme textTheme}) {
    return Expanded(
      child: Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.labelMedium),
              const SizedBox(height: 8),
              Text(value, style: textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the search bar and filter button
  Widget _buildSearchBar(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
              _runFilters();
            },
            decoration: InputDecoration(
              hintText: 'Search by customer name',
              hintStyle: textTheme.bodySmall,
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
            onPressed: () {
              // Show the updated filter sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FilterTransactionsSheet(
                  initialCommodity: _selectedCommodity,
                  initialStatus: _selectedStatus,
                  initialStartDate: _startDate,
                  initialEndDate: _endDate,
                  onApplyFilters:
                      (newStart, newEnd, newCommodity, newStatus) {
                    setState(() {
                      _startDate = newStart;
                      _endDate = newEnd;
                      _selectedCommodity = newCommodity;
                      _selectedStatus = newStatus;
                    });
                    _runFilters();
                    Navigator.of(context).pop();
                  },
                  onClearFilters: (){
                    _searchController.clear();
                    setState(() {
                      _searchText = "";
                      _selectedCommodity = "all";
                      _selectedStatus = "all";
                      _startDate = null;
                      _endDate = null;
                    });
                    _runFilters();
                    Navigator.of(context).pop(); // Close modal
                  },
                  
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the header for a content section
  Widget _buildSectionHeader(
      BuildContext context, TextTheme textTheme, String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: textTheme.titleLarge),
        TextButton(
          onPressed: () {
            // TODO: Handle Export
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Export logic not implemented.")),
            );
          },
          child: Text(
            actionText,
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the list of transaction items dynamically
  Widget _buildTransactionList(BuildContext context, TextTheme textTheme) {
    if (_filteredData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _isAnyFilterApplied
                ? "No transactions match your filters."
                : "No transactions found.",
            style: textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: _filteredData.map((transaction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildTransactionItem(
            context: context,
            textTheme: textTheme,
            icon: _getStatusIcon(transaction.status),
            iconBgColor: _getStatusBgColor(transaction.status),
            iconColor: _getStatusIconColor(transaction.status),
            title: transaction.customer.name,
            date: DateFormat.yMd().add_jm().format(transaction.createdAt),
            trailingTitle:
                '${transaction.amount} ${transaction.commodity.name}',
            trailingSubtitle: _getTrailingSubtitle(transaction),
            trailingSubtitleColor: _getTrailingSubtitleColor(transaction),
          ),
        );
      }).toList(),
    );
  }

  /// Helper widget for a single transaction item
  Widget _buildTransactionItem({
    required BuildContext context,
    required TextTheme textTheme,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String date,
    required String trailingTitle,
    required String trailingSubtitle,
    required Color trailingSubtitleColor,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(date, style: textTheme.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(trailingTitle, style: textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  trailingSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: trailingSubtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Status-based Helpers ---

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "success":
        return Icons.check;
      case "pending":
        return Icons.hourglass_empty_rounded;
      default: // "failed" or other
        return Icons.close;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case "success":
        return Colors.green.shade100;
      case "pending":
        return Colors.amber.shade100;
      default:
        return Colors.red.shade100;
    }
  }

  Color _getStatusIconColor(String status) {
    switch (status) {
      case "success":
        return Colors.green.shade700;
      case "pending":
        return Colors.amber.shade800;
      default:
        return Colors.red.shade700;
    }
  }

  String _getTrailingSubtitle(Transaction transaction) {
    if (transaction.status == "success") {
      final total = transaction.amount * transaction.commodity.price;
      return "${total.toStringAsFixed(2)} ETB";
    }
    return transaction.status; // "Pending" or "Failed"
  }

  Color _getTrailingSubtitleColor(Transaction transaction) {
    if (transaction.status == "success") {
      return Colors.grey.shade600;
    }
    return _getStatusIconColor(transaction.status);
  }
}