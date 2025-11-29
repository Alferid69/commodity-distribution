import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/transactions_api.dart';
import 'package:public_commodity_distribution/api/retailer_cooperatives_api.dart';
import 'package:public_commodity_distribution/api/retailer_cooperative_shops_api.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/models/transaction_model.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_model.dart';
import 'package:public_commodity_distribution/models/retailer_cooperative_shop_model.dart';
import 'package:public_commodity_distribution/screens/shop_transactions.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // State variables
  bool _isLoading = true;
  String _errorMessage = '';

  // Data for all roles
  List<RetailerCooperative> _cooperatives = [];
  List<RetailerCooperativeShop> _shops = [];
  Map<String, List<RetailerCooperativeShop>> _shopsByCooperative = {};
  Map<String, List<Transaction>> _transactionsByShop = {};

  // Aggregated data for RetailerCooperative
  int _totalTransactions = 0;
  double _totalQuantitySold = 0.0;
  double _totalRevenue = 0.0;

  // User info
  late String _token;
  late String _role;
  late String _worksAt;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    _token = prefs.getString('auth_token') ?? '';
    _role = prefs.getString('role') ?? '';
    _worksAt = prefs.getString('worksAt') ?? '';

    print('User Role: $_role');
    print('Works At: $_worksAt');

    try {
      await _fetchDataBasedOnRole();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDataBasedOnRole() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (_role == 'RetailerCooperativeShop') {
      await _fetchShopTransactions();
    } else if (_role == 'RetailerCooperative') {
      await _fetchCooperativeData();
    } else if (_role == 'TradeBureau' || _role == 'SubCityOffice') {
      await _fetchAllCooperativesAndShops();
    } else if (_role == 'WoredaOffice') {
      await _fetchCooperativesByWoreda();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchShopTransactions() async {
    final data = await TransactionsApi.fetchTransactionsByShopId(
      token: _token,
      shopId: _worksAt,
    );
    final transactions = Transaction.fromJsonList(data);

    // Find the shop
    final shopData =
        await RetailerCooperativeShopsApi.getRetailerCooperativeShopById(
          token: _token,
          id: _worksAt,
        );
    final shop = RetailerCooperativeShop.fromJson(shopData['data']);

    // Navigate to shop transactions screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              ShopTransactionsScreen(shop: shop, allTransactions: transactions),
        ),
      );
    }
  }

  Future<void> _fetchCooperativeData() async {
    // Fetch shops under this cooperative
    final shopsData =
        await RetailerCooperativeShopsApi.getShopsByRetailerCooperativeId(
          token: _token,
          retailerCooperativeId: _worksAt,
        );
    _shops = RetailerCooperativeShop.fromJsonList(shopsData['data'] ?? []);

    // Fetch transactions for all shops
    for (final shop in _shops) {
      final transactionsData = await TransactionsApi.fetchTransactionsByShopId(
        token: _token,
        shopId: shop.id,
      );
      final transactions = Transaction.fromJsonList(transactionsData);
      _transactionsByShop[shop.id] = transactions;

      // Aggregate data
      _totalTransactions += transactions.length;
      _totalQuantitySold += transactions.fold(0.0, (sum, t) => sum + t.amount);
      _totalRevenue += transactions.fold(
        0.0,
        (sum, t) => sum + (t.amount * t.commodity.price),
      );
    }
  }

  Future<void> _fetchAllCooperativesAndShops() async {
    // Fetch all cooperatives
    final cooperativesData =
        await RetailerCooperativesApi.getRetailerCooperatives(token: _token);
    _cooperatives = RetailerCooperative.fromJsonList(
      cooperativesData['data'] ?? [],
    );

    // Fetch all shops
    final shopsData =
        await RetailerCooperativeShopsApi.getRetailerCooperativeShops(
          token: _token,
        );
    _shops = RetailerCooperativeShop.fromJsonList(shopsData['data'] ?? []);

    // Group shops by cooperative
    _shopsByCooperative = {};
    for (final shop in _shops) {
      final coopId = shop.retailerCooperativeId ?? '';
      if (coopId.isNotEmpty) {
        if (!_shopsByCooperative.containsKey(coopId)) {
          _shopsByCooperative[coopId] = [];
        }
        _shopsByCooperative[coopId]!.add(shop);
      }
    }

    // Fetch transactions for all shops
    for (final shop in _shops) {
      final transactionsData = await TransactionsApi.fetchTransactionsByShopId(
        token: _token,
        shopId: shop.id,
      );
      final transactions = Transaction.fromJsonList(transactionsData);
      _transactionsByShop[shop.id] = transactions;
    }
  }

  Future<void> _fetchCooperativesByWoreda() async {
    // Fetch all cooperatives and filter by woredaOffice
    final cooperativesData =
        await RetailerCooperativesApi.getRetailerCooperatives(token: _token);
    final allCooperatives = RetailerCooperative.fromJsonList(
      cooperativesData['data'] ?? [],
    );
    _cooperatives = allCooperatives.where((coop) {
      return coop.woredaOffice == _worksAt;
    }).toList();

    // Fetch shops for these cooperatives
    for (final coop in _cooperatives) {
      final shopsData =
          await RetailerCooperativeShopsApi.getShopsByRetailerCooperativeId(
            token: _token,
            retailerCooperativeId: coop.id,
          );
      final shops = RetailerCooperativeShop.fromJsonList(
        shopsData['data'] ?? [],
      );
      _shops.addAll(shops);
      _shopsByCooperative[coop.id] = shops;

      // Fetch transactions for these shops
      for (final shop in shops) {
        final transactionsData =
            await TransactionsApi.fetchTransactionsByShopId(
              token: _token,
              shopId: shop.id,
            );
        final transactions = Transaction.fromJsonList(transactionsData);
        _transactionsByShop[shop.id] = transactions;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
        body: Center(child: Text('Error: $_errorMessage')),
      );
    }

    if (_role == 'RetailerCooperative') {
      return _buildCooperativeView(context, textTheme);
    } else if (_role == 'TradeBureau' ||
        _role == 'SubCityOffice' ||
        _role == 'WoredaOffice') {
      return _buildAdminView(context, textTheme);
    }

    // Fallback
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      body: const Center(child: Text('No data available')),
    );
  }

  Widget _buildCooperativeView(BuildContext context, TextTheme textTheme) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards (aggregated)
              _buildStatsRow(
                context,
                textTheme,
                transactions: _totalTransactions.toString(),
                qtySold: _totalQuantitySold.toStringAsFixed(2),
                revenue: _totalRevenue.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),

              // Shops List
              _buildSectionHeader(context, textTheme, 'Shops', ''),
              const SizedBox(height: 16),
              _buildShopsList(context, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminView(BuildContext context, TextTheme textTheme) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cooperatives List
              _buildCooperativesList(context, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopsList(BuildContext context, TextTheme textTheme) {
    return Column(
      children: _shops.map((shop) {
        final shopTransactions = _transactionsByShop[shop.id] ?? [];
        final shopTotalTransactions = shopTransactions.length;
        final shopTotalQuantity = shopTransactions.fold(
          0.0,
          (sum, t) => sum + t.amount,
        );
        final shopTotalRevenue = shopTransactions.fold(
          0.0,
          (sum, t) => sum + (t.amount * t.commodity.price),
        );

        return Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.white,
          child: ListTile(
            title: Text(shop.name, style: textTheme.bodyMedium),
            subtitle: Text(
              '$shopTotalTransactions transactions • ${shopTotalQuantity.toStringAsFixed(2)} qty • ${shopTotalRevenue.toStringAsFixed(2)} ETB',
              style: textTheme.bodySmall,
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[500]),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ShopTransactionsScreen(
                    shop: shop,
                    allTransactions: shopTransactions,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCooperativesList(BuildContext context, TextTheme textTheme) {
    return Column(
      children: _cooperatives.map((coop) {
        final shops = _shopsByCooperative[coop.id] ?? [];
        final totalShops = shops.length;
        final totalTransactions = shops.fold(
          0,
          (sum, shop) => sum + (_transactionsByShop[shop.id]?.length ?? 0),
        );
        final totalQuantity = shops.fold(
          0.0,
          (sum, shop) =>
              sum +
              (_transactionsByShop[shop.id]?.fold<double>(
                    0.0,
                    (s, t) => s + t.amount,
                  ) ??
                  0.0),
        );
        final totalRevenue = shops.fold(
          0.0,
          (sum, shop) =>
              sum +
              (_transactionsByShop[shop.id]?.fold<double>(
                    0.0,
                    (s, t) => s + (t.amount * t.commodity.price),
                  ) ??
                  0.0),
        );

        return ExpansionTile(
          title: Text(coop.name, style: textTheme.bodyMedium),
          subtitle: Text(
            '$totalShops shops • $totalTransactions transactions • ${totalQuantity.toStringAsFixed(2)} qty • ${totalRevenue.toStringAsFixed(2)} ETB',
            style: textTheme.bodySmall,
          ),
          children: shops.map((shop) {
            final shopTransactions = _transactionsByShop[shop.id] ?? [];
            final shopTotalTransactions = shopTransactions.length;
            final shopTotalQuantity = shopTransactions.fold(
              0.0,
              (sum, t) => sum + t.amount,
            );
            final shopTotalRevenue = shopTransactions.fold(
              0.0,
              (sum, t) => sum + (t.amount * t.commodity.price),
            );

            return ListTile(
              title: Text(shop.name, style: textTheme.bodySmall),
              subtitle: Text(
                '$shopTotalTransactions transactions • ${shopTotalQuantity.toStringAsFixed(2)} qty • ${shopTotalRevenue.toStringAsFixed(2)} ETB',
                style: textTheme.bodySmall,
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[500]),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ShopTransactionsScreen(
                      shop: shop,
                      allTransactions: shopTransactions,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

/// Builds the row of three statistics cards
Widget _buildStatsRow(
  BuildContext context,
  TextTheme textTheme, {
  String transactions = '0',
  String qtySold = '0.00',
  String revenue = '0.00',
}) {
  return Row(
    children: [
      _buildStatCard(
        context,
        title: 'Transactions',
        value: transactions,
        textTheme: textTheme,
      ),
      const SizedBox(width: 12),
      _buildStatCard(
        context,
        title: 'Qty Sold',
        value: qtySold,
        textTheme: textTheme,
      ),
      const SizedBox(width: 12),
      _buildStatCard(
        context,
        title: 'Revenue',
        value: revenue,
        textTheme: textTheme,
      ),
    ],
  );
}

/// Helper widget for a single statistic card
Widget _buildStatCard(
  BuildContext context, {
  required String title,
  required String value,
  required TextTheme textTheme,
}) {
  return Expanded(
    child: Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

/// Builds the header for a content section (e.g., "Recent Transactions")
Widget _buildSectionHeader(
  BuildContext context,
  TextTheme textTheme,
  String title,
  String actionText,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: textTheme.titleLarge),
      TextButton(
        onPressed: () {
          // Handle "View all"
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
