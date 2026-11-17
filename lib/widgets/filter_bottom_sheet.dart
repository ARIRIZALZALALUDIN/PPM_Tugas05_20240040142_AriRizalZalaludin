import 'package:flutter/material.dart';

import '../models/event_item.dart';

/// Kondisi filter pada daftar seminar.
class EventFilter {
  const EventFilter({this.category, this.hideRegistered = false});

  final EventCategory? category;
  final bool hideRegistered;

  bool get isActive => category != null || hideRegistered;
}

Future<EventFilter?> showFilterBottomSheet(
  BuildContext context,
  EventFilter current,
) {
  return showModalBottomSheet<EventFilter>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FilterSheet(initial: current),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final EventFilter initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late EventCategory? _category = widget.initial.category;
  late bool _hideRegistered = widget.initial.hideRegistered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter Seminar', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Kategori', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Semua'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final c in EventCategory.values)
                  ChoiceChip(
                    avatar: Icon(c.icon, size: 18),
                    label: Text(c.label),
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sembunyikan yang sudah saya daftar'),
              value: _hideRegistered,
              onChanged: (v) => setState(() => _hideRegistered = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, const EventFilter()),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      EventFilter(
                        category: _category,
                        hideRegistered: _hideRegistered,
                      ),
                    ),
                    child: const Text('Terapkan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
