import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/event_item.dart';
import '../models/registration_ticket.dart';

/// Formulir pendaftaran. Mengembalikan [RegistrationTicket] lewat Navigator.pop.
class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key, required this.event});

  final EventItem event;

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _waCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  ParticipantType _type = ParticipantType.mahasiswa;
  KitPackage _kit = KitPackage.none;
  DateTime? _date;
  double _donation = 0;
  bool _agree = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _waCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  // ---------- Validator ----------
  String? _validateName(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Nama wajib diisi';
    if (value.length < 3) return 'Nama minimal 3 karakter';
    if (!RegExp(r"^[A-Za-z .,'-]+$").hasMatch(value)) {
      return 'Nama hanya boleh berisi huruf';
    }
    return null;
  }

  String? _validateNim(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'NIM wajib diisi';
    if (value.length < 8 || value.length > 12) return 'NIM harus 8-12 digit angka';
    return null;
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email wajib diisi';
    if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validateWhatsapp(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Nomor WhatsApp wajib diisi';
    if (!RegExp(r'^(\+62|62|0)8[0-9]{8,12}$').hasMatch(value)) {
      return 'Gunakan format 08xxxxxxxxxx atau +62xxxxxxxxxxx';
    }
    return null;
  }

  // ---------- Aksi ----------
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? widget.event.startDate,
      firstDate: widget.event.startDate,
      lastDate: widget.event.endDate,
      helpText: 'Pilih tanggal kehadiran',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateCtrl.text = formatDate(picked);
      });
    }
  }

  void _showRules() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tata Tertib Peserta'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Hadir 15 menit sebelum acara dimulai.\n'
            '2. Membawa tiket dan kartu identitas.\n'
            '3. Menjaga ketertiban selama acara.\n'
            '4. Tidak merekam materi tanpa izin pembicara.\n'
            '5. Pembatalan dilakukan melalui menu Tiket Terdaftar.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali data yang belum valid.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulasi proses server
    if (!mounted) return;

    final ticket = RegistrationTicket(
      id: 'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      event: widget.event,
      name: _nameCtrl.text.trim(),
      nim: _nimCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      whatsapp: _waCtrl.text.trim(),
      participantType: _type,
      attendanceDate: _date!,
      kit: _kit,
      donation: _donation.round(),
      createdAt: DateTime.now(),
    );
    Navigator.of(context).pop(ticket);
  }

  String _kitLabel(KitPackage k) {
    final price = k.price == 0 ? 'Gratis' : formatRupiah(k.price);
    return '${k.label} ($price)';
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.event;
    final total = _kit.price + _donation.round();

    return PopScope(
      canPop: !_loading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pendaftaran Tiket'),
          bottom: _loading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(4),
                  child: LinearProgressIndicator(),
                )
              : null,
        ),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: EdgeInsets.zero,
                        color: theme.colorScheme.primaryContainer,
                        child: ListTile(
                          leading: Icon(event.category.icon),
                          title: Text(event.title,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${event.dateLabel} • ${event.venue}'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameCtrl,
                        enabled: !_loading,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Nama lengkap',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateName,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nimCtrl,
                        enabled: !_loading,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'NIM',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateNim,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: !_loading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _waCtrl,
                        enabled: !_loading,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nomor WhatsApp',
                          hintText: '081234567890',
                          prefixIcon: Icon(Icons.chat_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateWhatsapp,
                      ),
                      const SizedBox(height: 20),
                      Text('Tipe peserta', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in ParticipantType.values)
                            ChoiceChip(
                              label: Text(p.label),
                              selected: _type == p,
                              onSelected: _loading
                                  ? null
                                  : (_) => setState(() => _type = p),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _dateCtrl,
                        readOnly: true,
                        enabled: !_loading,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal kehadiran',
                          prefixIcon: Icon(Icons.event),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Pilih tanggal kehadiran'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownMenu<KitPackage>(
                        expandedInsets: EdgeInsets.zero,
                        enabled: !_loading,
                        initialSelection: _kit,
                        label: const Text('Paket seminar kit'),
                        leadingIcon: const Icon(Icons.inventory_2_outlined),
                        dropdownMenuEntries: [
                          for (final k in KitPackage.values)
                            DropdownMenuEntry<KitPackage>(
                              value: k,
                              label: _kitLabel(k),
                            ),
                        ],
                        onSelected: (k) {
                          if (k != null) setState(() => _kit = k);
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Donasi sukarela: ${formatRupiah(_donation.round())}',
                          style: theme.textTheme.titleSmall),
                      Slider(
                        value: _donation,
                        min: 0,
                        max: 200000,
                        divisions: 8,
                        label: formatRupiah(_donation.round()),
                        onChanged: _loading
                            ? null
                            : (v) => setState(() => _donation = v),
                      ),
                      FormField<bool>(
                        initialValue: _agree,
                        validator: (v) => (v ?? false)
                            ? null
                            : 'Kamu harus menyetujui tata tertib',
                        builder: (state) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              value: state.value ?? false,
                              onChanged: _loading
                                  ? null
                                  : (v) {
                                      state.didChange(v);
                                      setState(() => _agree = v ?? false);
                                    },
                              title: const Text(
                                  'Saya menyetujui tata tertib peserta'),
                              subtitle: GestureDetector(
                                onTap: _showRules,
                                child: Text(
                                  'Baca tata tertib',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Text(
                                  state.errorText!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Expanded(child: Text('Total pembayaran')),
                              Text(
                                formatRupiah(total),
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: _loading
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Memproses...'),
                                ],
                              )
                            : const Text('Daftar Sekarang'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
