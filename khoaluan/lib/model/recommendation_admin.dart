class RecommendationSettingsModel {
  final bool aprioriEnabled;
  final bool contentBasedEnabled;
  final bool autoRebuildEnabled;
  final double minSupport;
  final double minConfidence;
  final int maxResults;
  final String? updatedAt;

  const RecommendationSettingsModel({
    required this.aprioriEnabled,
    required this.contentBasedEnabled,
    required this.autoRebuildEnabled,
    required this.minSupport,
    required this.minConfidence,
    required this.maxResults,
    this.updatedAt,
  });

  factory RecommendationSettingsModel.fromJson(Map<String, dynamic> json) {
    return RecommendationSettingsModel(
      aprioriEnabled: json['aprioriEnabled'] ?? true,
      contentBasedEnabled: json['contentBasedEnabled'] ?? true,
      autoRebuildEnabled: json['autoRebuildEnabled'] ?? true,
      minSupport: (json['minSupport'] as num? ?? 0.01).toDouble(),
      minConfidence: (json['minConfidence'] as num? ?? 0.10).toDouble(),
      maxResults: (json['maxResults'] as num? ?? 5).toInt(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class RecommendationStatsModel {
  final int eligibleBaskets;
  final int rulesCount;
  final int activeProducts;
  final int coveredProducts;
  final double coveragePercent;
  final String? lastUpdated;

  const RecommendationStatsModel({
    required this.eligibleBaskets,
    required this.rulesCount,
    required this.activeProducts,
    required this.coveredProducts,
    required this.coveragePercent,
    this.lastUpdated,
  });

  factory RecommendationStatsModel.fromJson(Map<String, dynamic> json) {
    return RecommendationStatsModel(
      eligibleBaskets: (json['eligibleBaskets'] as num? ?? 0).toInt(),
      rulesCount: (json['rulesCount'] as num? ?? 0).toInt(),
      activeProducts: (json['activeProducts'] as num? ?? 0).toInt(),
      coveredProducts: (json['coveredProducts'] as num? ?? 0).toInt(),
      coveragePercent: (json['coveragePercent'] as num? ?? 0).toDouble(),
      lastUpdated: json['lastUpdated']?.toString(),
    );
  }
}

class RecommendationRuleModel {
  final int id;
  final int productId;
  final String sourceProductName;
  final int recommendedProductId;
  final String recommendedProductName;
  final double support;
  final double confidence;
  final String lastUpdated;

  const RecommendationRuleModel({
    required this.id,
    required this.productId,
    required this.sourceProductName,
    required this.recommendedProductId,
    required this.recommendedProductName,
    required this.support,
    required this.confidence,
    required this.lastUpdated,
  });

  factory RecommendationRuleModel.fromJson(Map<String, dynamic> json) {
    return RecommendationRuleModel(
      id: (json['id'] as num? ?? 0).toInt(),
      productId: (json['productId'] as num? ?? 0).toInt(),
      sourceProductName: json['sourceProductName']?.toString() ?? '',
      recommendedProductId: (json['recommendedProductId'] as num? ?? 0).toInt(),
      recommendedProductName: json['recommendedProductName']?.toString() ?? '',
      support: (json['support'] as num? ?? 0).toDouble(),
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      lastUpdated: json['lastUpdated']?.toString() ?? '',
    );
  }
}

class RecommendationDashboardModel {
  final RecommendationSettingsModel settings;
  final RecommendationStatsModel stats;
  final List<RecommendationRuleModel> rules;

  const RecommendationDashboardModel({
    required this.settings,
    required this.stats,
    required this.rules,
  });

  factory RecommendationDashboardModel.fromJson(Map<String, dynamic> json) {
    final settings = Map<String, dynamic>.from(json['settings'] ?? const {});
    final stats = Map<String, dynamic>.from(json['stats'] ?? const {});
    final rules = (json['rules'] as List? ?? const []);
    return RecommendationDashboardModel(
      settings: RecommendationSettingsModel.fromJson(settings),
      stats: RecommendationStatsModel.fromJson(stats),
      rules: rules
          .map(
            (item) => RecommendationRuleModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}
