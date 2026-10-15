import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/api_service.dart';

class SetPasswordPage extends StatefulWidget {
  const SetPasswordPage({super.key, required this.token});

  final String token;

  @override
  State<SetPasswordPage> createState() => _SetPasswordPageState();
}

class _SetPasswordPageState extends State<SetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loadingLink = true;
  bool _submitting = false;
  bool _showPassword = false;
  String? _email;
  String? _linkError;

  @override
  void initState() {
    super.initState();
    _loadLink();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadLink() async {
    if (widget.token.trim().isEmpty) {
      setState(() {
        _loadingLink = false;
        _linkError = '';
      });
      return;
    }
    try {
      final data = await ApiService().getRegistrationLinkInfo(widget.token);
      if (!mounted) return;
      setState(() {
        _email = (data['email'] ?? data['Email'])?.toString();
        _loadingLink = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingLink = false;
        _linkError = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      final message = await ApiService().completeRegistration(
        token: widget.token,
        fullName: _nameController.text.trim(),
        newPassword: _passwordController.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.registrationSuccess),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              },
              child: Text(context.l10n.login),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f3),
      appBar: AppBar(
        title: Text(context.l10n.accountSetup),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Color(0x14000000), blurRadius: 24),
              ],
            ),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loadingLink) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_linkError != null) {
      return Column(
        children: [
          Icon(Icons.link_off, size: 56, color: Colors.red.shade600),
          const SizedBox(height: 18),
          Text(
            context.l10n.invalidRegistrationLink,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            _linkError!.isEmpty
                ? context.l10n.registrationLinkMissingToken
                : _linkError!,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (_) => false,
            ),
            child: Text(context.l10n.requestNewLink),
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.createYourPassword,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            _email ?? '',
            style: const TextStyle(color: Color(0xff555555), fontSize: 15),
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return context.l10n.requiredField(context.l10n.fullName);
              }
              return text.length < 2
                  ? context.l10n.minLengthField(context.l10n.fullName, 2)
                  : null;
            },
            decoration: InputDecoration(
              labelText: context.l10n.fullName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            autofillHints: const [AutofillHints.newPassword],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.requiredField(
                  context.l10n.newPasswordField,
                );
              }
              return value.length < 8
                  ? context.l10n.minLengthField(
                      context.l10n.newPasswordField,
                      8,
                    )
                  : null;
            },
            decoration: InputDecoration(
              labelText: context.l10n.newPasswordField,
              helperText: context.l10n.minimumEightCharacters,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _showPassword = !_showPassword),
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _confirmController,
            obscureText: !_showPassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.requiredField(
                  context.l10n.confirmPasswordField,
                );
              }
              return value != _passwordController.text
                  ? context.l10n.passwordMismatch
                  : null;
            },
            onFieldSubmitted: (_) => _submitting ? null : _submit(),
            decoration: InputDecoration(
              labelText: context.l10n.confirmPasswordField,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff2d2d2d),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(context.l10n.completeRegistration),
            ),
          ),
        ],
      ),
    );
  }
}
