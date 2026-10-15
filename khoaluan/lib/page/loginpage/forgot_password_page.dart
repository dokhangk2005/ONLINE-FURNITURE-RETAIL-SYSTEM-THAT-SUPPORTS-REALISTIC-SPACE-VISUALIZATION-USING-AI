import 'dart:async';
import 'package:flutter/material.dart';
import '../../conf/responsive.dart';
import '../../l10n/l10n.dart';
import '../../services/api_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: Reset Password
  bool _isLoading = false;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Resend Timer
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final emailError =
        RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email)
        ? null
        : context.l10n.invalidEmail;
    if (emailError != null) {
      _showSnackBar(emailError, Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await ApiService().forgotPassword(email);
      setState(() {
        _currentStep = 2;
      });
      _startResendTimer();
      if (!mounted) return;
      _showSnackBar(
        res['message']?.toString() ?? context.l10n.verificationCodeSent,
        Colors.green,
      );
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;
    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    try {
      await ApiService().forgotPassword(email);
      if (!mounted) return;
      _startResendTimer();
      _showSnackBar(context.l10n.otpResent, Colors.green);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOtp() async {
    final otp = _otpController.text.trim();
    final otpError = otp.isEmpty
        ? context.l10n.otpRequired
        : !RegExp(r'^\d{6}$').hasMatch(otp)
        ? context.l10n.otpDigitsRequired(6)
        : null;
    if (otpError != null) {
      _showSnackBar(otpError, Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService().verifyResetOtp(_emailController.text.trim(), otp);
      if (!mounted) return;
      setState(() => _currentStep = 3);
      _showSnackBar(context.l10n.otpVerifiedSetPassword, Colors.green);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitNewPassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    final passError = newPass.isEmpty
        ? context.l10n.requiredField(context.l10n.newPasswordField)
        : newPass.length < 6
        ? context.l10n.minLengthField(context.l10n.newPasswordField, 6)
        : null;
    if (passError != null) {
      _showSnackBar(passError, Colors.red);
      return;
    }
    final confirmError = confirmPass.isEmpty
        ? context.l10n.requiredField(context.l10n.confirmPasswordField)
        : confirmPass != newPass
        ? context.l10n.passwordMismatch
        : null;
    if (confirmError != null) {
      _showSnackBar(confirmError, Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService().resetPassword(
        _emailController.text.trim(),
        _otpController.text.trim(),
        newPass,
      );
      if (!mounted) return;
      _showSnackBar(context.l10n.passwordRecoverySuccess, Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String text, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _evaluatePasswordStrength(String pass) {
    if (pass.isEmpty) return 0;
    if (pass.length < 6) return 1; // Yếu
    bool hasLetters = pass.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigits = pass.contains(RegExp(r'[0-9]'));
    bool hasSpecialOrUpper =
        pass.contains(RegExp(r'[A-Z]')) ||
        pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (pass.length >= 8 && hasLetters && hasDigits && hasSpecialOrUpper) {
      return 3;
    }
    if (hasLetters && hasDigits) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    Widget formContent = _buildStepperContent(isMobile, isTablet);

    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/loginpage/login.png',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: formContent,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 60,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: formContent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperContent(bool isMobile, bool isTablet) {
    final titleSize = isMobile ? 24.0 : 30.0;
    final bodySize = isMobile ? 13.0 : 14.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Back Button
        InkWell(
          onTap: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 20, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                _currentStep > 1
                    ? context.l10n.backPreviousStep
                    : context.l10n.backToLogin,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Step indicator banner
        Row(
          children: [
            _buildStepCircle(1, '1. Email', _currentStep >= 1),
            _buildStepDivider(_currentStep >= 2),
            _buildStepCircle(2, context.l10n.otpStep, _currentStep >= 2),
            _buildStepDivider(_currentStep >= 3),
            _buildStepCircle(
              3,
              context.l10n.newPasswordStep,
              _currentStep >= 3,
            ),
          ],
        ),
        const SizedBox(height: 32),

        if (_currentStep == 1) _buildStep1(titleSize, bodySize),
        if (_currentStep == 2) _buildStep2(titleSize, bodySize),
        if (_currentStep == 3) _buildStep3(titleSize, bodySize),
      ],
    );
  }

  Widget _buildStepCircle(int stepNum, String label, bool active) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: active
                ? const Color(0xff2d2d2d)
                : Colors.grey.shade300,
            child: Text(
              stepNum.toString(),
              style: TextStyle(
                color: active ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? Colors.black87 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool active) {
    return Container(
      width: 25,
      height: 2,
      color: active ? const Color(0xff2d2d2d) : Colors.grey.shade300,
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  // STEP 1: Email
  Widget _buildStep1(double titleSize, double bodySize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.passwordRecoveryTitle,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.passwordRecoveryDescription,
          style: TextStyle(
            fontSize: bodySize,
            color: const Color(0xff505050),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          context.l10n.yourEmailRequired,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: context.l10n.emailExample,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xffd8d8d8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            onSubmitted: (_) => _submitEmail(),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2d2d2d),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    context.l10n.sendOtp,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // STEP 2: OTP
  Widget _buildStep2(double titleSize, double bodySize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.verifyOtpTitle,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.otpEmailInstruction(_emailController.text),
          style: TextStyle(
            fontSize: bodySize,
            color: const Color(0xff505050),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          context.l10n.sixDigitVerificationCode,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 6.0,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: '',
              hintText: '• • • • • •',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xffd8d8d8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            onSubmitted: (_) => _submitOtp(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _resendCountdown > 0
                  ? context.l10n.resendAfterSeconds(_resendCountdown)
                  : context.l10n.emailNotReceived,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            TextButton(
              onPressed: (_resendCountdown > 0 || _isLoading)
                  ? null
                  : _resendOtp,
              child: Text(
                context.l10n.resendNewCode,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2d2d2d),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    context.l10n.confirmOtp,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // STEP 3: Reset Password
  Widget _buildStep3(double titleSize, double bodySize) {
    int strength = _evaluatePasswordStrength(_newPasswordController.text);
    Color strengthColor = Colors.grey;
    String strengthText = context.l10n.notEntered;
    double progress = 0.0;
    if (strength == 1) {
      strengthColor = Colors.red;
      strengthText = context.l10n.weak;
      progress = 0.33;
    } else if (strength == 2) {
      strengthColor = Colors.orange;
      strengthText = context.l10n.medium;
      progress = 0.66;
    } else if (strength == 3) {
      strengthColor = Colors.green;
      strengthText = context.l10n.strong;
      progress = 1.0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.createNewPassword,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.verifiedPasswordInstruction(_emailController.text),
          style: TextStyle(
            fontSize: bodySize,
            color: const Color(0xff505050),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          context.l10n.newPasswordRequired,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: !_showNewPassword,
          onChanged: (val) =>
              setState(() {}), // Trigger re-evaluating strength meter
          decoration: InputDecoration(
            hintText: context.l10n.minimumSixCharactersHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xffd8d8d8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.black),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showNewPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: () =>
                  setState(() => _showNewPassword = !_showNewPassword),
            ),
          ),
        ),
        if (_newPasswordController.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.passwordStrength(strengthText),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: strengthColor,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Text(
          context.l10n.confirmPasswordRequired,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: !_showConfirmPassword,
          decoration: InputDecoration(
            hintText: context.l10n.confirmNewPasswordHint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xffd8d8d8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.black),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
          ),
          onSubmitted: (_) => _submitNewPassword(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitNewPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2d2d2d),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    context.l10n.savePasswordComplete,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1.0,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
