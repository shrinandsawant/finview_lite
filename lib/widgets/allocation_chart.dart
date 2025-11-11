import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/portfolio.dart';
import '../theme/app_theme.dart';

class AssetAllocationChart extends StatefulWidget {
  final List<Holding> holdings;
  final Function(int)? onSliceSelected;
  final int? highlightedIndex;

  const AssetAllocationChart({
    required this.holdings,
    this.onSliceSelected,
    this.highlightedIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<AssetAllocationChart> createState() => _AssetAllocationChartState();
}

class _AssetAllocationChartState extends State<AssetAllocationChart> {
  int selectedIndex = -1;
  int viewIndex = 0; // 0=Value, 1=Units, 2=% Gain, 3=% Loss
  static const int topN = 8;

  @override
  void didUpdateWidget(covariant AssetAllocationChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedIndex != null) {
      selectedIndex = widget.highlightedIndex!;
    }
  }

  void _nextView() {
    setState(() => viewIndex = (viewIndex + 1) % 4);
  }

  void _previousView() {
    setState(() => viewIndex = (viewIndex - 1 + 4) % 4);
  }

  String _getChartTitle() {
    switch (viewIndex) {
      case 0:
        return 'Asset Allocation by Value';
      case 1:
        return 'Asset Allocation by Units';
      case 2:
        return 'Asset Allocation by % Gain';
      case 3:
        return 'Asset Allocation by % Loss';
      default:
        return '';
    }
  }

  double _computeMetric(Holding h) {
    switch (viewIndex) {
      case 0:
        return h.units * h.currentPrice;
      case 1:
        return h.units.toDouble();
      case 2:
        double gainPercent = ((h.currentPrice - h.avgCost) / h.avgCost) * 100;
        return gainPercent > 0 ? gainPercent : 0;
      case 3:
        double lossPercent = ((h.currentPrice - h.avgCost) / h.avgCost) * 100;
        return lossPercent < 0 ? -lossPercent : 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nonZeroHoldings = widget.holdings.where((h) => h.units > 0).toList();
    final metrics = nonZeroHoldings.map(_computeMetric).toList();
    final hasData = metrics.any((v) => v > 0);
    final isMobile = MediaQuery.of(context).size.width < 800;

    Widget cardContent = hasData
        ? _buildChart(nonZeroHoldings)
        : _buildNoData();

    return Center(
      child: SizedBox(
        width: isMobile ? double.infinity : 950,
        height: 450,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isMobile
                ? Column(
                    children: [
                      // Title
                      Text(
                        _getChartTitle(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppTheme.fontFamily,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Up arrow
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Colors.grey,
                        ),
                        onPressed: _previousView,
                      ),
                      // Chart or no data
                      Expanded(child: cardContent),
                      // Down arrow
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(
                          Icons.arrow_downward,
                          color: Colors.grey,
                        ),
                        onPressed: _nextView,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left arrow
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.grey,
                        ),
                        onPressed: _previousView,
                      ),
                      // Chart or no data with title above
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _getChartTitle(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppTheme.fontFamily,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(child: cardContent),
                          ],
                        ),
                      ),
                      // Right arrow
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        ),
                        onPressed: _nextView,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(List<Holding> holdings) {
    final sorted = [...holdings]
      ..sort((a, b) => _computeMetric(b).compareTo(_computeMetric(a)));
    final topHoldings = sorted.take(topN).toList();
    final othersValue = sorted
        .skip(topN)
        .fold(0.0, (sum, h) => sum + _computeMetric(h));

    if (othersValue > 0) {
      topHoldings.add(
        Holding(
          symbol: "OTHERS",
          name: "Others",
          units: 0,
          avgCost: 0,
          currentPrice: 0,
        ),
      );
    }

    final totalMetric = topHoldings.fold(
      0.0,
      (sum, h) => sum + _computeMetric(h),
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 60,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (response?.touchedSection != null) {
                    setState(() {
                      selectedIndex =
                          response!.touchedSection!.touchedSectionIndex;
                    });
                    widget.onSliceSelected?.call(selectedIndex);
                  }
                },
              ),
              sections: topHoldings.asMap().entries.map((entry) {
                final idx = entry.key;
                final h = entry.value;
                final value = _computeMetric(h);
                final pct = totalMetric > 0
                    ? (value / totalMetric) * 100.0
                    : 0.0;
                final isSelected = selectedIndex == idx;

                // Truncate symbol to 3 letters
                final displaySymbol = h.symbol.length > 3
                    ? h.symbol.substring(0, 3).toUpperCase()
                    : h.symbol.toUpperCase();

                return PieChartSectionData(
                  color:
                      Colors.primaries[idx % Colors.primaries.length].shade400,
                  value: value,
                  title: displaySymbol,
                  radius: isSelected ? 70 : 60,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  badgeWidget: isSelected ? _buildTooltip(h, pct) : null,
                  badgePositionPercentageOffset: 1.4,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: 180,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: topHoldings.asMap().entries.map((entry) {
              final idx = entry.key;
              final h = entry.value;
              final value = _computeMetric(h);
              final pct = totalMetric > 0 ? (value / totalMetric) * 100.0 : 0.0;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors
                            .primaries[idx % Colors.primaries.length]
                            .shade400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        h.symbol == "OTHERS" ? "OTHERS" : h.symbol,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text("${pct.toStringAsFixed(1)}%"),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "No active investments to display for this view.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip(Holding holding, double percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${holding.name}\n${percentage.toStringAsFixed(1)}%",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
