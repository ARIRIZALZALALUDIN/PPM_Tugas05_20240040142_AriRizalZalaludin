import 'event_item.dart';

enum ParticipantType {
  mahasiswa('Mahasiswa'),
  dosen('Dosen'),
  umum('Umum');

  const ParticipantType(this.label);
  final String label;
}

enum KitPackage {
  none('Tanpa Kit', 0),
  basic('Kit Basic', 50000),
  premium('Kit Premium', 100000);

  const KitPackage(this.label, this.price);
  final String label;
  final int price;
}

/// Model tiket hasil pendaftaran.
class RegistrationTicket {
  const RegistrationTicket({
    required this.id,
    required this.event,
    required this.name,
    required this.nim,
    required this.email,
    required this.whatsapp,
    required this.participantType,
    required this.attendanceDate,
    required this.kit,
    required this.donation,
    required this.createdAt,
  });

  final String id;
  final EventItem event;
  final String name;
  final String nim;
  final String email;
  final String whatsapp;
  final ParticipantType participantType;
  final DateTime attendanceDate;
  final KitPackage kit;
  final int donation;
  final DateTime createdAt;

  int get total => kit.price + donation;
}
