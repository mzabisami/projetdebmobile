import 'dart:convert';

import 'package:flutter/services.dart';

const int mockInitialPoints = 320;
const String rewardsAssetPath = 'lib/data/rewards.json';

class Reward {
  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.available,
    required this.category,
    required this.icon,
    required this.isSpecial,
    required this.discountLabel,
  });

  final String id;
  final String name;
  final String description;
  final int cost;
  final bool available;
  final String category;
  final String icon;
  final bool isSpecial;
  final String discountLabel;

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      cost: json['cost'] as int,
      available: json['available'] as bool,
      category: json['category'] as String,
      icon: json['icon'] as String,
      isSpecial: json['isSpecial'] as bool? ?? false,
      discountLabel: json['discountLabel'] as String? ?? '',
    );
  }
}

Future<List<Reward>> loadRewards({AssetBundle? bundle}) async {
  final content = await (bundle ?? rootBundle).loadString(rewardsAssetPath);
  final decoded = jsonDecode(content) as List<dynamic>;

  return decoded
      .map((item) => Reward.fromJson(item as Map<String, dynamic>))
      .toList(growable: false);
}

bool canRedeemReward(Reward reward, int pointsBalance) {
  return reward.available && pointsBalance >= reward.cost;
}

int redeemReward(Reward reward, int pointsBalance) {
  if (!canRedeemReward(reward, pointsBalance)) {
    return pointsBalance;
  }

  return pointsBalance - reward.cost;
}
