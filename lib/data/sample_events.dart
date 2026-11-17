import 'package:flutter/material.dart';

import '../models/event_item.dart';

DateTime _day(int offset) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
}

/// Data contoh. Tanggal dihitung dari hari ini agar selalu relevan.
final List<EventItem> sampleEvents = [
  EventItem(
    id: 'EVT-01',
    title: 'Generative AI untuk Produktivitas Kampus',
    speaker: 'Dr. Rina Kusuma, M.Kom.',
    category: EventCategory.ai,
    startDate: _day(7),
    endDate: _day(7),
    time: '09.00 - 12.00 WIB',
    venue: 'Aula Utama',
    description:
        'Pengenalan generative AI, prompt engineering, dan etika penggunaan AI untuk tugas kuliah dan penelitian.',
    quota: 150,
    color: Colors.indigo,
    posterAsset: 'assets/images/posters/01_generative_ai.jpg',
  ),
  EventItem(
    id: 'EVT-02',
    title: 'Workshop Computer Vision dengan Python',
    speaker: 'Bagas Prasetyo, M.T.',
    category: EventCategory.ai,
    startDate: _day(14),
    endDate: _day(15),
    time: '13.00 - 16.00 WIB',
    venue: 'Lab AI',
    description:
        'Praktik klasifikasi gambar dan deteksi objek menggunakan Python, OpenCV, dan model pretrained.',
    quota: 40,
    color: Colors.deepPurple,
    posterAsset: 'assets/images/posters/02_computer_vision.jpg',
    isWorkshop: true,
  ),
  EventItem(
    id: 'EVT-03',
    title: 'Membangun Aplikasi Mobile dengan Flutter 3',
    speaker: 'Dinda Maharani, S.T.',
    category: EventCategory.mobile,
    startDate: _day(9),
    endDate: _day(9),
    time: '10.00 - 12.00 WIB',
    venue: 'Aula Utama',
    description:
        'Dasar widget, layout, dan state management untuk membangun aplikasi lintas platform.',
    quota: 120,
    color: Colors.teal,
    posterAsset: 'assets/images/posters/03_flutter_3.jpg',
  ),
  EventItem(
    id: 'EVT-04',
    title: 'Workshop UI Responsif Material 3',
    speaker: 'Fajar Nugroho, S.Kom.',
    category: EventCategory.mobile,
    startDate: _day(16),
    endDate: _day(16),
    time: '09.00 - 15.00 WIB',
    venue: 'Ruang Workshop Mobile',
    description:
        'Praktik membuat tampilan adaptif dan bebas overflow memakai Material 3 dan Flutter Inspector.',
    quota: 35,
    color: Colors.cyan.shade700,
    posterAsset: 'assets/images/posters/04_ui_responsif_material3.jpg',
    isWorkshop: true,
  ),
  EventItem(
    id: 'EVT-05',
    title: 'IoT Cerdas: Dari Sensor ke Dashboard',
    speaker: 'Ir. Hendra Wijaya, M.T.',
    category: EventCategory.iot,
    startDate: _day(11),
    endDate: _day(11),
    time: '13.00 - 15.00 WIB',
    venue: 'Lab IoT',
    description:
        'Arsitektur IoT, protokol MQTT, dan visualisasi data sensor secara real-time.',
    quota: 80,
    color: Colors.orange.shade800,
    posterAsset: 'assets/images/posters/05_iot_cerdas.jpg',
  ),
  EventItem(
    id: 'EVT-06',
    title: 'Workshop ESP32 dan MQTT',
    speaker: 'Satria Aditama, S.T.',
    category: EventCategory.iot,
    startDate: _day(18),
    endDate: _day(19),
    time: '08.30 - 16.00 WIB',
    venue: 'Lab IoT',
    description:
        'Merakit rangkaian ESP32, membaca sensor suhu, dan mengirim data ke broker MQTT.',
    quota: 30,
    color: Colors.deepOrange,
    posterAsset: 'assets/images/posters/06_esp32_mqtt.jpg',
    isWorkshop: true,
  ),
  EventItem(
    id: 'EVT-07',
    title: 'Ancaman Siber di Era Digital',
    speaker: 'Maya Anggraini, CEH',
    category: EventCategory.cybersecurity,
    startDate: _day(12),
    endDate: _day(12),
    time: '09.00 - 11.30 WIB',
    venue: 'Aula Utama',
    description:
        'Tren serangan phishing, ransomware, dan langkah praktis menjaga keamanan akun mahasiswa.',
    quota: 200,
    color: Colors.red.shade700,
    posterAsset: 'assets/images/posters/07_ancaman_siber.jpg',
  ),
  EventItem(
    id: 'EVT-08',
    title: 'Workshop Capture The Flag untuk Pemula',
    speaker: 'Rizky Ramadhan, OSCP',
    category: EventCategory.cybersecurity,
    startDate: _day(21),
    endDate: _day(21),
    time: '09.00 - 17.00 WIB',
    venue: 'Ruang Cyber Range',
    description:
        'Latihan CTF: web exploitation dasar, kriptografi sederhana, dan forensik berkas.',
    quota: 50,
    color: Colors.blueGrey.shade800,
    posterAsset: 'assets/images/posters/08_capture_the_flag.jpg',
    isWorkshop: true,
  ),
];
