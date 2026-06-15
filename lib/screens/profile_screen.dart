import 'package:flutter/material.dart';
import '../modeles/historique_trajets.dart';
import '../services/route_history_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _bgColor = Color(0xFFF5F7FA);
  static const Color _primaryBlue = Color(0xFF2E86C1);
  static const Color _dangerRed = Color(0xFFE74C3C);
  static const Color _warningOrange = Color(0xFFE67E22);
  static const Color _emeraldStart = Color(0xFF10B981);
  static const Color _emeraldEnd = Color(0xFF059669);
  static const Color _blueStart = Color(0xFF3B82F6);
  static const Color _indigoEnd = Color(0xFF6366F1);
  static const Color _purpleColor = Color(0xFF9333EA);

  final RouteHistoryService _historyService = RouteHistoryService();

  List<Trajets> _recentRoutes = [];
  List<Trajets> _weekRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final routes = await _historyService.getRoutesForUser(widget.userId);
      final week = await _historyService.getWeeklyRoutes(widget.userId);
      setState(() {
        _recentRoutes = routes.take(5).toList();
        _weekRoutes = week;
      });
    } catch (e) {
      // erreur silencieuse
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _historyService.watchUserStats(widget.userId),
        builder: (context, snapshot) {
          final stats = snapshot.data ?? {};
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(stats),
                  const SizedBox(height: 16),
                  _buildStatsRow(stats),
                  const SizedBox(height: 16),
                  _buildPointsBreakdown(stats),
                  const SizedBox(height: 16),
                  _buildResultsSummary(stats),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(),
                  const SizedBox(height: 16),
                  _buildMonthlyStats(stats),
                  const SizedBox(height: 16),
                  _buildGoals(stats),
                  const SizedBox(height: 16),
                  _buildSettings(),
                  const SizedBox(height: 16),
                  _buildEcoImpact(stats),
                  const SizedBox(height: 16),
                  _buildLogout(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // En-tête dégradé : avatar + badge points
  Widget _buildHeader(Map<String, dynamic> stats) {
    final int totalPoints = (stats['totalPoints'] as int?) ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_emeraldStart, _emeraldEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon compte',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$totalPoints pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3 cartes : Trajets verts, points totaux, CO2
  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final int ecoRoutes = (stats['ecoRoutes'] as int?) ?? 0;
    final int totalPoints = (stats['totalPoints'] as int?) ?? 0;
    final double totalCo2 = (stats['totalCo2'] as double?) ?? 0.0;
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.eco,
          label: 'Trajets verts',
          value: '$ecoRoutes',
          bgColor: const Color(0xFFD1FAE5),
          iconColor: _emeraldStart,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.emoji_events,
          label: 'Points',
          value: '$totalPoints',
          gradient: const LinearGradient(colors: [_emeraldStart, _blueStart]),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.trending_up,
          label: 'CO₂ éco.',
          value: '${(totalCo2 / 1000).toStringAsFixed(1)} kg',
          bgColor: const Color(0xFFFEF3C7),
          iconColor: _warningOrange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    Color? bgColor,
    Color? iconColor,
    Gradient? gradient,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                gradient: gradient,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Répartition des points (Éco / Sécurité)
  Widget _buildPointsBreakdown(Map<String, dynamic> stats) {
    final int totalPts = (stats['totalPoints'] as int?) ?? 0;
    final int totalRts = ((stats['totalRoutes'] as int?) ?? 1).clamp(1, 9999);
    final int ecoRts = (stats['ecoRoutes'] as int?) ?? 0;
    final int ecoPoints = (totalPts * ecoRts / totalRts).round();
    final int secPts = totalPts - ecoPoints;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_emeraldStart, _blueStart],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition des points',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPointsSubCard(
                  icon: Icons.eco,
                  label: 'Points Éco',
                  value: '$ecoPoints',
                  sub: totalPts > 0
                      ? '${(ecoPoints / totalPts * 100).round()}% du total'
                      : '0%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPointsSubCard(
                  icon: Icons.shield,
                  label: 'Points Sécurité',
                  value: '$secPts',
                  sub: totalPts > 0
                      ? '${(secPts / totalPts * 100).round()}% du total'
                      : '0%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Continuez à choisir des Trajets sûrs et écologiques !',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSubCard({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Cartes résultats semaine (CO2 + points)
  Widget _buildResultsSummary(Map<String, dynamic> stats) {
    final double weekCo2 = (stats['weekCo2'] as double?) ?? 0.0;
    final int weekPoints = (stats['weekPoints'] as int?) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mes résultats',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildResultCard(
                icon: Icons.trending_down,
                label: 'CO₂ économisé',
                value: '${(weekCo2 / 1000).toStringAsFixed(1)} kg',
                sub: 'Cette semaine',
                gradient: const LinearGradient(
                  colors: [_emeraldStart, _emeraldEnd],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildResultCard(
                icon: Icons.emoji_events,
                label: 'Points gagnés',
                value: '$weekPoints',
                sub: 'Cette semaine',
                gradient: const LinearGradient(
                  colors: [_blueStart, _indigoEnd],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required String label,
    required String value,
    required String sub,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Graphique activité hebdomadaire (barres custom)
  Widget _buildWeeklyChart() {
    const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final List<int> dayPoints = List.filled(7, 0);
    for (final r in _weekRoutes) {
      dayPoints[(r.date.weekday - 1) % 7] += r.points;
    }
    final int maxPts = dayPoints.fold(1, (a, b) => a > b ? a : b);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Activité hebdomadaire',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  Icon(Icons.trending_up, color: _emeraldStart, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '+12%',
                    style: TextStyle(color: _emeraldStart, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final double ratio = (dayPoints[i] / maxPts).clamp(0.05, 1.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_emeraldEnd, _emeraldStart],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayNames[i],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Stats mensuelles + répartition modes
  Widget _buildMonthlyStats(Map<String, dynamic> stats) {
    final int totalRoutes = (stats['totalRoutes'] as int?) ?? 0;
    final int ecoRoutes = (stats['ecoRoutes'] as int?) ?? 0;
    final double ecoRatio = totalRoutes > 0 ? ecoRoutes / totalRoutes : 0;
    final Map<String, int> modeCounts = {};
    for (final r in _recentRoutes) {
      modeCounts[r.mode] = (modeCounts[r.mode] ?? 0) + 1;
    }
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
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'Statistiques mensuelles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trajets écologiques',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    'Sur $totalRoutes Trajets totaux',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              Text(
                '$ecoRoutes',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ecoRatio,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(_emeraldStart),
            ),
          ),
          const SizedBox(height: 12),
          _buildModeBreakdown(modeCounts),
        ],
      ),
    );
  }

  Widget _buildModeBreakdown(Map<String, int> m) {
    return Row(
      children: [
        _modeItem(
          'vélo',
          m['vélo'] ?? 0,
          _emeraldStart,
          const Color(0xFFD1FAE5),
          '🚲',
        ),
        _modeItem(
          'bus',
          m['bus'] ?? 0,
          _blueStart,
          const Color(0xFFDBEAFE),
          '🚌',
        ),
        _modeItem(
          'métro',
          m['métro'] ?? 0,
          _purpleColor,
          const Color(0xFFF3E8FF),
          '🚇',
        ),
        _modeItem(
          'voiture',
          m['voiture'] ?? 0,
          _dangerRed,
          const Color(0xFFFEE2E2),
          '🚗',
        ),
      ],
    );
  }

  Widget _modeItem(
    String mode,
    int count,
    Color color,
    Color bgColor,
    String emoji,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              mode,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Objectifs du mois
  Widget _buildGoals(Map<String, dynamic> stats) {
    final int co2Kg = (((stats['totalCo2'] as double?) ?? 0.0) / 1000).round();
    final int ecoRoutes = (stats['ecoRoutes'] as int?) ?? 0;
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
            'Objectifs du mois',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildGoalBar(
            label: 'Économiser 50 kg de CO₂',
            current: co2Kg,
            target: 50,
            color: _emeraldStart,
          ),
          const SizedBox(height: 12),
          _buildGoalBar(
            label: 'Faire 60 Trajets verts',
            current: ecoRoutes,
            target: 60,
            color: _blueStart,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalBar({
    required String label,
    required int current,
    required int target,
    required Color color,
  }) {
    final double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$current / $target',
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
      ],
    );
  }

  // Menu paramètres + support
  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 10),
        Container(
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
            children: [
              _buildSettingsItem(
                Icons.person_outline,
                'Modifier le profil',
                null,
                null,
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.notifications_outlined,
                'Notifications',
                null,
                null,
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.settings_outlined,
                'Préférences',
                null,
                null,
              ),
              _buildDivider(),
              _buildSettingsItem(
                Icons.help_outline,
                'Aide & FAQ',
                _blueStart,
                const Color(0xFFDBEAFE),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String label,
    Color? iconColor,
    Color? iconBg,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBg ?? Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Colors.grey[700]),
      ),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildDivider() => Container(
    height: 1,
    color: Colors.grey[100],
    margin: const EdgeInsets.symmetric(horizontal: 16),
  );

  // Impact écologique
  Widget _buildEcoImpact(Map<String, dynamic> stats) {
    final double co2Kg = ((stats['totalCo2'] as double?) ?? 0.0) / 1000;
    final int treesEquiv = (co2Kg / 5).floor().clamp(1, 7);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFEFF6FF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _emeraldStart,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Votre impact écologique',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Grâce à vos Trajets, vous avez économisé '
                  '${co2Kg.toStringAsFixed(1)} kg de CO₂ !',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text('🌳 ' * treesEquiv, style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bouton déconnexion
  Widget _buildLogout() {
    return GestureDetector(
      onTap: () {},
      child: Container(
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
