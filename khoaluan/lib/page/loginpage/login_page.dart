import 'package:flutter/material.dart';

import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../services/api_service.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/web_page_route.dart';
import 'password_login_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validateEmail() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.invalidEmail)));
    }
    return valid;
  }

  void _openPasswordLogin() {
    if (!_validateEmail()) return;
    Navigator.push(
      context,
      WebPageRoute(
        page: PasswordLoginPage(initialEmail: _emailController.text.trim()),
        animated: false,
      ),
    );
  }

  Future<void> _quickRegister() async {
    if (!_validateEmail()) return;
    setState(() => _isRegistering = true);
    try {
      await ApiService().quickRegister(_emailController.text.trim());
      if (!mounted) return;
      final l10n = context.l10n;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.checkEmailTitle),
          content: Text(l10n.quickRegisterDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.understood),
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
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final l10n = context.l10n;
    final form = Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 48,
          vertical: 40,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.loginTitle,
                  style: TextStyle(
                    fontSize: isMobile ? 28 : 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.loginIntro,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Color(0xff555555),
                  ),
                ),
                const SizedBox(height: 36),
                Text(
                  l10n.emailAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .5,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    final validEmail = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(email);
                    return validEmail ? null : l10n.invalidEmail;
                  },
                  onFieldSubmitted: (_) => _openPasswordLogin(),
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _isRegistering ? null : _openPasswordLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xff2d2d2d),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: Text(l10n.loginWithPassword),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isRegistering ? null : _quickRegister,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xff2d2d2d)),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: _isRegistering
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.quickRegister),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.secureLinkHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff666666),
                  ),
                ),
                const SizedBox(height: 34),
                TextButton(
                  onPressed: () => Navigator.of(context).canPop()
                      ? Navigator.pop(context)
                      : Navigator.pushReplacementNamed(context, '/'),
                  child: Text(l10n.backHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final pageContent = isMobile
        ? SafeArea(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/loginpage/login.png',
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),
                Expanded(child: form),
              ],
            ),
          )
        : Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/loginpage/login.png',
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(child: form),
            ],
          );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: pageContent),
          const Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: SizedBox(
                width: 70,
                height: 40,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  child: LanguageSwitcher(height: 40, horizontalPadding: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
