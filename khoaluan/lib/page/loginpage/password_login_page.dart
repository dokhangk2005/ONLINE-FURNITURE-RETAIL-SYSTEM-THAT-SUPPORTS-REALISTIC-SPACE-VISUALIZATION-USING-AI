import 'package:flutter/material.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/language_switcher.dart';
import 'forgot_password_page.dart';

class PasswordLoginPage extends StatefulWidget {
  const PasswordLoginPage({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<PasswordLoginPage> createState() => _PasswordLoginPageState();
}

class _PasswordLoginPageState extends State<PasswordLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool showPassword = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.incompleteLogin),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final user = await ApiService().loginUser(email, password);
      if (!mounted) return;

      // Lưu thông tin đăng nhập
      AuthService.login(user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.loginSuccess(user['fullName']?.toString() ?? ''),
          ),
        ),
      );

      // Chuyển hướng theo vai trò (Admin = 1, Shipper = 3)
      final dynamic roleIdValue = user['roleId'] ?? user['RoleId'];
      if (roleIdValue != null &&
          (roleIdValue.toString() == '1' || roleIdValue == 1)) {
        Navigator.of(context).pushReplacementNamed('/admin');
      } else if (roleIdValue != null &&
          (roleIdValue.toString() == '3' || roleIdValue == 3)) {
        Navigator.of(context).pushReplacementNamed('/shipper');
      } else {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: const _CompactAuthLanguageSwitcher(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/loginpage/login.png',
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 34),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _PasswordLoginForm(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    showPassword: showPassword,
                    isLoading: isLoading,
                    onTogglePasswordVisibility: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    onLogin: _onLogin,
                    formWidth: double.infinity,
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: const _CompactAuthLanguageSwitcher(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Row(
        children: [
          if (!isTablet || context.screenWidth >= 768)
            Expanded(
              flex: isTablet ? 4 : 5,
              child: SizedBox.expand(
                child: Image.asset(
                  'assets/images/loginpage/login.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            flex: isTablet ? 6 : 6,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 0,
                    vertical: 40,
                  ),
                  child: _PasswordLoginForm(
                    formKey: _formKey,
                    emailController: emailController,
                    passwordController: passwordController,
                    showPassword: showPassword,
                    isLoading: isLoading,
                    onTogglePasswordVisibility: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    onLogin: _onLogin,
                    formWidth: isTablet ? double.infinity : 600,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Extracted Password Login Form ──────────────────────────────────────────────
class _CompactAuthLanguageSwitcher extends StatelessWidget {
  const _CompactAuthLanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 70,
      height: 40,
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        clipBehavior: Clip.antiAlias,
        child: LanguageSwitcher(height: 40, horizontalPadding: 8),
      ),
    );
  }
}

class _PasswordLoginForm extends StatelessWidget {
  const _PasswordLoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.showPassword,
    required this.isLoading,
    required this.onTogglePasswordVisibility,
    required this.onLogin,
    required this.formWidth,
    required this.onBack,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool showPassword;
  final bool isLoading;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onLogin;
  final double formWidth;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    final titleSize = isMobile ? 26.0 : (isTablet ? 28.0 : 34.0);
    final bodySize = isMobile ? 13.0 : 14.0;
    final l10n = context.l10n;

    Widget content = Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.passwordLoginTitle,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            l10n.passwordLoginWelcome,
            style: TextStyle(
              fontSize: bodySize,
              color: const Color(0xff505050),
              height: 1.6,
            ),
          ),

          SizedBox(height: isMobile ? 32 : 46),

          Text(
            l10n.emailOrUsername,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.text,
            validator: (value) {
              final input = value?.trim() ?? '';
              if (input.isEmpty) {
                return l10n.requiredField(l10n.emailOrUsernameField);
              }
              if (input.length < 3) {
                return l10n.minLengthField(l10n.emailOrUsernameField, 3);
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: l10n.emailOrUsernameHint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: Color(0xffd8d8d8),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            l10n.password,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: passwordController,
            obscureText: !showPassword,
            validator: (value) => value == null || value.isEmpty
                ? l10n.requiredField(l10n.passwordField)
                : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: l10n.passwordHint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(
                  color: Color(0xffd8d8d8),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.black, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: onTogglePasswordVisibility,
              ),
            ),
          ),

          const SizedBox(height: 20),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
              child: Text(
                l10n.forgotPassword,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Login button
          MouseRegion(
            cursor: isLoading
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: isLoading ? null : onLogin,
              child: Container(
                width: double.infinity,
                height: 60,
                color: const Color(0xff2d2d2d),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        l10n.login,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: isMobile ? 2 : 4,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBack,
              child: Text(
                l10n.backToLoginOptions,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          const SizedBox(height: 44),
        ],
      ),
    );

    if (formWidth == double.infinity) return content;

    return SizedBox(width: formWidth, child: content);
  }
}
