import 'package:flutter/material.dart';

import '../data/sample_events.dart';
import '../models/event_item.dart';
import '../models/registration_ticket.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/poster_viewer.dart';
import '../widgets/venue_map_viewer.dart';
import 'event_registration_screen.dart';
import 'registered_tickets_screen.dart';

/// Layar utama dengan 3 tab: Seminar, Galeri & Denah, Tiket Terdaftar.
class HomeEventsScreen extends StatefulWidget {
  const HomeEventsScreen({super.key});

  @override
  State<HomeEventsScreen> createState() => _HomeEventsScreenState();
}

class _HomeEventsScreenState extends State<HomeEventsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  EventFilter _filter = const EventFilter();
  final List<RegistrationTicket> _tickets = [];
  int _galleryMode = 0; // 0 = poster, 1 = denah

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isRegistered(EventItem e) => _tickets.any((t) => t.event.id == e.id);

  List<EventItem> get _filteredEvents => sampleEvents.where((e) {
        if (_filter.category != null && e.category != _filter.category) {
          return false;
        }
        if (_filter.hideRegistered && _isRegistered(e)) return false;
        return true;
      }).toList();

  void _snack(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: action,
      ));
  }

  Future<void> _openFilter() async {
    final result = await showFilterBottomSheet(context, _filter);
    if (result != null) setState(() => _filter = result);
  }

  Future<void> _openRegistration(EventItem event) async {
    if (_isRegistered(event)) {
      _snack('Kamu sudah terdaftar pada acara ini.');
      return;
    }
    final ticket = await Navigator.of(context).push<RegistrationTicket>(
      MaterialPageRoute(builder: (_) => EventRegistrationScreen(event: event)),
    );
    if (ticket == null || !mounted) return;

    setState(() => _tickets.insert(0, ticket));
    _snack(
      'Pendaftaran berhasil! Tiket ${ticket.id} sudah aktif.',
      action: SnackBarAction(
        label: 'LIHAT',
        onPressed: () => _tabController.animateTo(2),
      ),
    );
  }

  Future<void> _openPoster(EventItem event) async {
    final selected = await PosterViewerScreen.open(
      context,
      event,
      registeredIds: _tickets.map((t) => t.event.id).toSet(),
    );
    if (selected != null && mounted) _openRegistration(selected);
  }

  void _cancelTicket(RegistrationTicket ticket) {
    setState(() => _tickets.removeWhere((t) => t.id == ticket.id));
    _snack('Tiket ${ticket.id} telah dibatalkan.');
  }

  void _showEventDetail(EventItem event) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _PosterBanner(
                  event: event,
                  onTap: () {
                    Navigator.pop(ctx);
                    _openPoster(event);
                  },
                ),
                const SizedBox(height: 16),
                Text(event.title,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${event.typeLabel} • ${event.category.label}'),
                const SizedBox(height: 12),
                Text(event.description),
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.person_outline, text: event.speaker),
                _DetailRow(icon: Icons.calendar_today, text: event.dateLabel),
                _DetailRow(icon: Icons.schedule, text: event.time),
                _DetailRow(icon: Icons.place_outlined, text: event.venue),
                _DetailRow(
                    icon: Icons.event_seat_outlined,
                    text: 'Kuota ${event.quota} peserta'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openRegistration(event);
                    },
                    icon: const Icon(Icons.how_to_reg),
                    label: Text(_isRegistered(event)
                        ? 'Sudah Terdaftar'
                        : 'Daftar Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _centered(Widget child) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: child,
        ),
      );

  // ---------- Tab 1: Seminar ----------
  Widget _buildSeminarTab() {
    final events = _filteredEvents;

    return _centered(
      Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: EventCategory.values.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = i == 0 ? null : EventCategory.values[i - 1];
                return ChoiceChip(
                  label: Text(cat?.label ?? 'Semua'),
                  selected: _filter.category == cat,
                  onSelected: (_) => setState(() => _filter = EventFilter(
                        category: cat,
                        hideRegistered: _filter.hideRegistered,
                      )),
                );
              },
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Tidak ada seminar yang sesuai filter.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          event: event,
                          isRegistered: _isRegistered(event),
                          onTap: () => _showEventDetail(event),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------- Tab 2: Galeri & Denah ----------
  Widget _buildGalleryTab() {
    return _centered(
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.grid_view),
                    label: Text('Poster'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.map_outlined),
                    label: Text('Denah'),
                  ),
                ],
                selected: {_galleryMode},
                onSelectionChanged: (s) =>
                    setState(() => _galleryMode = s.first),
              ),
            ),
          ),
          Expanded(
            child: _galleryMode == 0
                ? GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: sampleEvents.length,
                    itemBuilder: (context, index) {
                      final event = sampleEvents[index];
                      return _PosterTile(
                        event: event,
                        onTap: () => _openPoster(event),
                      );
                    },
                  )
                : const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: VenueMapViewer(),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NusaEvent Hub'),
        actions: [
          IconButton(
            tooltip: 'Filter',
            onPressed: _openFilter,
            icon: Badge(
              isLabelVisible: _filter.isActive,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            const Tab(
              icon: Icon(Icons.event_note),
              text: 'Seminar & Workshop',
            ),
            const Tab(
              icon: Icon(Icons.photo_library_outlined),
              text: 'Galeri & Denah Venue',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: _tickets.isNotEmpty,
                label: Text('${_tickets.length}'),
                child: const Icon(Icons.confirmation_number_outlined),
              ),
              text: 'Tiket Terdaftar',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSeminarTab(),
          _buildGalleryTab(),
          RegisteredTicketsScreen(
            tickets: _tickets,
            onCancel: _cancelTicket,
            onBrowse: () => _tabController.animateTo(0),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Banner poster pada detail acara (ketuk untuk melihat poster penuh).
class _PosterBanner extends StatelessWidget {
  const _PosterBanner({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(event: event, cacheWidth: 900),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.55, 1.0],
                  colors: [Color(0x00000000), Color(0xB3000000)],
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xCC000000),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.zoom_out_map, size: 14, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Lihat poster',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Poster seminar berupa gambar asli dengan overlay label, judul, dan tanggal.
class _PosterTile extends StatelessWidget {
  const _PosterTile({required this.event, required this.onTap});

  final EventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterImage(event: event, cacheWidth: 500),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.25, 0.55, 1.0],
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0xEE000000),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.typeLabel.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 11, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
