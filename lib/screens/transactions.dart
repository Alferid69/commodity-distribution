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

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  bool _isLoading = true;
  String _errorMessage = '';

  // Data for all roles
  List<RetailerCooperative> _cooperatives = [];
  List<RetailerCooperativeShop> _shops = [];
  Map<String, List<RetailerCooperativeShop>> _shopsByCooperative = {};
  final Map<String, List<Transaction>> _transactionsByShop = {};

  // Aggregated data for RetailerCooperative
  int _totalTransactions = 0;
  double _totalQuantitySold = 0.0;
  double _totalRevenue = 0.0;

  // User info
  late String _token;
  late String _role;
  late String _worksAt;

  // Animation controller for Skeleton/Shimmer effect
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    // Initialize shimmer controller for pulsing effect
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initializeData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _initializeData() async {
    _token = prefs.getString('auth_token') ?? '';
    _role = prefs.getString('role') ?? '';
    _worksAt = prefs.getString('worksAt') ?? '';

    debugPrint('User Role: $_role');
    debugPrint('Works At: $_worksAt');

    try {
      await _fetchDataBasedOnRole();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
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

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchShopTransactions() async {
    final results = await Future.wait([
      TransactionsApi.fetchTransactionsByShopId(
        token: _token,
        shopId: _worksAt,
      ),
      RetailerCooperativeShopsApi.getRetailerCooperativeShopById(
        token: _token,
        id: _worksAt,
      ),
    ]);

    final transactions = Transaction.fromJsonList(results[0] as List<dynamic>);
    final shopData = results[1] as Map<String, dynamic>;
    final shop = RetailerCooperativeShop.fromJson(shopData['data']);

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
    final shopsData =
        await RetailerCooperativeShopsApi.getShopsByRetailerCooperativeId(
          token: _token,
          retailerCooperativeId: _worksAt,
        );
    _shops = RetailerCooperativeShop.fromJsonList(shopsData['data'] ?? []);

    final transactionFutures = _shops.map((shop) {
      return TransactionsApi.fetchTransactionsByShopId(
        token: _token,
        shopId: shop.id,
      );
    }).toList();

    final results = await Future.wait(transactionFutures);

    for (int i = 0; i < _shops.length; i++) {
      final shop = _shops[i];
      final transactionsData = results[i];
      final transactions = Transaction.fromJsonList(transactionsData);

      _transactionsByShop[shop.id] = transactions;

      _totalTransactions += transactions.length;
      _totalQuantitySold += transactions.fold(0.0, (sum, t) => sum + t.amount);
      _totalRevenue += transactions.fold(
        0.0,
        (sum, t) => sum + (t.amount * t.commodity.price),
      );
    }
  }

  Future<void> _fetchAllCooperativesAndShops() async {
    final initialResults = await Future.wait([
      RetailerCooperativesApi.getRetailerCooperatives(token: _token),
      RetailerCooperativeShopsApi.getRetailerCooperativeShops(token: _token),
    ]);

    final cooperativesData = initialResults[0] as Map<String, dynamic>;
    final shopsData = initialResults[1] as Map<String, dynamic>;

    _cooperatives = RetailerCooperative.fromJsonList(
      cooperativesData['data'] ?? [],
    );
    _shops = RetailerCooperativeShop.fromJsonList(shopsData['data'] ?? []);

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

    final transactionFutures = _shops.map((shop) {
      return TransactionsApi.fetchTransactionsByShopId(
        token: _token,
        shopId: shop.id,
      );
    }).toList();

    final results = await Future.wait(transactionFutures);

    for (int i = 0; i < _shops.length; i++) {
      final shop = _shops[i];
      final transactions = Transaction.fromJsonList(results[i]);
      _transactionsByShop[shop.id] = transactions;
    }
  }

  Future<void> _fetchCooperativesByWoreda() async {
    final cooperativesData =
        await RetailerCooperativesApi.getRetailerCooperatives(token: _token);
    final allCooperatives = RetailerCooperative.fromJsonList(
      cooperativesData['data'] ?? [],
    );

    _cooperatives = allCooperatives.where((coop) {
      return coop.woredaOffice == _worksAt;
    }).toList();

    final shopFutures = _cooperatives.map((coop) {
      return RetailerCooperativeShopsApi.getShopsByRetailerCooperativeId(
        token: _token,
        retailerCooperativeId: coop.id,
      );
    }).toList();

    final shopResults = await Future.wait(shopFutures);

    List<Future<List<dynamic>>> transactionFutures = [];
    List<RetailerCooperativeShop> orderedShopsForTransactions = [];

    for (int i = 0; i < _cooperatives.length; i++) {
      final coop = _cooperatives[i];
      final shopsData = shopResults[i];
      final shops = RetailerCooperativeShop.fromJsonList(
        shopsData['data'] ?? [],
      );

      _shops.addAll(shops);
      _shopsByCooperative[coop.id] = shops;

      for (final shop in shops) {
        orderedShopsForTransactions.add(shop);
        transactionFutures.add(
          TransactionsApi.fetchTransactionsByShopId(
            token: _token,
            shopId: shop.id,
          ),
        );
      }
    }

    if (transactionFutures.isNotEmpty) {
      final transactionResults = await Future.wait(transactionFutures);

      for (int i = 0; i < orderedShopsForTransactions.length; i++) {
        final shop = orderedShopsForTransactions[i];
        final transactions = Transaction.fromJsonList(transactionResults[i]);
        _transactionsByShop[shop.id] = transactions;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
        // Use the new Skeleton Builder here
        body: _buildLoadingSkeleton(),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      body: const Center(child: Text('No data available')),
    );
  }

  /// Builds a skeleton loader mimicking the actual content
  Widget _buildLoadingSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        // Create a pulsing opacity effect
        final opacity = 0.3 + (_shimmerController.value * 0.4); // 0.3 to 0.7

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Stats Row Skeleton
                Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        height: 80,
                        margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(opacity),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Section Header Skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 120,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. List of Shop Cards Skeleton
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6, // Show 6 fake items
                  itemBuilder: (context, index) {
                    return Container(
                      height: 140, // Approximate height of our shop card
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header (Name + ID)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 180,
                                    height: 16,
                                    color: Colors.grey.withOpacity(opacity),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 100,
                                    height: 12,
                                    color: Colors.grey.withOpacity(opacity),
                                  ),
                                ],
                              ),
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.withOpacity(opacity),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Divider(),
                          const Spacer(),
                          // Stats row inside card
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              3,
                              (i) => Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 10,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      color: Colors.grey.withOpacity(opacity),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 14,
                                      color: Colors.grey.withOpacity(opacity),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCooperativeView(BuildContext context, TextTheme textTheme) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(
                context,
                textTheme,
                transactions: _totalTransactions.toString(),
                qtySold: _totalQuantitySold.toStringAsFixed(2),
                revenue: _totalRevenue.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, textTheme, 'My Shops', ''),
              const SizedBox(height: 12),
              _buildShopsList(context, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminView(BuildContext context, TextTheme textTheme) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Transactions'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildCooperativesList(context, textTheme)],
          ),
        ),
      ),
    );
  }

  Widget _buildShopsList(BuildContext context, TextTheme textTheme) {
    if (_shops.isEmpty) {
      return const Center(child: Text("No shops assigned."));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _shops.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final shop = _shops[index];
        final shopTransactions = _transactionsByShop[shop.id] ?? [];
        return _buildEnhancedShopCard(
          context,
          textTheme,
          shop,
          shopTransactions,
        );
      },
    );
  }

  Widget _buildCooperativesList(BuildContext context, TextTheme textTheme) {
    if (_cooperatives.isEmpty) {
      return const Center(child: Text("No cooperatives found."));
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _cooperatives.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final coop = _cooperatives[index];
        final shops = _shopsByCooperative[coop.id] ?? [];

        final totalShops = shops.length;
        double totalRev = 0.0;

        for (var s in shops) {
          final trans = _transactionsByShop[s.id] ?? [];
          totalRev += trans.fold(
            0.0,
            (sum, t) => sum + (t.amount * t.commodity.price),
          );
        }

        return Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                coop.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.storefront, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('$totalShops Shops', style: textTheme.bodySmall),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${totalRev.toStringAsFixed(0)} ETB',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                Container(
                  color: Colors.grey[50],
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: shops.map((shop) {
                      final shopTransactions =
                          _transactionsByShop[shop.id] ?? [];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildEnhancedShopCard(
                          context,
                          textTheme,
                          shop,
                          shopTransactions,
                          isNested: true,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _buildEnhancedShopCard(
  BuildContext context,
  TextTheme textTheme,
  RetailerCooperativeShop shop,
  List<Transaction> transactions, {
  bool isNested = false,
}) {
  final count = transactions.length;
  final qty = transactions.fold(0.0, (sum, t) => sum + t.amount);
  final rev = transactions.fold(
    0.0,
    (sum, t) => sum + (t.amount * t.commodity.price),
  );

  return Card(
    elevation: isNested ? 0 : 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: isNested
          ? BorderSide(color: Colors.grey.shade300)
          : BorderSide.none,
    ),
    color: Colors.white,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ShopTransactionsScreen(
              shop: shop,
              allTransactions: transactions,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (shop.retailerCooperativeId != null)
                        Text(
                          'ID: ${shop.id.substring(0, 8)}...',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 20, color: Colors.blue[700]),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMiniStat(
                  textTheme,
                  'Trans',
                  '$count',
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _buildMiniStat(
                  textTheme,
                  'Sold',
                  qty.toStringAsFixed(1),
                  Icons.inventory_2_outlined,
                  Colors.orange,
                ),
                _buildMiniStat(
                  textTheme,
                  'Rev (ETB)',
                  rev.toStringAsFixed(0),
                  Icons.monetization_on_outlined,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMiniStat(
  TextTheme textTheme,
  String label,
  String value,
  IconData icon,
  MaterialColor color,
) {
  return Expanded(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color[800],
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

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
        icon: Icons.receipt,
        color: Colors.blue,
        textTheme: textTheme,
      ),
      const SizedBox(width: 12),
      _buildStatCard(
        context,
        title: 'Qty Sold',
        value: qtySold,
        icon: Icons.inventory,
        color: Colors.orange,
        textTheme: textTheme,
      ),
      const SizedBox(width: 12),
      _buildStatCard(
        context,
        title: 'Revenue',
        value: revenue,
        icon: Icons.attach_money,
        color: Colors.green,
        textTheme: textTheme,
      ),
    ],
  );
}

Widget _buildStatCard(
  BuildContext context, {
  required String title,
  required String value,
  required IconData icon,
  required MaterialColor color,
  required TextTheme textTheme,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color.shade700),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSectionHeader(
  BuildContext context,
  TextTheme textTheme,
  String title,
  String actionText,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      if (actionText.isNotEmpty)
        TextButton(
          onPressed: () {},
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
