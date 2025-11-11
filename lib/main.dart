import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('loggedIn') ?? false;
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(FinViewApp(isDarkMode: isDarkMode, isLoggedIn: isLoggedIn));
}

class FinViewApp extends StatefulWidget {
  final bool isDarkMode;
  final bool isLoggedIn;
  const FinViewApp({
    super.key,
    required this.isDarkMode,
    required this.isLoggedIn,
  });

  @override
  State<FinViewApp> createState() => _FinViewAppState();
}

class _FinViewAppState extends State<FinViewApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() => isDarkMode = !isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FinView Lite',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/loading',
      routes: {
        '/loading': (_) => LoadingScreen(toggleTheme: toggleTheme),
        '/login': (_) =>
            LoginScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
        '/dashboard': (_) =>
            DashboardScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
      },
    );
  }
}

/// Temporary screen to check login state
class LoadingScreen extends StatefulWidget {
  final Function toggleTheme;
  const LoadingScreen({super.key, required this.toggleTheme});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;

    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
