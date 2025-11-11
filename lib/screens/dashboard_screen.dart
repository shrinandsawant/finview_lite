import 'dart:math';
import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../widgets/header.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/allocation_chart.dart';
import '../widgets/holdings_list.dart';
import '../widgets/footer.dart';
import '../models/portfolio.dart';

class DashboardScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const DashboardScreen({
    required this.toggleTheme,
    required this.isDarkMode,
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PortfolioService _service = PortfolioService();
  final ValueNotifier<Portfolio?> _portfolioNotifier = ValueNotifier(null);
  final ScrollController _scrollController = ScrollController();

  bool showScrollToTop = false;
  bool showPercent = true;
  int? highlightedIndex;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _portfolioNotifier.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 300;
    if (shouldShow != showScrollToTop) {
      setState(() => showScrollToTop = shouldShow);
    }
  }

  /// Load portfolio from service
  Future<void> _loadPortfolio() async {
    final portfolio = await _service.loadPortfolio();
    _portfolioNotifier.value = portfolio;
  }

  /// Simulate updating portfolio prices
  Portfolio _simulatePortfolioUpdate(Portfolio portfolio) {
    final random = Random();
    List<Holding> updatedHoldings = portfolio.holdings.map((h) {
      double changePercent = (random.nextDouble() * 10) - 5; // -5% to +5%
      double newPrice = h.currentPrice * (1 + changePercent / 100);
      return h.copyWith(
        currentPrice: double.parse(newPrice.toStringAsFixed(2)),
      );
    }).toList();

    return portfolio.copyWith(holdings: updatedHoldings);
  }

  /// Reload portfolio (simulate price updates)
  Future<void> _reloadPortfolio() async {
    try {
      final currentPortfolio = _portfolioNotifier.value;
      if (currentPortfolio == null) return;

      // Simulate price updates
      final updatedPortfolio = _simulatePortfolioUpdate(currentPortfolio);

      // Update ValueNotifier
      _portfolioNotifier.value = updatedPortfolio;

      // Optionally, save to local storage
      await _service.savePortfolio(updatedPortfolio);

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
  }

  void _handleSliceSelected(int index) {
    setState(() => highlightedIndex = index);
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              toggleTheme: widget.toggleTheme,
              isDarkMode: widget.isDarkMode,
              portfolio:
                  _portfolioNotifier.value ??
                  Portfolio(user: 'User', holdings: []),
              onPortfolioUpdated: (updatedPortfolio) {
                _portfolioNotifier.value = updatedPortfolio;
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ValueListenableBuilder<Portfolio?>(
                valueListenable: _portfolioNotifier,
                builder: (context, portfolio, _) {
                  if (portfolio == null) {
                    return SizedBox(
                      height: 200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (portfolio.holdings.isEmpty) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    return SizedBox(
                      height: screenHeight - kToolbarHeight,
                      child: const Center(
                        child: Text(
                          "No holdings found.\nAdd some investments to see data.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  return isMobile
                      ? _buildMobileLayout(portfolio)
                      : _buildDesktopLayout(portfolio);
                },
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
      floatingActionButton: showScrollToTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: const Color(0xFF8DB600),
                mini: true,
                child: const Icon(Icons.arrow_upward, size: 18),
              ),
            )
          : null,
    );
  }

  Widget _buildMobileLayout(Portfolio portfolio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PortfolioSummaryCard(
          portfolio: portfolio,
          showPercent: showPercent,
          onToggle: (val) => setState(() => showPercent = val),
        ),
        const SizedBox(height: 16),
        AssetAllocationChart(
          holdings: portfolio.holdings,
          highlightedIndex: highlightedIndex,
          onSliceSelected: _handleSliceSelected,
        ),
        const SizedBox(height: 24),
        HoldingsList(
          holdings: portfolio.holdings,
          showPercent: showPercent,
          highlightedIndex: highlightedIndex,
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(Portfolio portfolio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 360,
                child: PortfolioSummaryCard(
                  portfolio: portfolio,
                  showPercent: showPercent,
                  onToggle: (val) => setState(() => showPercent = val),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 360,
                child: AssetAllocationChart(
                  holdings: portfolio.holdings,
                  highlightedIndex: highlightedIndex,
                  onSliceSelected: _handleSliceSelected,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        HoldingsList(
          holdings: portfolio.holdings,
          showPercent: showPercent,
          highlightedIndex: highlightedIndex,
        ),
      ],
    );
  }
}
