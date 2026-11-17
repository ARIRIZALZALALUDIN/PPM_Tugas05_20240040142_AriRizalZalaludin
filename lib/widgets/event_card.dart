import 'package:flutter/material.dart';

import '../models/event_item.dart';
import 'poster_viewer.dart';

/// Kartu seminar yang dapat disentuh (InkWell).
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.onTap,
  });

  final EventItem event;
  final bool isRegistered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 68,
                height: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: PosterImage(event: event, cacheWidth: 240),
                    ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: event.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Icon(event.category.icon,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.speaker,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _InfoItem(
                            icon: Icons.calendar_today, text: event.dateLabel),
                        _InfoItem(icon: Icons.place_outlined, text: event.venue),
                        _InfoItem(
                            icon: Icons.local_offer_outlined,
                            text: '${event.typeLabel} • ${event.category.label}'),
                      ],
                    ),
                    if (isRegistered) ...[
                      const SizedBox(height: 8),
                      Chip(
                        avatar: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Sudah terdaftar'),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
      ],
    );
  }
}
