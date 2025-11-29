import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/screens/login.dart';
import 'package:public_commodity_distribution/widgets/drawer_item.dart';
import 'package:public_commodity_distribution/api/requests_api.dart'; // <--- Add this import
import 'package:public_commodity_distribution/api/allocations_api.dart'; // <--- Add this import

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final String identifier;
  final List<String> allowedRoles;

  DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.identifier,
    required this.allowedRoles,
  });
}

class DrawerSection {
  final String title;
  final List<DrawerMenuItem> items;

  DrawerSection({required this.title, required this.items});
}

class MainDrawer extends StatefulWidget {
  final String username;
  final void Function(String identifier) onSelectScreen;

  const MainDrawer({
    super.key,
    required this.username,
    required this.onSelectScreen,
  });

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  int _unreadRequests = 0;
  bool _loadingUnread = true;
  int _pendingAllocations = 0;
  bool _loadingPendingAllocations = true;

  @override
  void initState() {
    super.initState();
    _fetchUnreadRequests();
    _fetchPendingAllocations();
  }

  Future<void> _fetchPendingAllocations() async {
    setState(() => _loadingPendingAllocations = true);
    final token = prefs.getString('auth_token');
    final worksAt = prefs.getString('worksAt');
    final userRole = prefs.getString('role');
    // Only receive allocations by 'to/id'
    final allocatedToRoles = ['RetailerCooperative', 'RetailerCooperativeShop'];
    if (token != null &&
        worksAt != null &&
        allocatedToRoles.contains(userRole)) {
      final count = await AllocationsApi.getPendingAllocationsCount(
        token: token,
        id: worksAt,
      );
      if (!mounted) return;
      setState(() {
        _pendingAllocations = count;
        _loadingPendingAllocations = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _loadingPendingAllocations = false);
    }
  }

  Future<void> _fetchUnreadRequests() async {
    setState(() => _loadingUnread = true);
    final token = prefs.getString('auth_token');
    final worksAt = prefs.getString('worksAt');
    if (token != null && worksAt != null) {
      final count = await RequestsApi.getUnreadReceivedRequestsCount(
        token: token,
        worksAt: worksAt,
      );
      if (!mounted) return; // <--- add this check!
      setState(() {
        _unreadRequests = count;
        _loadingUnread = false;
      });
    } else {
      if (!mounted) return; // <--- add this check!
      setState(() => _loadingUnread = false);
    }
  }

  void _logout(BuildContext ctx) async {
    await prefs.remove('auth_token');
    await prefs.remove('worksAt');
    Navigator.of(ctx).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = prefs.getString('role') ?? 'User';

    final List<DrawerSection> sections = [
      DrawerSection(
        title: 'DASHBOARD',
        items: [
          DrawerMenuItem(
            icon: Icons.home,
            title: 'Welcome',
            identifier: 'home',
            allowedRoles: [
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
              'RetailerCooperativeShop',
            ],
          ),
        ],
      ),
      DrawerSection(
        title: 'DISTRIBUTION',
        items: [
          DrawerMenuItem(
            icon: Icons.receipt_long,
            title: 'Transactions',
            identifier: 'transactions',
            allowedRoles: [
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
              'RetailerCooperativeShop',
            ],
          ),
          DrawerMenuItem(
            icon: Icons.inventory_2,
            title: 'Inventory',
            identifier: 'inventory',
            allowedRoles: [
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
              'RetailerCooperativeShop',
            ],
          ),
          DrawerMenuItem(
            icon: Icons.assignment,
            title: 'Requests',
            identifier: 'requests',
            allowedRoles: [
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
            ],
          ),
          DrawerMenuItem(
            icon: Icons.dashboard_customize,
            title: 'Allocations',
            identifier: 'allocations',
            allowedRoles: [
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
            ],
          ),
          DrawerMenuItem(
            icon: Icons.local_mall,
            title: 'Commodities',
            identifier: 'commodities',
            allowedRoles: [
              'Admin',
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
              'RetailerCooperativeShop',
            ],
          ),
          DrawerMenuItem(
            icon: Icons.local_shipping,
            title: 'Distribution',
            identifier: 'distributions',
            allowedRoles: ['RetailerCooperative', 'RetailerCooperativeShop'],
          ),
        ],
      ),
      DrawerSection(
        title: 'MANAGEMENT',
        items: [
          DrawerMenuItem(
            icon: Icons.people,
            title: 'Customers',
            identifier: 'customers',
            allowedRoles: ['WoredaOffice', 'SubCityOffice', 'TradeBureau'],
          ),
          DrawerMenuItem(
            icon: Icons.shop_2,
            title: 'Retailer Cooperatives',
            identifier: 'retailer_cooperatives',
            allowedRoles: [
              'Admin',
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
            ],
          ),
          DrawerMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            identifier: 'settings',
            allowedRoles: [
              'WoredaOffice',
              'SubCityOffice',
              'TradeBureau',
              'RetailerCooperative',
              'RetailerCooperativeShop',
            ],
          ),
        ],
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  Expanded(child: Image.asset('assets/images/favicon.ico')),
                  const SizedBox(width: 18),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Commodity Distribution',
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Text(
                        userRole,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final section in sections) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ...section.items
                        .where((item) => item.allowedRoles.contains(userRole))
                        .map(
                          (item) => DrawerItem(
                            icon: item.icon,
                            title: item.title,
                            badgeCount: item.identifier == 'requests'
                                ? (_loadingUnread ? -1 : _unreadRequests)
                                : item.identifier == 'allocations'
                                ? (_loadingPendingAllocations
                                      ? -1
                                      : _pendingAllocations)
                                : 0,
                            onTap: () => widget.onSelectScreen(item.identifier),
                          ),
                        ),
                  ],
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Admin User'),
              subtitle: Text(widget.username),
              trailing: IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
