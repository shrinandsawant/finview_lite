import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../theme/app_theme.dart';

class HoldingsList extends StatefulWidget {
  final List<Holding> holdings;
  final bool showPercent;
  final int? highlightedIndex;

  const HoldingsList({
    required this.holdings,
    required this.showPercent,
    this.highlightedIndex,
    super.key,
  });

  @override
  State<HoldingsList> createState() => _HoldingsListState();
}

class _HoldingsListState extends State<HoldingsList> {
  int? hoveredIndex;
  String sortBy = 'symbol';
  bool ascending = true;

  // Sort holdings based on current sort field
  List<Holding> get sortedHoldings {
    final sorted = [...widget.holdings];
    sorted.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortBy) {
        case 'symbol':
          aValue = a.symbol;
          bValue = b.symbol;
          break;
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'units':
          aValue = a.units;
          bValue = b.units;
          break;
        case 'avgCost':
          aValue = a.avgCost;
          bValue = b.avgCost;
          break;
        case 'currentValue':
          aValue = a.currentValue;
          bValue = b.currentValue;
          break;
        case 'gain':
          aValue = widget.showPercent ? a.gainPercent : a.gain;
          bValue = widget.showPercent ? b.gainPercent : b.gain;
          break;
        default:
          aValue = a.symbol;
          bValue = b.symbol;
      }

      final compare = (aValue is String)
          ? aValue.compareTo(bValue)
          : (aValue as num).compareTo(bValue as num);
      return ascending ? compare : -compare;
    });
    return sorted;
  }

  void _onSort(String field) {
    setState(() {
      if (sortBy == field) {
        ascending = !ascending;
      } else {
        sortBy = field;
        ascending = true;
      }
    });
  }

  // Show detailed popup for a holding
  void _showHoldingDetails(Holding holding) {
    final totalCost = holding.units * holding.avgCost;
    final totalGain = holding.currentValue - totalCost;
    final gainPercent = totalCost != 0 ? (totalGain / totalCost) * 100 : 0;
    final theme = Theme.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final fontSize = isMobile ? 14.0 : 16.0;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          Center(
            child: Container(
              width: isMobile ? 320 : 380,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        holding.symbol,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.iconTheme.color),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFormulaRow(
                    'Units',
                    holding.units.toString(),
                    textColor: theme.textTheme.bodyMedium?.color,
                    fontSize: fontSize,
                  ),
                  _buildFormulaRow(
                    'Avg Cost',
                    '₹${holding.avgCost.toStringAsFixed(2)}',
                    textColor: theme.textTheme.bodyMedium?.color,
                    fontSize: fontSize,
                  ),
                  const Divider(height: 20, thickness: 1),
                  _buildFormulaRow(
                    'Total Cost',
                    totalCost > 0 ? '₹${totalCost.toStringAsFixed(2)}' : 'N/A',
                    textColor: theme.textTheme.bodyMedium?.color,
                    fontSize: fontSize,
                  ),
                  _buildFormulaRow(
                    'Current Value',
                    holding.currentValue > 0
                        ? '₹${holding.currentValue.toStringAsFixed(2)}'
                        : 'N/A',
                    textColor: theme.textTheme.bodyMedium?.color,
                    fontSize: fontSize,
                  ),
                  _buildFormulaRow(
                    'Gain/Loss',
                    totalCost > 0 ? '₹${totalGain.toStringAsFixed(2)}' : 'N/A',
                    valueColor: totalGain >= 0
                        ? AppTheme.success
                        : AppTheme.danger,
                    textColor: theme.textTheme.bodyMedium?.color,
                    fontSize: fontSize,
                  ),
                  _buildFormulaRow(
                    'Gain %',
                    totalCost > 0
                        ? '${gainPercent.toStringAsFixed(2)}%'
                        : 'N/A',
                    valueColor: totalGain >= 0
                        ? AppTheme.success
                        : AppTheme.danger,
                    textColor: theme.textTheme.bodyMedium?.color,
                    fontSize: fontSize,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build rows with label and value
  Widget _buildFormulaRow(
    String label,
    String value, {
    Color? valueColor,
    Color? textColor,
    double fontSize = 16,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: fontSize,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value,
              style: TextStyle(color: valueColor ?? textColor ?? Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final rowFontSize = isMobile ? 13.0 : 16.0;
    final headerFontSize = isMobile ? 13.0 : 16.0;

    // Show info when no active holdings
    if (widget.holdings.isEmpty || widget.holdings.every((h) => h.units == 0)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "No active holdings to display.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            children: [
              _buildSortableHeader(
                'Symbol',
                'symbol',
                flex: 2,
                fontSize: headerFontSize,
              ),
              _buildSortableHeader(
                'Name',
                'name',
                flex: 4,
                fontSize: headerFontSize,
              ),
              _buildSortableHeader(
                'Units',
                'units',
                flex: 2,
                alignRight: true,
                fontSize: headerFontSize,
              ),
              _buildSortableHeader(
                'Avg Cost',
                'avgCost',
                flex: 3,
                alignRight: true,
                fontSize: headerFontSize,
              ),
              _buildSortableHeader(
                'Current Value',
                'currentValue',
                flex: 3,
                alignRight: true,
                fontSize: headerFontSize,
              ),
              _buildSortableHeader(
                'Gain/Loss',
                'gain',
                flex: 3,
                alignRight: true,
                fontSize: headerFontSize,
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),

        // Table rows
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedHoldings.length,
          itemBuilder: (context, index) {
            final holding = sortedHoldings[index];
            final isHighlighted = index == widget.highlightedIndex;
            final isHovered = index == hoveredIndex;

            return MouseRegion(
              onEnter: (_) => setState(() => hoveredIndex = index),
              onExit: (_) => setState(() => hoveredIndex = null),
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppTheme.primary.withOpacity(0.15)
                      : isHovered
                      ? AppTheme.primary.withOpacity(0.08)
                      : index.isEven
                      ? theme.cardColor.withOpacity(0.04)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                transform: isHovered
                    ? (Matrix4.identity()..translate(0, -2))
                    : Matrix4.identity(),
                child: GestureDetector(
                  onTap: () => _showHoldingDetails(holding),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          holding.symbol,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: rowFontSize,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          holding.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: rowFontSize),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${holding.units}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: rowFontSize),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '₹${holding.avgCost.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: rowFontSize),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          '₹${holding.currentValue.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: rowFontSize),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          widget.showPercent
                              ? '${holding.gainPercent.toStringAsFixed(2)}%'
                              : '₹${holding.gain.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: holding.gain >= 0
                                ? AppTheme.success
                                : AppTheme.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: rowFontSize,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Build sortable column headers
  Widget _buildSortableHeader(
    String label,
    String field, {
    double flex = 1,
    bool alignRight = false,
    double fontSize = 16,
  }) {
    final isActive = sortBy == field;
    return Expanded(
      flex: flex.toInt(),
      child: GestureDetector(
        onTap: () => _onSort(field),
        child: Row(
          mainAxisAlignment: alignRight
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              isActive
                  ? (ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                  : Icons.swap_vert_rounded,
              size: 16,
              color: isActive ? AppTheme.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
