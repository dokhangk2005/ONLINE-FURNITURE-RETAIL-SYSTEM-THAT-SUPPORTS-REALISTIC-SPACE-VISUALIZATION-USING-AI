import 'package:flutter/material.dart';
import '../widgets/main_layout.dart';
import '../l10n/l10n.dart';

class StaticInfoPage extends StatelessWidget {
  const StaticInfoPage({super.key, required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final about = type == 'about';
    return MainLayout(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  about ? context.l10n.aboutTitle : context.l10n.contactTitle,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  about
                      ? context.l10n.aboutDescription
                      : context.l10n.contactDescription,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
