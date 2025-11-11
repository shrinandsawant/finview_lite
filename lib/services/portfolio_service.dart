import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio.dart';

class PortfolioService {
  /// Loads the portfolio from cache if available,
  /// otherwise falls back to assets/portfolio.json
  Future<Portfolio?> loadPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('portfolioJson');

      if (cachedData != null && cachedData.isNotEmpty) {
        // Use cached only if it exists
        final jsonResult = json.decode(cachedData);
        return Portfolio.fromJson(jsonResult);
      }

      // Always load from assets first if cache is empty
      final data = await rootBundle.loadString('assets/portfolio.json');
      final jsonResult = json.decode(data);

      // Save the initial data to cache for future runs
      await prefs.setString('portfolioJson', jsonEncode(jsonResult));

      return Portfolio.fromJson(jsonResult);
    } catch (e) {
      print('Error loading portfolio: $e');
      return null;
    }
  }

  /// Always loads the latest bundled file from assets (for refresh comparison)
  Future<Portfolio?> loadPortfolioFromAssets() async {
    try {
      final data = await rootBundle.loadString('assets/portfolio.json');
      final jsonResult = json.decode(data);
      return Portfolio.fromJson(jsonResult);
    } catch (e) {
      print('Error loading portfolio from assets: $e');
      return null;
    }
  }

  /// Saves the latest portfolio JSON to local cache
  Future<void> savePortfolio(Portfolio portfolio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('portfolioJson', jsonEncode(portfolio.toJson()));
  }
}
