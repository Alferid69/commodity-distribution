import 'package:flutter/material.dart';
import 'package:public_commodity_distribution/api/auth.dart';
import 'package:public_commodity_distribution/screens/welcome.dart';
import 'package:public_commodity_distribution/screens/login.dart';
import 'package:public_commodity_distribution/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferencesWithCache prefs;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isLoggedInFuture;
  late String _username = 'User';

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _checkLogin();
  }

  Future<bool> _checkLogin() async {
    final token = prefs.getString('auth_token');
    // Fetch username now so HomePage can receive it immediately once
    // the login check completes. _getUsername will return 'User' if
    // token is null or fetching fails.
    try {
      _username = await _getUsername();
    } catch (_) {
      _username = 'User';
    }
    return await Auth.isLoggedIn(token: token ?? '');
  }

  Future<String> _getUsername() async {
    final token = prefs.getString('auth_token');
    if (token != null) {
      print('getting username from main...');
      final userInfo = await Auth.getMe(token: token);
      return userInfo['data']['name'] ?? 'User';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme,
      home: FutureBuilder<bool>(
        future: _isLoggedInFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Error checking login status')),
            );
          } else {
            final isLoggedIn = snapshot.data ?? false;
            return isLoggedIn
                ? HomePage(username: _username)
                : const LoginScreen();
          }
        },
      ),
    );
  }
}
