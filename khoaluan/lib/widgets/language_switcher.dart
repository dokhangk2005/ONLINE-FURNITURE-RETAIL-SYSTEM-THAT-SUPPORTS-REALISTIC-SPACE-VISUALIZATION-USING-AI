import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/locale_service.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({
    super.key,
    this.color = Colors.black,
    this.height = 48,
    this.horizontalPadding = 12,
  });

  final Color color;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final currentCode = LocaleService.locale.value.languageCode;
    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      initialValue: currentCode,
      onSelected: LocaleService.setLanguage,
      itemBuilder: (context) => [
        _languageItem(
          code: 'vi',
          label: context.l10n.vietnamese,
          currentCode: currentCode,
        ),
        _languageItem(
          code: 'en',
          label: context.l10n.english,
          currentCode: currentCode,
        ),
      ],
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, color: color, size: 23),
            const SizedBox(width: 5),
            Text(
              currentCode.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _languageItem({
    required String code,
    required String label,
    required String currentCode,
  }) {
    return PopupMenuItem(
      value: code,
      child: Row(
        children: [
          if (currentCode == code) const Icon(Icons.check, size: 18),
          if (currentCode != code) const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
