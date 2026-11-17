import 'package:flutter/material.dart';

/// Kategori seminar/workshop yang tersedia pada filter.
enum EventCategory {
  ai('AI', Icons.psychology),
  mobile('Mobile', Icons.phone_android),
  iot('IoT', Icons.sensors),
  cybersecurity('Cybersecurity', Icons.security);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Model data seminar / workshop.
class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.speaker,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.venue,
    required this.description,
    required this.quota,
    required this.color,
    required this.posterAsset,
    this.isWorkshop = false,
  });

  final String id;
  final String title;
  final String speaker;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final String time;
  final String venue;
  final String description;
  final int quota;
  final Color color;

  /// Path aset poster, contoh: assets/images/posters/01_generative_ai.jpg
  final String posterAsset;
  final bool isWorkshop;

  String get typeLabel => isWorkshop ? 'Workshop' : 'Seminar';

  String get dateLabel {
    if (endDate.difference(startDate).inDays == 0) {
      return formatDate(startDate);
    }
    return '${startDate.day} - ${formatDate(endDate)}';
  }
}

const List<String> _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// Contoh: 12 Mei 2026
String formatDate(DateTime d) => '${d.day} ${_monthNames[d.month - 1]} ${d.year}';

/// Contoh: Rp50.000
String formatRupiah(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return 'Rp$buffer';
}
