import 'package:devmobile/config/theme.dart';
import 'package:devmobile/mocks/mock_data.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({
    super.key,
    this.initialRewards,
    this.initialPoints = mockInitialPoints,
  });

  final List<Reward>? initialRewards;
  final int initialPoints;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<List<Reward>> _rewardsFuture;
  late int _pointsBalance;

  @override
  void initState() {
    super.initState();
    _pointsBalance = widget.initialPoints;
    _rewardsFuture = widget.initialRewards == null
        ? loadRewards()
        : Future.value(widget.initialRewards);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Reward>>(
        future: _rewardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ShopError(onRetry: _reloadRewards);
          }

          final rewards = snapshot.data ?? const <Reward>[];
          final specialReward = _specialReward(rewards);
          final regularRewards = rewards
              .where((reward) => !reward.isSpecial)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PointsHeader(pointsBalance: _pointsBalance),
                    const SizedBox(height: 16),
                    if (specialReward != null) ...[
                      _SectionTitle(
                        title: 'Offre spéciale',
                        actionLabel: specialReward.discountLabel,
                      ),
                      const SizedBox(height: 8),
                      _RewardCard(
                        reward: specialReward,
                        pointsBalance: _pointsBalance,
                        highlighted: true,
                        onRedeem: _redeem,
                      ),
                      const SizedBox(height: 18),
                    ],
                    const _SectionTitle(title: 'Récompenses'),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    return _RewardCard(
                      reward: regularRewards[index],
                      pointsBalance: _pointsBalance,
                      onRedeem: _redeem,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemCount: regularRewards.length,
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(18, 0, 18, 20),
                sliver: SliverToBoxAdapter(child: _EarnMoreBanner()),
              ),
            ],
          );
        },
      ),
    );
  }

  Reward? _specialReward(List<Reward> rewards) {
    for (final reward in rewards) {
      if (reward.isSpecial) {
        return reward;
      }
    }

    return null;
  }

  void _reloadRewards() {
    setState(() {
      _rewardsFuture = loadRewards();
    });
  }

  void _redeem(Reward reward) {
    if (!canRedeemReward(reward, _pointsBalance)) {
      return;
    }

    setState(() {
      _pointsBalance = redeemReward(reward, _pointsBalance);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Récompense échangée : ${reward.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PointsHeader extends StatelessWidget {
  const _PointsHeader({required this.pointsBalance});

  final int pointsBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.stars, color: AppColors.warning, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes points',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$pointsBalance pts',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.eco, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.actionLabel});

  final String title;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (actionLabel != null && actionLabel!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              actionLabel!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.pointsBalance,
    required this.onRedeem,
    this.highlighted = false,
  });

  final Reward reward;
  final int pointsBalance;
  final ValueChanged<Reward> onRedeem;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final canRedeem = canRedeemReward(reward, pointsBalance);
    final buttonLabel = canRedeem ? 'Échanger' : 'Bientôt';

    return Card(
      color: highlighted ? AppColors.accentLight : AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: highlighted ? AppColors.accent : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _rewardIcon(reward.icon),
                color: highlighted ? Colors.white : AppColors.primaryDark,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reward.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Text(
                        '${reward.cost} pts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: highlighted
                              ? AppColors.accent
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _CategoryChip(label: reward.category),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: canRedeem ? () => onRedeem(reward) : null,
                        icon: Icon(
                          canRedeem ? Icons.redeem : Icons.schedule,
                          size: 18,
                        ),
                        label: Text(buttonLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _rewardIcon(String key) {
    switch (key) {
      case 'directions_bus':
        return Icons.directions_bus;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'pedal_bike':
        return Icons.pedal_bike;
      case 'restaurant':
        return Icons.restaurant;
      case 'confirmation_number':
        return Icons.confirmation_number;
      case 'local_cafe':
      default:
        return Icons.local_cafe;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EarnMoreBanner extends StatelessWidget {
  const _EarnMoreBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Gagnez plus de points avec les trajets éco et les scores sécurité élevés.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopError extends StatelessWidget {
  const _ShopError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.warning, size: 42),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger la boutique.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
