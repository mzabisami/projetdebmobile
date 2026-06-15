import 'package:flutter/material.dart';
import '../modeles/historique_trajets.dart';
import '../modeles/score_securite.dart';
import '../services/route_history_service.dart';
import '../services/security_service.dart';

class SafetyScreen extends StatefulWidget {
  final String userId;
  const SafetyScreen({super.key, required this.userId});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  static const Color _bgColor = Color(0xFFF5F7FA);
  static const Color _primaryBlue = Color(0xFF2E86C1);
  static const Color _emeraldStart = Color(0xFF10B981);
  static const Color _emeraldEnd = Color(0xFF059669);
  static const Color _blueStart = Color(0xFF3B82F6);
  static const Color _indigoEnd = Color(0xFF6366F1);
  static const Color _yellowColor = Color(0xFFEAB308);
  static const Color _purpleColor = Color(0xFF9333EA);
  static const Color _orangeColor = Color(0xFFF97316);

  final SecurityService _securityService = SecurityService();
  final RouteHistoryService _historyService = RouteHistoryService();

  List<Trajets> _recentRoutes = [];
  double _avgScore = 0;
  double _avgLighting = 0;
  double _avgCycling = 0;
  double _avgTraffic = 0;
  double _avgCrowding = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _securityService.loadZones();
      final routes = await _historyService.getRoutesForUser(widget.userId);
      final List<SecurityScore> zones = _securityService.getZones();

      double avgL = 0, avgC = 0, avgT = 0, avgCr = 0;
      if (zones.isNotEmpty) {
        avgL = zones.fold(0.0, (s, z) => s + z.lighting) / zones.length;
        avgC = zones.fold(0.0, (s, z) => s + z.cyclingPath) / zones.length;
        avgT = zones.fold(0.0, (s, z) => s + z.traffic) / zones.length;
        avgCr = zones.fold(0.0, (s, z) => s + z.crowding) / zones.length;
      }
      final double avg = routes.isEmpty
          ? 0.0
          : routes.fold(0.0, (s, r) => s + r.securityScore) / routes.length;

      setState(() {
        _recentRoutes = routes.take(5).toList();
        _avgScore = avg;
        _avgLighting = avgL;
        _avgCycling = avgC;
        _avgTraffic = avgT;
        _avgCrowding = avgCr;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Sécurité des Trajets'),
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildScoreCard(),
                    const SizedBox(height: 16),
                    _buildPointsCard(),
                    const SizedBox(height: 16),
                    _buildCriteriaCard(),
                    const SizedBox(height: 16),
                    _buildRecentRoutes(),
                    const SizedBox(height: 16),
                    _buildSafetyTips(),
                    const SizedBox(height: 16),
                    _buildAlert(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // Carte score global
  Widget _buildScoreCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text(
                'Score de sécurité',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Vos Trajets sont analysés en temps réel',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Score moyen',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${_avgScore.toStringAsFixed(0)}/100',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Carte points de sécurité avec barème
  Widget _buildPointsCard() {
    final int totalPts = _recentRoutes.fold(0, (s, r) {
      if (r.securityScore >= 90) return s + 15;
      if (r.securityScore >= 75) return s + 8;
      if (r.securityScore >= 60) return s + 5;
      return s;
    });
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_blueStart, _indigoEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Points de sécurité',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Gagnez des points bonus en choisissant des Trajets sûrs !',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBonusBox('+15', 'Score 90+'),
              const SizedBox(width: 8),
              _buildBonusBox('+8', 'Score 75-89'),
              const SizedBox(width: 8),
              _buildBonusBox('+5', 'Score 60-74'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous avez gagné $totalPts points de sécurité sur ces Trajets',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBonusBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Critères de sécurité (moyennes des zones)
  Widget _buildCriteriaCard() {
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
            'Critères de sécurité',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildCriterionBar(
            icon: Icons.wb_sunny,
            label: 'Éclairage',
            value: _avgLighting,
            color: _yellowColor,
          ),
          const SizedBox(height: 12),
          _buildCriterionBar(
            icon: Icons.directions_bike,
            label: 'Pistes cyclables',
            value: _avgCycling,
            color: _emeraldStart,
          ),
          const SizedBox(height: 12),
          _buildCriterionBar(
            icon: Icons.navigation,
            label: 'Fluidité du trafic',
            value: (1 - _avgTraffic).clamp(0.0, 1.0),
            color: _blueStart,
          ),
          const SizedBox(height: 12),
          _buildCriterionBar(
            icon: Icons.people,
            label: 'Fréquentation',
            value: _avgCrowding,
            color: _purpleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCriterionBar({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    final double pct = (value * 100).clamp(0.0, 100.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 14)),
              ],
            ),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  // Trajets récents avec score de sécurité
  Widget _buildRecentRoutes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vos Trajets récents',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 10),
        if (_recentRoutes.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'Aucun trajet pour le moment 🚶',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...(_recentRoutes.map(_buildRouteCard)),
      ],
    );
  }

  Widget _buildRouteCard(Trajets route) {
    final Color statusColor = route.securityScore >= 90
        ? _emeraldStart
        : route.securityScore >= 75
        ? _blueStart
        : _orangeColor;
    final Color statusBg = route.securityScore >= 90
        ? const Color(0xFFD1FAE5)
        : route.securityScore >= 75
        ? const Color(0xFFDBEAFE)
        : const Color(0xFFFFEDD5);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.place, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${route.startPoint} → ${route.endPoint}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  route.mode,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  route.securityScore.toStringAsFixed(0),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: _blueStart, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    '+${_ptsForScore(route.securityScore)} pts',
                    style: const TextStyle(
                      color: _blueStart,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _ptsForScore(double score) {
    if (score >= 90) return 15;
    if (score >= 75) return 8;
    if (score >= 60) return 5;
    return 0;
  }

  // Conseils de sécurité
  Widget _buildSafetyTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conseils de sécurité',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        const SizedBox(height: 10),
        _buildTipCard(
          Icons.wb_sunny,
          'Éclairage optimal',
          'Privilégiez les rues bien éclairées le soir',
          '+5 pts',
        ),
        _buildTipCard(
          Icons.directions_bike,
          'Pistes cyclables',
          'Utilisez les pistes dédiées pour plus de sécurité',
          '+8 pts',
        ),
        _buildTipCard(
          Icons.people,
          'Zones fréquentées',
          'Les zones avec plus de passage sont plus sûres',
          '+3 pts',
        ),
      ],
    );
  }

  Widget _buildTipCard(IconData icon, String title, String desc, String bonus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _blueStart,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bonus,
                        style: const TextStyle(
                          color: _blueStart,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Alerte sécurité
  Widget _buildAlert() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFEDD5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber,
              color: _orangeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alerte sécurité',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Le score de sécurité peut être réduit en cas de mauvaises '
                  'conditions météo ou de trafic dense.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
