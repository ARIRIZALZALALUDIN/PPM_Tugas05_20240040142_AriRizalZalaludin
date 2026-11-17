import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/poster_viewer.dart';

/// Tab "Tiket Terdaftar": geser tiket ke kiri untuk membatalkan.
class RegisteredTicketsScreen extends StatelessWidget {
  const RegisteredTicketsScreen({
    super.key,
    required this.tickets,
    required this.onCancel,
    required this.onBrowse,
  });

  final List<RegistrationTicket> tickets;
  final ValueChanged<RegistrationTicket> onCancel;
  final VoidCallback onBrowse;

  Future<bool?> _confirmCancel(BuildContext context, RegistrationTicket t) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Batalkan tiket?'),
        content: Text(
          'Tiket "${t.event.title}" atas nama ${t.name} akan dibatalkan dan '
          'tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tickets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 72, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text('Belum ada tiket aktif', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              const Text(
                'Daftar seminar terlebih dahulu untuk mendapatkan tiket.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onBrowse,
                icon: const Icon(Icons.search),
                label: const Text('Lihat Seminar'),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.swipe_left, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Geser tiket ke kiri untuk membatalkan.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final t = tickets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmCancel(context, t),
                      onDismissed: (_) => onCancel(t),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline,
                                color: theme.colorScheme.onErrorContainer),
                            const SizedBox(width: 8),
                            Text('Batalkan',
                                style: TextStyle(
                                    color: theme.colorScheme.onErrorContainer)),
                          ],
                        ),
                      ),
                      child: _TicketCard(ticket: t),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket});

  final RegistrationTicket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = ticket;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              height: 76,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: PosterImage(event: t.event, cacheWidth: 200),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('${t.name} • ${t.nim}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${t.participantType.label} • ${t.kit.label}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('Hadir: ${formatDate(t.attendanceDate)}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Chip(
                        label: Text(t.id),
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        'Total ${formatRupiah(t.total)}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Icon(Icons.qr_code_2, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: 4),
                Text('Aktif',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.green.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
