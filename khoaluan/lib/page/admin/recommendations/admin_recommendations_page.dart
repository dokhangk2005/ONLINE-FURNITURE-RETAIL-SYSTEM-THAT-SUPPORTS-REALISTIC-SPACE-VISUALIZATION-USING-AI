import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../model/product.dart';
import '../../../model/recommendation_admin.dart';
import '../../../services/api_service.dart';

class AdminRecommendationsPage extends StatefulWidget {
  const AdminRecommendationsPage({super.key});

  @override
  State<AdminRecommendationsPage> createState() =>
      _AdminRecommendationsPageState();
}

class _AdminRecommendationsPageState extends State<AdminRecommendationsPage> {
  final _api = ApiService();
  final _supportController = TextEditingController();
  final _confidenceController = TextEditingController();
  final _maxResultsController = TextEditingController();

  RecommendationDashboardModel? _dashboard;
  List<Product> _products = [];
  List<Product> _contentPreview = [];
  int? _previewProductId;
  bool _aprioriEnabled = true;
  bool _contentBasedEnabled = true;
  bool _autoRebuildEnabled = true;
  bool _loading = true;
  bool _saving = false;
  bool _rebuilding = false;
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _supportController.dispose();
    _confidenceController.dispose();
    _maxResultsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _api.fetchRecommendationAdminDashboard(),
        _api.fetchProducts(),
      ]);
      if (!mounted) return;
      final dashboard = results[0] as RecommendationDashboardModel;
      final products = results[1] as List<Product>;
      setState(() {
        _dashboard = dashboard;
        _products = products;
        _aprioriEnabled = dashboard.settings.aprioriEnabled;
        _contentBasedEnabled = dashboard.settings.contentBasedEnabled;
        _autoRebuildEnabled = dashboard.settings.autoRebuildEnabled;
        _supportController.text = _formatNumber(
          dashboard.settings.minSupport * 100,
        );
        _confidenceController.text = _formatNumber(
          dashboard.settings.minConfidence * 100,
        );
        _maxResultsController.text = dashboard.settings.maxResults.toString();
        if (_previewProductId == null && products.isNotEmpty) {
          _previewProductId = products.first.productId;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.recommendationLoadError(e.toString())),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatNumber(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  double? _parsePercent(TextEditingController controller) {
    return double.tryParse(controller.text.trim().replaceAll(',', '.'));
  }

  Future<bool> _saveSettings({bool showMessage = true}) async {
    final support = _parsePercent(_supportController);
    final confidence = _parsePercent(_confidenceController);
    final maxResults = int.tryParse(_maxResultsController.text.trim());
    if (support == null || support <= 0 || support > 100) {
      _showError(context.l10n.supportRangeError);
      return false;
    }
    if (confidence == null || confidence <= 0 || confidence > 100) {
      _showError(context.l10n.confidenceRangeError);
      return false;
    }
    if (maxResults == null || maxResults < 1 || maxResults > 20) {
      _showError(context.l10n.recommendationResultRangeError);
      return false;
    }

    setState(() => _saving = true);
    try {
      final message = await _api.updateRecommendationSettings(
        aprioriEnabled: _aprioriEnabled,
        contentBasedEnabled: _contentBasedEnabled,
        autoRebuildEnabled: _autoRebuildEnabled,
        minSupport: support / 100,
        minConfidence: confidence / 100,
        maxResults: maxResults,
      );
      if (!mounted) return false;
      if (showMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
      return true;
    } catch (e) {
      if (mounted) _showError(e.toString());
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _rebuild() async {
    if (!await _saveSettings(showMessage: false) || !mounted) return;
    setState(() => _rebuilding = true);
    try {
      final result = await _api.rebuildRecommendations();
      if (!mounted) return;
      final message =
          result['message']?.toString() ?? context.l10n.recommendationRebuilt;
      final baskets = result['totalBaskets'] ?? 0;
      final rules = result['rulesGenerated'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.recommendationBuildSummary(message, baskets, rules),
          ),
          backgroundColor: result['skipped'] == true
              ? Colors.orange.shade700
              : Colors.green.shade700,
        ),
      );
      await _loadData();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _rebuilding = false);
    }
  }

  Future<void> _clearRules() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteAllAprioriRules),
        content: Text(context.l10n.deleteAprioriWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.l10n.deleteRules),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      final message = await _api.clearRecommendationRules();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      await _loadData();
    } catch (e) {
      if (mounted) _showError(e.toString());
    }
  }

  Future<void> _previewContentBased() async {
    if (_previewProductId == null) return;
    setState(() => _previewing = true);
    try {
      final products = await _api.fetchSimilarProducts(_previewProductId!);
      if (!mounted) return;
      setState(() => _contentPreview = products);
    } finally {
      if (mounted) setState(() => _previewing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final dashboard = _dashboard;
    if (dashboard == null) {
      return Center(
        child: FilledButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          label: Text(context.l10n.tryAgain),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildStats(dashboard.stats),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 950;
                final settings = _buildSettingsCard();
                final explanation = _buildExplanationCard();
                return narrow
                    ? Column(
                        children: [
                          settings,
                          const SizedBox(height: 16),
                          explanation,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: settings),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: explanation),
                        ],
                      );
              },
            ),
            const SizedBox(height: 20),
            _buildContentPreview(),
            const SizedBox(height: 20),
            _buildRulesTable(dashboard.rules),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.recommendationManagementTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                context.l10n.recommendationManagementDescription,
                style: const TextStyle(color: Color(0xff667085)),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.refresh,
          onPressed: _loading ? null : _loadData,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildStats(RecommendationStatsModel stats) {
    final cards = [
      (
        context.l10n.eligibleBaskets,
        '${stats.eligibleBaskets}',
        Icons.shopping_basket,
        Colors.blue,
      ),
      (
        context.l10n.aprioriRules,
        '${stats.rulesCount}',
        Icons.account_tree,
        Colors.deepPurple,
      ),
      (
        context.l10n.coveredProducts,
        '${stats.coveredProducts}/${stats.activeProducts}',
        Icons.inventory_2,
        Colors.teal,
      ),
      (
        context.l10n.coverage,
        '${stats.coveragePercent.toStringAsFixed(1)}%',
        Icons.donut_large,
        Colors.orange,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 700
            ? constraints.maxWidth
            : (constraints.maxWidth - 48) / 4;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards.map((card) {
            return Container(
              width: width,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border(left: BorderSide(color: card.$4, width: 4)),
              ),
              child: Row(
                children: [
                  Icon(card.$3, color: card.$4, size: 30),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xff667085),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          card.$2,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSettingsCard() {
    return _card(
      title: context.l10n.operationSettings,
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.aprioriFrequentlyBoughtTogether),
            subtitle: Text(context.l10n.aprioriHistoryDescription),
            value: _aprioriEnabled,
            onChanged: (value) => setState(() => _aprioriEnabled = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.contentBasedSimilarProducts),
            subtitle: Text(context.l10n.contentBasedDescription),
            value: _contentBasedEnabled,
            onChanged: (value) => setState(() => _contentBasedEnabled = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(context.l10n.autoRebuildApriori),
            subtitle: Text(context.l10n.autoRebuildDescription),
            value: _autoRebuildEnabled,
            onChanged: _aprioriEnabled
                ? (value) => setState(() => _autoRebuildEnabled = value)
                : null,
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: _numberField(
                  _supportController,
                  'Min Support (%)',
                  'VD: 1',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  _confidenceController,
                  'Min Confidence (%)',
                  'VD: 10',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _numberField(
                  _maxResultsController,
                  context.l10n.maximumRecommendationResults,
                  '1–20',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _saveSettings,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(context.l10n.saveSettings),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _rebuilding || !_aprioriEnabled ? null : _rebuild,
                  icon: _rebuilding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.play_arrow),
                  label: Text(context.l10n.rebuildApriori),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    return _card(
      title: context.l10n.parameterMeaning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HelpRow(title: 'Support', text: context.l10n.supportExplanation),
          SizedBox(height: 18),
          _HelpRow(
            title: 'Confidence',
            text: context.l10n.confidenceExplanation,
          ),
          SizedBox(height: 18),
          _HelpRow(
            title: context.l10n.coverage,
            text: context.l10n.coverageExplanation,
          ),
          SizedBox(height: 18),
          Text(
            context.l10n.thresholdExplanation,
            style: const TextStyle(
              color: Color(0xff8a4b08),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPreview() {
    return _card(
      title: context.l10n.contentBasedPreview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _previewProductId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.sourceProduct,
                    border: const OutlineInputBorder(),
                  ),
                  items: _products
                      .map(
                        (product) => DropdownMenuItem(
                          value: product.productId,
                          child: Text(
                            '#${product.productId} · ${product.productName}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _previewProductId = value;
                    _contentPreview = [];
                  }),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _previewing || !_contentBasedEnabled
                      ? null
                      : _previewContentBased,
                  icon: _previewing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.science_outlined),
                  label: Text(context.l10n.runTest),
                ),
              ),
            ],
          ),
          if (_contentPreview.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _contentPreview
                  .map(
                    (product) => Chip(
                      avatar: const Icon(Icons.chair_outlined, size: 18),
                      label: Text(
                        '#${product.productId} · ${product.productName}',
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRulesTable(List<RecommendationRuleModel> rules) {
    return _card(
      title: context.l10n.currentAprioriRules(rules.length),
      trailing: TextButton.icon(
        onPressed: rules.isEmpty ? null : _clearRules,
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: Text(
          context.l10n.deleteAll,
          style: const TextStyle(color: Colors.red),
        ),
      ),
      child: rules.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text(context.l10n.noAprioriRules)),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(context.l10n.sourceProduct)),
                  DataColumn(
                    label: Text(context.l10n.accompanyingRecommendation),
                  ),
                  const DataColumn(label: Text('Support')),
                  const DataColumn(label: Text('Confidence')),
                  DataColumn(label: Text(context.l10n.updatedAt)),
                ],
                rows: rules.map((rule) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text('#${rule.productId} · ${rule.sourceProductName}'),
                      ),
                      DataCell(
                        Text(
                          '#${rule.recommendedProductId} · ${rule.recommendedProductName}',
                        ),
                      ),
                      DataCell(
                        Text('${(rule.support * 100).toStringAsFixed(2)}%'),
                      ),
                      DataCell(
                        Text('${(rule.confidence * 100).toStringAsFixed(2)}%'),
                      ),
                      DataCell(Text(_shortDate(rule.lastUpdated))),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _card({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffeaecf0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  String _shortDate(String value) {
    if (value.isEmpty) return '—';
    return value.replaceFirst('T', ' ').split('.').first;
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xff667085), height: 1.4),
        ),
      ],
    );
  }
}
