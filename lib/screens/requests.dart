import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/widgets/new_request.dart';
import 'package:public_commodity_distribution/widgets/received_requests.dart';
import 'package:public_commodity_distribution/widgets/sent_requests.dart';
import 'package:intl/intl.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  var _selectedTabIndex = 0;
  String? _searchTerm;
  DateTime? _startDate;
  DateTime? _endDate;

  void _selectTab(int index) {
    if (index == _selectedTabIndex) return;
    setState(() {
      _selectedTabIndex = index;
    });
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _searchTerm ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search by sender'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Sender name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Search'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        _searchTerm = result.isEmpty ? null : result;
      });
    }
  }

  Future<void> _showFilterDialog() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _searchTerm = null;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userRole = prefs.getString('role');
    final bool hasSentTab =
        userRole != 'TradeBureau' && userRole != 'RetailerCooperativeShop';

    if (!hasSentTab && _selectedTabIndex != 0) {
      _selectedTabIndex = 0;
    }

    Widget activePage = ReceivedRequests(
      searchTerm: _searchTerm,
      startDate: _startDate,
      endDate: _endDate,
    );
    if (_selectedTabIndex == 1 && hasSentTab) {
      activePage = SentRequests(
        searchTerm: _searchTerm,
        startDate: _startDate,
        endDate: _endDate,
      );
    }

    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.move_to_inbox_outlined),
        label: 'Received',
        activeIcon: Icon(Icons.move_to_inbox),
      ),
      if (hasSentTab)
        const BottomNavigationBarItem(
          icon: Icon(Icons.send_outlined),
          label: 'Sent',
          activeIcon: Icon(Icons.send),
        ),
    ];

    String dateRangeLabel = '';
    if (_startDate != null && _endDate != null) {
      dateRangeLabel =
          '${DateFormat('yyyy-MM-dd').format(_startDate!)} → ${DateFormat('yyyy-MM-dd').format(_endDate!)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        actions: [
          if (_searchTerm != null || (_startDate != null && _endDate != null))
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: _showSearchDialog,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_alt),
                tooltip: 'Filter by date',
                onPressed: _showFilterDialog,
              ),
              if (dateRangeLabel.isNotEmpty)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dateRangeLabel,
                      style: const TextStyle(fontSize: 8, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: items.length >= 2
          ? BottomNavigationBar(
              onTap: _selectTab,
              currentIndex: _selectedTabIndex,
              items: items,
            )
          : null,
      body: Column(children: [Expanded(child: activePage)]),
      floatingActionButton: (hasSentTab && _selectedTabIndex == 1)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (ctx) => NewRequestScreen()));
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
