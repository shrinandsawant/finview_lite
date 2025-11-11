import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleTheme;

  const LoginScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;
  bool _showPassword = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordValidity);
  }

  void _checkPasswordValidity() {
    final password = _passwordController.text;
    final isValid =
        password.length >= 6 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#\$&*~]').hasMatch(password);

    if (isValid != _isPasswordValid) {
      setState(() => _isPasswordValid = isValid);
    }
  }

  Future<bool> _validateUsername(String username) async {
    try {
      final jsonString = await rootBundle.loadString('assets/portfolio.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return username == (data['user'] as String);
    } catch (e) {
      return false;
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter both username and password")),
      );
      return;
    }

    final isValidUser = await _validateUsername(username);
    if (!isValidUser) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid username")));
      return;
    }

    if (!_isPasswordValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password is invalid")));
      return;
    }

    setState(() => _isLoggingIn = true);
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', true);
    await prefs.setString('userName', username);
    await prefs.setBool('isDarkMode', widget.isDarkMode);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');

    setState(() => _isLoggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = _isPasswordValid
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'FinView Lite',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      onSubmitted: (_) {
                        if (_isPasswordValid) _login();
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: (_isPasswordValid && !_isLoggingIn)
                            ? _login
                            : null,
                        child: _isLoggingIn
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
