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

  Future<void> _loadPortfolio() async {
    final portfolio = await _service.loadPortfolio();
    _portfolioNotifier.value = portfolio;
  }

  Future<void> _reloadPortfolio() async {
    final portfolio = await _service.loadPortfolioFromAssets();
    if (portfolio != null) {
      _portfolioNotifier.value = portfolio;
      await _service.savePortfolio(portfolio);
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
              onPortfolioReload: _reloadPortfolio,
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

                  // Empty portfolio
                  if (portfolio.holdings.isEmpty) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    return SizedBox(
                      height:
                          screenHeight -
                          kToolbarHeight, // subtract header/appbar height if any
                      child: Center(
                        child: Text(
                          "No holdings found.\nAdd some investments to see data.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  // Non-empty portfolio
                  return isMobile
                      ? _buildMobileLayout(portfolio)
                      : _buildDesktopLayout(portfolio);
                },
              ),
            ),
            const AppFooter(), // natural flow, not sticky
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
