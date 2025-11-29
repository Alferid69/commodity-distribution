import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/requests_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/request_model.dart';
import 'package:public_commodity_distribution/widgets/request_card.dart';

class ReceivedRequests extends StatefulWidget {
  final String? searchTerm;
  final DateTime? startDate;
  final DateTime? endDate;
  const ReceivedRequests({
    super.key,
    this.searchTerm,
    this.startDate,
    this.endDate,
  });

  @override
  State<ReceivedRequests> createState() => _ReceivedRequestsState();
}

class _ReceivedRequestsState extends State<ReceivedRequests> {
  late Future<bool> _fetchReceivedRequestsFuture;
  final List<Request> _allRequests = [];
  final List<Request> _receivedRequests = [];
  final token = prefs.getString('auth_token');

  void _applySearchFilter() {
    List<Request> filtered = _allRequests;
    if (widget.searchTerm != null && widget.searchTerm!.trim().isNotEmpty) {
      final term = widget.searchTerm!.toLowerCase();
      filtered = filtered
          .where((r) => r.from.name.toLowerCase().contains(term))
          .toList();
    }
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _receivedRequests
        ..clear()
        ..addAll(filtered);
    });
  }

  Future<bool> _getReceivedRequests() async {
    try {
      final worksAt = prefs.getString('worksAt');
      debugPrint(
        'DEBUG: _getReceivedRequests called with token=$token worksAt=$worksAt start=${widget.startDate} end=${widget.endDate}',
      );
      if (token == null || worksAt == null) {
        debugPrint('Token or worksAt is null');
        return false;
      }
      final data = await RequestsApi.getReceivedRequests(
        token!,
        worksAt,
        start: widget.startDate == null
            ? null
            : widget.startDate!.toIso8601String().split('T')[0],
        end: widget.endDate == null
            ? null
            : widget.endDate!.toIso8601String().split('T')[0],
      );
      if (data == null) {
        return false;
      }
      final alerts = data['data']['alerts'];
      final requests = Request.fromJsonList(alerts);
      _allRequests
        ..clear()
        ..addAll(requests);
      _applySearchFilter();
      return true;
    } catch (e, st) {
      debugPrint('Error getting received requests: $e\n$st');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReceivedRequestsFuture = _getReceivedRequests();
  }

  @override
  void didUpdateWidget(covariant ReceivedRequests oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch only if start or end date changes
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _fetchReceivedRequestsFuture = _getReceivedRequests();
    } else if (oldWidget.searchTerm != widget.searchTerm) {
      // Filter in memory for search
      _applySearchFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchReceivedRequestsFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('An error occurred:  [35m")'));
        } else if (_receivedRequests.isEmpty) {
          return const Center(child: Text('No data found!'));
        } else {
          return ListView.builder(
            itemCount: _receivedRequests.length,
            itemBuilder: (ctx, index) =>
                RequestCard(request: _receivedRequests[index], isSent: false),
          );
        }
      },
    );
  }
}
