import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../models/portfolio.dart';
import '../theme/app_theme.dart';

class PortfolioSummaryCard extends StatefulWidget {
  final Portfolio portfolio;
  final bool showPercent;
  final Function(bool) onToggle;

  const PortfolioSummaryCard({
    required this.portfolio,
    required this.showPercent,
    required this.onToggle,
    super.key,
  });

  @override
  _PortfolioSummaryCardState createState() => _PortfolioSummaryCardState();
}

class _PortfolioSummaryCardState extends State<PortfolioSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<double> previousValues;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();

    // Store initial values for animation baseline
    previousValues = widget.portfolio.holdings.map((h) {
      return widget.showPercent
          ? ((h.currentPrice - h.avgCost) / h.avgCost * 100)
          : h.currentValue;
    }).toList();
  }

  @override
  void didUpdateWidget(covariant PortfolioSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    const eq = DeepCollectionEquality();

    // Detect if portfolio data itself changed
    final portfolioChanged = !eq.equals(
      oldWidget.portfolio.toJson(),
      widget.portfolio.toJson(),
    );

    // Trigger animation when either the toggle OR data changed
    if (oldWidget.showPercent != widget.showPercent || portfolioChanged) {
      _controller.forward(from: 0);
      previousValues = oldWidget.portfolio.holdings.map((h) {
        return oldWidget.showPercent
            ? ((h.currentPrice - h.avgCost) / h.avgCost * 100)
            : h.currentValue;
      }).toList();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gain = widget.portfolio.totalGain;
    final gainPercent =
        widget.portfolio.totalGain / widget.portfolio.portfolioValue * 100;
    final assetCount = widget.portfolio.holdings.length;

    IconData gainIcon = gain > 0
        ? Icons.arrow_upward
        : gain < 0
        ? Icons.arrow_downward
        : Icons.remove;
    Color gainColor = gain > 0
        ? AppTheme.success
        : gain < 0
        ? AppTheme.danger
        : Colors.grey;

    // Compute current values for the chart
    List<double> currentValues = widget.portfolio.holdings.map((h) {
      return widget.showPercent
          ? ((h.currentPrice - h.avgCost) / h.avgCost * 100)
          : h.currentValue;
    }).toList();

    double maxValue = currentValues
        .map((v) => v.abs())
        .fold(0, (a, b) => a > b ? a : b);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Portfolio Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$assetCount Assets',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Total Value (animated)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: widget.portfolio.portfolioValue,
              ),
              duration: const Duration(seconds: 1),
              builder: (context, value, _) => Text(
                'Total Value: ₹${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gain / % Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(gainIcon, color: gainColor, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      widget.showPercent
                          ? '${gainPercent.toStringAsFixed(2)}%'
                          : '₹${gain.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: gainColor,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(fontFamily: AppTheme.fontFamily),
                    ),
                    Switch(
                      value: widget.showPercent,
                      onChanged: (val) => widget.onToggle(val),
                    ),
                    Text(
                      '%',
                      style: TextStyle(fontFamily: AppTheme.fontFamily),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Animated Sparkline Chart
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                List<FlSpot> spots = [];
                for (int i = 0; i < currentValues.length; i++) {
                  double animatedValue =
                      previousValues[i] +
                      (currentValues[i] - previousValues[i]) * _animation.value;
                  spots.add(FlSpot(i.toDouble(), animatedValue));
                }

                return Container(
                  height: 150,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: LineChart(
                    LineChartData(
                      minY: widget.showPercent ? -maxValue * 1.1 : 0,
                      maxY: maxValue * 1.1,
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        enabled: true,
                        handleBuiltInTouches: true,
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => Colors.black87,
                          getTooltipItems: (spots) => spots.map((spot) {
                            final idx = spot.x.toInt();
                            final h = widget.portfolio.holdings[idx];
                            final value = widget.showPercent
                                ? '${((h.currentPrice - h.avgCost) / h.avgCost * 100).toStringAsFixed(2)}%'
                                : '₹${h.currentValue.toStringAsFixed(2)}';
                            return LineTooltipItem(
                              '${h.name}\nCurrent Price: ₹${h.currentPrice.toStringAsFixed(2)}\nValue: $value',
                              const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
