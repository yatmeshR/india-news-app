import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/settings_provider.dart';
import '../welcome/welcome_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget section(String label) => Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: t.labelLarge?.copyWith(color: scheme.onSurfaceVariant, letterSpacing: 1),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(s('settings'), style: t.headlineSmall),
        section(s('preferences')),
        Text(s('language'), style: t.bodyLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: settings.language,
          isExpanded: true,
          style: t.bodyLarge,
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
          ],
          onChanged: (v) => v == null ? null : n.setLanguage(v),
        ),
        section(s('appearance')),
        Row(children: [
          for (final (mode, label, icon) in [
            (ThemeMode.system, s('system'), Icons.smartphone),
            (ThemeMode.light, s('light'), Icons.light_mode_outlined),
            (ThemeMode.dark, s('dark'), Icons.dark_mode_outlined),
          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ModeTile(
                  label: label,
                  icon: icon,
                  selected: settings.themeMode == mode,
                  onTap: () => n.setThemeMode(mode),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 20),
        Text(s('textSize'), style: t.bodyLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<TextSizeSetting>(
          initialValue: settings.textSize,
          isExpanded: true,
          style: t.bodyLarge,
          items: [
            DropdownMenuItem(value: TextSizeSetting.small, child: Text(s('small'))),
            DropdownMenuItem(value: TextSizeSetting.normal, child: Text(s('normal'))),
            DropdownMenuItem(value: TextSizeSetting.large, child: Text(s('large'))),
            DropdownMenuItem(value: TextSizeSetting.accessible, child: Text(s('accessible'))),
          ],
          onChanged: (v) => v == null ? null : n.setTextSize(v),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Text(s('welcome').split('\n').first, style: t.bodyLarge),
        ),
        const SizedBox(height: 8),
        Text(s('fontNote'), style: t.bodySmall),
        const SizedBox(height: 20),
        Text(s('state'), style: t.bodyLarge),
        const SizedBox(height: 8),
        StatePicker(
          value: settings.homeState,
          language: settings.language,
          allLabel: s('all'),
          onChanged: n.setHomeState,
        ),
        section(s('notifications')),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s('breaking'), style: t.bodyLarge),
          subtitle: Text(s('alertDetail')),
          value: settings.breakingAlerts,
          onChanged: n.setBreakingAlerts,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s('digest'), style: t.bodyLarge),
          value: settings.dailyDigest,
          onChanged: n.setDailyDigest,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 48,
          enabled: settings.dailyDigest,
          title: Text(s('digestTime')),
          trailing: Text(settings.digestTime.format(context), style: t.labelLarge),
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: settings.digestTime);
            if (picked != null) n.setDigestTime(picked);
          },
        ),
        section(s('about')),
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 48,
          title: Text(s('privacy')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(s('privacy')),
              content: SingleChildScrollView(child: Text(s('privacyText'))),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s('done')))],
            ),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          minTileHeight: 48,
          title: Text(s('feedback')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _feedback(context, ref),
        ),
        const SizedBox(height: 8),
        Text(s('version'), style: t.bodySmall),
      ],
    );
  }

  Future<void> _feedback(BuildContext context, WidgetRef ref) {
    final s = ref.read(stringsProvider);
    final controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s('feedback')),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(hintText: s('feedbackPlaceholder')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s('cancel'))),
          FilledButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: controller.text));
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s('feedbackThanks'))));
              }
            },
            child: Text(s('copyFeedback')),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : scheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: selected ? scheme.primary : null),
              const SizedBox(height: 6),
              Text(label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected ? scheme.primary : null,
                      )),
            ]),
          ),
        ),
      ),
    );
  }
}
