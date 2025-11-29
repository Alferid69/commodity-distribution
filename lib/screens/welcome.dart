import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/screens/allocations.dart';
import 'package:public_commodity_distribution/screens/customers.dart';
import 'package:public_commodity_distribution/screens/distributions.dart';
import 'package:public_commodity_distribution/screens/inventory.dart';
import 'package:public_commodity_distribution/screens/requests.dart';
import 'package:public_commodity_distribution/screens/transactions.dart';
import 'package:public_commodity_distribution/widgets/feature_card.dart';
import 'package:public_commodity_distribution/widgets/main_drawer.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  String _currentScreen = 'home';

  void _setScreen(String identifier) {
    Navigator.of(context).pop();
    if (_currentScreen == identifier) {
      return;
    }

    Widget nextScreen;
    switch (identifier) {
      case 'transactions':
        nextScreen = const TransactionsScreen();
        break;
      case 'home':
        nextScreen = HomePage(username: username);
        break;
      case 'customers':
        nextScreen = const CustomersScreen();
        break;
      case 'requests':
        nextScreen = const RequestsScreen();
        break;
      case 'allocations':
        nextScreen = const AllocationsScreen();
        break;
      case 'inventory':
        nextScreen = const InventoryScreen();
        break;
      case 'distributions':
        nextScreen = const DistributionsScreen();
        break;
      default:
        // It's good practice to have a default case
        return;
    }

    _currentScreen = identifier;

    // Use pushReplacement to replace the current screen in the stack
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => nextScreen));
    // ).pushReplacement(MaterialPageRoute(builder: (ctx) => nextScreen));

    setState(() {
      _currentScreen = 'home'; // resets to the home screen when returning
    });
  }

  @override
  void initState() {
    super.initState();
    username = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Hello $username',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt, color: Colors.black54),
            onPressed: () {
              /* TODO: Handle action tap */
            },
          ),
          TextButton(
            onPressed: () {
              /* TODO: Handle language change */
            },
            child: const Text('us EN'),
          ),
        ],
      ),

      drawer: MainDrawer(username: username, onSelectScreen: _setScreen),

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 1. Welcome Card with Background Image
          _buildWelcomeCard(),

          const SizedBox(height: 32.0),

          // 2. "Your Digital Distribution Hub" Section
          Text(
            'Your Digital Distribution Hub',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'This Comprehensive System Is Designed To Streamline The Distribution Process, Enhance Customer Service, And Provide Valuable Insights For Better Decision Making In Bole Subcity.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: 32.0),

          // 3. Reusable Feature Cards
          FeatureCard(
            icon: Icons.people_outline,
            title: 'Customer Management',
            description:
                'Register And Manage Customer Information With Ease And Accuracy',
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 24.0),
          FeatureCard(
            icon: Icons.inventory_2_outlined,
            title: 'Distribution Tracking',
            description:
                'Monitor And Track All Distribution Activities In Real-Time',
            iconColor: Colors.green,
          ),
          const SizedBox(height: 24.0),
          FeatureCard(
            icon: Icons.analytics_outlined,
            title: 'Analytics & Reports',
            description:
                'Generate Detailed Reports And Analytics For Informed Decision Making',
            iconColor: Colors.deepPurpleAccent,
          ),
          // Add more FeatureCard widgets here for other sections
        ],
      ),
    );
  }
}

Widget _buildWelcomeCard() {
  return Card(
    clipBehavior:
        Clip.antiAlias, // Ensures the image respects the rounded corners
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    elevation: 4.0,
    child: Stack(
      alignment: Alignment.bottomLeft,
      children: [
        // Background Image
        Image.asset(
          'assets/images/background.jpeg', // Your image file
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        // Dark overlay for text readability
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.center,
            ),
          ),
        ),
        // Text Content
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome To Bole Subcity\nDistribution Management\nSystem',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Efficiently Managing Commodity Distribution\nAnd Customer Services For The Community\nOf Bole Subcity',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
