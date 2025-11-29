import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:public_commodity_distribution/api/auth.dart';
import 'package:public_commodity_distribution/main.dart';
import 'package:public_commodity_distribution/screens/welcome.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  var _usernameError = '';
  var _passwordError = '';
  var _isLogging = false;

  Future<void> _login() async {
    var username = _usernameController.text.trim();
    var password = _passwordController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _usernameError = 'Username cannot be empty';
      });
      return;
    }

    if (username.length < 4) {
      setState(() {
        _usernameError = 'Username must be at least 4 characters';
      });
      return;
    }
    setState(() {
      _usernameError = '';
    });

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _passwordError = '';
    });

    try {
      print('Logging in .........');
      setState(() {
        _isLogging = true;
      });

      final data = await Auth.login(username: username, password: password);
      final token = data['token']; // ✅ correct way
      await prefs.setString('auth_token', token);
      await prefs.setString('worksAt', data['data']['user']['worksAt']);
      print('user role is.... ${data['data']['user']['role']['name']}');
      await prefs.setString('role', data['data']['user']['role']['name']);
      final userInfo = await Auth.getMe(token: token);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) =>
              HomePage(username: userInfo['data']['name'] ?? 'User'),
        ),
      );
    } catch (e) {
      print('Error: $e.');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Incorrect email or password')));
    } finally {
      setState(() {
        _isLogging = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Image.asset(
                'assets/images/background.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  width: 360,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    // The semi-transparent white color
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.87),
                      width: 1.5,
                    ),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Please login to your account',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _usernameController,
                        onTap: () => _usernameController.text = 'trade',
                        decoration: InputDecoration(
                          labelText: 'Username',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.0,
                            ),
                          ),
                          // The border when the field is focused
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.teal,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      if (_usernameError.isNotEmpty)
                        Text(
                          _usernameError,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),

                      const SizedBox(height: 24),

                      TextField(
                        controller: _passwordController,
                        onTap: () => _passwordController.text = '121223',
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey.shade400,
                              width: 1.0,
                            ),
                          ),
                          // The border when the field is focused
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            borderSide: BorderSide(
                              color: Colors.teal,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      if (_passwordError.isNotEmpty)
                        Text(
                          _passwordError,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _login,
                        // style: ButtonStyle(
                        //   padding: WidgetStatePropertyAll(EdgeInsets.all(24)),
                        // ),
                        child: _isLogging
                            ? CircularProgressIndicator()
                            : Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
