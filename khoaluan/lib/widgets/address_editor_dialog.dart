import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/api_service.dart';

class AddressEditorDialog extends StatefulWidget {
  const AddressEditorDialog({
    super.key,
    required this.apiService,
    this.address,
  });

  final ApiService apiService;
  final Map<String, dynamic>? address;

  @override
  State<AddressEditorDialog> createState() => _AddressEditorDialogState();
}

class _AddressEditorDialogState extends State<AddressEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late String _sessionToken;

  Timer? _debounce;
  List<Map<String, dynamic>> _suggestions = [];
  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isSearching = false;
  bool _isRetrieving = false;
  bool _isSaving = false;
  bool _applyingSuggestion = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _nameController = TextEditingController(
      text: (address?['recipientName'] ?? '').toString(),
    );
    _phoneController = TextEditingController(
      text: (address?['phone'] ?? '').toString(),
    );
    _addressController = TextEditingController(
      text: (address?['addressLine'] ?? '').toString(),
    );
    _selectedLabel = _normalizeLabel(address?['label']);
    _isDefault = address?['isDefault'] == true;
    _sessionToken = _newSessionToken();
    _addressController.addListener(_onAddressChanged);
  }

  String _newSessionToken() {
    final random = Random();
    return '${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(1000000)}';
  }

  String _normalizeLabel(Object? value) {
    final label = value?.toString().trim().toLowerCase() ?? '';
    if (label == 'company' || label == 'công ty' || label == 'work') {
      return 'Company';
    }
    if (label == 'other' || label == 'khác') return 'Other';
    return 'Home';
  }

  void _onAddressChanged() {
    if (_applyingSuggestion) return;
    _debounce?.cancel();
    final query = _addressController.text.trim();
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
      return;
    }

    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await widget.apiService.suggestAddresses(
          query,
          _sessionToken,
        );
        if (!mounted || query != _addressController.text.trim()) return;
        setState(() {
          _suggestions = results;
          _isSearching = false;
        });
      } catch (_) {
        if (!mounted || query != _addressController.text.trim()) return;
        setState(() {
          _suggestions = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    final mapboxId = (suggestion['mapbox_id'] ?? '').toString();
    if (mapboxId.isEmpty || _isRetrieving) return;
    setState(() => _isRetrieving = true);
    try {
      final result = await widget.apiService.retrieveAddress(
        mapboxId,
        _sessionToken,
      );
      final features = result['features'] as List? ?? const [];
      var addressLine = (suggestion['full_address'] ?? suggestion['name'] ?? '')
          .toString()
          .trim();
      if (features.isNotEmpty && features.first is Map) {
        final feature = Map<String, dynamic>.from(features.first as Map);
        final properties = feature['properties'] is Map
            ? Map<String, dynamic>.from(feature['properties'] as Map)
            : <String, dynamic>{};
        addressLine = _fullAddressFromProperties(properties, addressLine);
      }

      if (!mounted) return;
      _applyingSuggestion = true;
      _addressController.text = addressLine;
      _addressController.selection = TextSelection.collapsed(
        offset: _addressController.text.length,
      );
      _applyingSuggestion = false;
      setState(() {
        _suggestions = [];
        _isRetrieving = false;
        _sessionToken = _newSessionToken();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isRetrieving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  String _fullAddressFromProperties(
    Map<String, dynamic> properties,
    String fallback,
  ) {
    final fullAddress = (properties['full_address'] ?? '').toString().trim();
    if (fullAddress.isNotEmpty) return fullAddress;

    final context = properties['context'] is Map
        ? Map<String, dynamic>.from(properties['context'] as Map)
        : <String, dynamic>{};
    final parts = <String>[];
    void addPart(Object? value) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && !parts.contains(text)) parts.add(text);
    }

    addPart(properties['name']);
    addPart((context['neighborhood'] as Map?)?['name']);
    addPart((context['place'] as Map?)?['name']);
    addPart((context['district'] as Map?)?['name']);
    addPart((context['region'] as Map?)?['name']);
    return parts.isEmpty ? fallback : parts.join(', ');
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final l10n = context.l10n;
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addressRequiredFields)));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.apiService.saveAddress({
        'recipientName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'addressLine': _addressController.text.trim(),
        'label': _selectedLabel,
        'isDefault': _isDefault,
      }, id: widget.address?['addressId'] as int?);
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _addressController.removeListener(_onAddressChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(_isEditing ? l10n.editAddress : l10n.addAddress),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.recipient,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.fullAddress,
                  hintText: l10n.addressSearchHint,
                  border: const OutlineInputBorder(),
                  suffixIcon: _isSearching || _isRetrieving
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Icon(Icons.location_on_outlined),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffD7DFEA)),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff2563EB),
                          ),
                          title: Text((suggestion['name'] ?? '').toString()),
                          subtitle: Text(
                            (suggestion['full_address'] ?? '').toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectSuggestion(suggestion),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                l10n.addressLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: 'Home',
                      icon: const Icon(Icons.home_outlined),
                      label: Text(l10n.addressLabelHome),
                    ),
                    ButtonSegment(
                      value: 'Company',
                      icon: const Icon(Icons.business_outlined),
                      label: Text(l10n.addressLabelCompany),
                    ),
                    ButtonSegment(
                      value: 'Other',
                      icon: const Icon(Icons.place_outlined),
                      label: Text(l10n.addressLabelOther),
                    ),
                  ],
                  selected: {_selectedLabel},
                  onSelectionChanged: (selection) {
                    setState(() => _selectedLabel = selection.first);
                  },
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.makeDefault),
                value: _isDefault,
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() => _isDefault = value ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}
