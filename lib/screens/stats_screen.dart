import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../modeles/historique_trajets.dart';
import '../services/route_history_service.dart';

class StatsScreen extends StatefulWidget {
  final String userId;
  const StatsScreen({super.key, required this.userId});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Color _primaryBlue = Color(0xFF2E86C1);
  static const Color _successGreen = Color(0xFF27AE60);
  static const Color _warningOrange = Color(0xFFE67E22);
  static const Color _bgColor = Color(0xFFF5F7FA);
  static const Color _metroViolet = Color(0xFF8E44AD);
  static const Color _dangerRed = Color(0xFFE74C3C);

  final RouteHistoryService _historyService = RouteHistoryService();

  List<Trajets> _weekRoutes = [];
  List<Trajets> _monthRoutes = [];
  bool _isLoading = true;

  // Onglet actif : 0 = semaine, 1 = mois
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final List<Trajets> week = await _historyService.getWeeklyRoutes(
        widget.userId,
      );
      final List<Trajets> month = await _historyService.getMonthlyRoutes(
        widget.userId,
      );
      setState(() {
        _weekRoutes = week;
        _monthRoutes = month;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Données actives selon l'onglet sélectionné
  List<Trajets> get _activeRoutes =>
      _selectedTab == 0 ? _weekRoutes : _monthRoutes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTabSelector(),
                  const SizedBox(height: 16),
                  _buildSummaryCards(),
                  const SizedBox(height: 16),
                  _buildPointsChart(),
                  const SizedBox(height: 16),
                  _buildModeChart(),
                ],
              ),
            ),
    );
  }

  // Sélecteur Semaine / Mois
  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['Cette semaine', 'Ce mois'].asMap().entries.map((entry) {
          final bool isSelected = _selectedTab == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Cartes résumé (points, Trajets, CO2)
  Widget _buildSummaryCards() {
    final List<Trajets> routes = _activeRoutes;
    final int totalPts = routes.fold(0, (s, r) => s + r.points);
    final double totalCo2 = routes.fold(0.0, (s, r) => s + r.co2);

    return Row(
      children: [
        _miniCard('${routes.length}', 'Trajets', Icons.route, _primaryBlue),
        const SizedBox(width: 10),
        _miniCard('$totalPts', 'Points', Icons.star, _warningOrange),
        const SizedBox(width: 10),
        _miniCard(
          '${totalCo2.toStringAsFixed(0)}g',
          'CO2',
          Icons.eco,
          _successGreen,
        ),
      ],
    );
  }

  Widget _miniCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Graphique : Points gagnés par trajet (barres)
  Widget _buildPointsChart() {
    final List<Trajets> displayed = _activeRoutes
        .take(7)
        .toList()
        .reversed
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Points par trajet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (displayed.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aucune donnée 📊',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            _buildBarChart(displayed),
          const SizedBox(height: 8),
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Trajets> displayed) {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final int i = value.toInt();
                  if (i >= displayed.length) return const Text('');
                  const Map<String, String> icons = {
                    'vélo': '🚲',
                    'bus': '🚌',
                    'métro': '🚇',
                    'voiture': '🚗',
                  };
                  return Text(
                    icons[displayed[i].mode] ?? '🚶',
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: _barGroups(displayed),
        ),
      ),
    );
  }

  List<BarChartGroupData> _barGroups(List<Trajets> displayed) {
    return displayed.asMap().entries.map((MapEntry<int, Trajets> entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.points.toDouble(),
            color: entry.value.isEco ? _successGreen : _primaryBlue,
            width: 22,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        _legendDot(_successGreen),
        const SizedBox(width: 4),
        const Text('Éco', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        _legendDot(_primaryBlue),
        const SizedBox(width: 4),
        const Text('Standard', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _legendDot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  // Graphique : Répartition par mode (camembert)
  Widget _buildModeChart() {
    final List<Trajets> routes = _activeRoutes;
    if (routes.isEmpty) return const SizedBox();

    final Map<String, int> modeCounts = {};
    for (final r in routes) {
      modeCounts[r.mode] = (modeCounts[r.mode] ?? 0) + 1;
    }

    final Map<String, Color> modeColors = {
      'vélo': _successGreen,
      'bus': _primaryBlue,
      'métro': _metroViolet,
      'voiture': _dangerRed,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Modes de transport',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPieChart(modeCounts, modeColors),
              const SizedBox(width: 20),
              _buildModeLegend(modeCounts, modeColors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    Map<String, int> modeCounts,
    Map<String, Color> modeColors,
  ) {
    return SizedBox(
      height: 140,
      width: 140,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: modeCounts.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value.toDouble(),
              color: modeColors[entry.key] ?? Colors.grey,
              radius: 45,
              title: '${entry.value}',
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModeLegend(
    Map<String, int> modeCounts,
    Map<String, Color> modeColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: modeCounts.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              _legendDot(modeColors[entry.key] ?? Colors.grey),
              const SizedBox(width: 6),
              Text(
                '${entry.key} (${entry.value})',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
