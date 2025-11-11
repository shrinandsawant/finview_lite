import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final Function toggleTheme;
  final bool isDarkMode;
  final Future<void> Function() onPortfolioReload;

  const Header({
    required this.toggleTheme,
    required this.isDarkMode,
    required this.onPortfolioReload,
    super.key,
  });

  @override
  _HeaderState createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _HeaderState extends State<Header> {
  bool isRefreshing = false;
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName') ?? 'User';
    if (!mounted) return;
    setState(() => userName = name);
  }

  Future<void> _handleRefresh() async {
    setState(() => isRefreshing = true);
    try {
      await widget.onPortfolioReload();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Portfolio refreshed!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to refresh: $e")));
    }
    setState(() => isRefreshing = false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', false);
    await prefs.remove('userName');
    if (!mounted) return;

    // Navigate to login screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF8DC63F), // keep same color always
      foregroundColor: Colors.black, // text/icons remain visible
      elevation: 2,
      title: const Text(
        'FinView Lite',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Text(
              'Hello, $userName',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.black),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
        IconButton(
          icon: Icon(
            widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Colors.black,
          ),
          tooltip: 'Toggle Dark Mode',
          onPressed: () => widget.toggleTheme(),
        ),
        IconButton(
          icon: AnimatedRotation(
            turns: isRefreshing ? 1.0 : 0.0,
            duration: const Duration(seconds: 1),
            child: const Icon(Icons.refresh, color: Colors.black),
          ),
          tooltip: 'Refresh Portfolio',
          onPressed: _handleRefresh,
        ),
      ],
    );
  }
}
