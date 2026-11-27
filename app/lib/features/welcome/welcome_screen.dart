import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/languages.dart';
import '../../data/models.dart';
import '../../state/settings_provider.dart';
import '../splash/splash_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight - 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(size: 48),
                  const SizedBox(height: 24),
                  Text(s('welcome'), style: t.headlineLarge),
                  const SizedBox(height: 12),
                  Text(s('intro'),
                      style: t.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Text(s('language'), style: t.labelLarge),
                  const SizedBox(height: 8),
                  Row(children: [
                    for (final (i, l) in kLanguages.indexed) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: _LanguageCard(
                          label: l.native,
                          selected: settings.language == l.code,
                          onTap: () => notifier.setLanguage(l.code),
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 24),
                  Text(s('state'), style: t.labelLarge),
                  const SizedBox(height: 8),
                  StatePicker(
                    value: settings.homeState,
                    language: settings.language,
                    hint: s('chooseState'),
                    onChanged: notifier.setHomeState,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s('alerts'), style: t.bodyLarge),
                    subtitle: Text(s('alertDetail')),
                    value: settings.breakingAlerts,
                    onChanged: notifier.setBreakingAlerts,
                  ),
                  Text(s('notPermission'), style: t.bodySmall),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      // Router redirect moves us to /feed once onboarded flips.
                      onPressed: notifier.completeOnboarding,
                      child: Text(s('start')),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(child: Text(s('later'), style: t.bodySmall)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: Theme.of(context).textTheme.bodyLarge),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(Icons.check_circle_outline, size: 20, color: scheme.primary),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// Home-state dropdown shared by Welcome, Discover and Settings.
class StatePicker extends StatelessWidget {
  const StatePicker({
    super.key,
    required this.value,
    required this.language,
    required this.onChanged,
    this.hint,
    this.allLabel,
  });
  final String? value;
  final String language;
  final String? hint;

  /// When set, adds a leading "all" entry that maps to null.
  final String? allLabel;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      style: Theme.of(context).textTheme.bodyLarge,
      hint: hint == null ? null : Text(hint!),
      decoration: const InputDecoration(),
      items: [
        if (allLabel != null) DropdownMenuItem<String?>(value: null, child: Text(allLabel!)),
        for (final st in kStates)
          DropdownMenuItem<String?>(value: st, child: Text(stateLabel(st, language))),
      ],
      onChanged: onChanged,
    );
  }
}
