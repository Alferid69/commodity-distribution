import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/requests_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/request_model.dart';
import 'package:public_commodity_distribution/widgets/request_card.dart';

class SentRequests extends StatefulWidget {
  final String? searchTerm;
  final DateTime? startDate;
  final DateTime? endDate;
  const SentRequests({
    super.key,
    this.searchTerm,
    this.startDate,
    this.endDate,
  });

  @override
  State<SentRequests> createState() => _SentRequestsState();
}

class _SentRequestsState extends State<SentRequests> {
  late Future<bool> _fetchSentRequestsFuture;
  final List<Request> _allRequests = [];
  final List<Request> _sentRequests = [];

  void _applySearchFilter() {
    List<Request> filtered = _allRequests;
    if (widget.searchTerm != null && widget.searchTerm!.trim().isNotEmpty) {
      final term = widget.searchTerm!.toLowerCase();
      filtered = filtered
          .where((r) => r.to.name.toLowerCase().contains(term))
          .toList();
    }
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _sentRequests
        ..clear()
        ..addAll(filtered);
    });
  }

  Future<bool> _getSentRequests() async {
    try {
      final token = prefs.getString('auth_token');
      final worksAt = prefs.getString('worksAt');
      if (token == null || worksAt == null) {
        print('Token or worksAt is null');
        return false;
      }
      final data = await RequestsApi.getSentRequests(
        token,
        worksAt,
        start: widget.startDate == null
            ? null
            : widget.startDate!.toIso8601String().split('T')[0],
        end: widget.endDate == null
            ? null
            : widget.endDate!.toIso8601String().split('T')[0],
      );
      final requests = Request.fromJsonList(data['data']['alerts']);
      _allRequests
        ..clear()
        ..addAll(requests);
      _applySearchFilter();
      return true;
    } catch (e) {
      print('Error getting sent requests: $e');
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSentRequestsFuture = _getSentRequests();
  }

  @override
  void didUpdateWidget(covariant SentRequests oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch only if start or end date changes
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _fetchSentRequestsFuture = _getSentRequests();
    } else if (oldWidget.searchTerm != widget.searchTerm) {
      // Filter in memory for search
      _applySearchFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Request> sortedRequests = _sentRequests;
    return FutureBuilder(
      future: _fetchSentRequestsFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('An error occurred: \u001b[35m"'));
        } else if (sortedRequests.isEmpty) {
          return const Center(child: Text('No data found!'));
        } else {
          return ListView.builder(
            itemCount: sortedRequests.length,
            itemBuilder: (ctx, index) =>
                RequestCard(request: sortedRequests[index], isSent: true),
          );
        }
      },
    );
  }
}
