import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sample_events.dart';
import '../models/event_item.dart';

/// Gambar poster dari aset dengan placeholder warna acara, efek fade-in,
/// dan fallback ikon bila file gambar tidak ditemukan.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.event,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    this.cacheWidth,
  });

  final EventItem event;
  final BoxFit fit;
  final Alignment alignment;

  /// Lebar decode (piksel). Isi untuk thumbnail agar hemat memori.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: event.color,
      child: Image.asset(
        event.posterAsset,
        fit: fit,
        alignment: alignment,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        width: double.infinity,
        height: double.infinity,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(event.category.icon, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}

/// Layar penuh untuk melihat poster: geser kiri/kanan untuk ganti poster,
/// cubit atau klik dua kali untuk zoom. Mengembalikan [EventItem] bila
/// pengguna menekan tombol "Daftar".
class PosterViewerScreen extends StatefulWidget {
  const PosterViewerScreen({
    super.key,
    required this.events,
    required this.initialIndex,
    this.registeredIds = const <String>{},
  });

  final List<EventItem> events;
  final int initialIndex;
  final Set<String> registeredIds;

  static Future<EventItem?> open(
    BuildContext context,
    EventItem event, {
    List<EventItem>? events,
    Set<String> registeredIds = const <String>{},
  }) {
    final list = events ?? sampleEvents;
    final index = list.indexWhere((e) => e.id == event.id);
    return Navigator.of(context).push<EventItem>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PosterViewerScreen(
          events: list,
          initialIndex: index < 0 ? 0 : index,
          registeredIds: registeredIds,
        ),
      ),
    );
  }

  @override
  State<PosterViewerScreen> createState() => _PosterViewerScreenState();
}

class _PosterViewerScreenState extends State<PosterViewerScreen> {
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;
  bool _zoomed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final target = _index + delta;
    if (target < 0 || target >= widget.events.length) return;
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.events[_index];
    final isWide = MediaQuery.sizeOf(context).width >= 700;
    final registered = widget.registeredIds.contains(event.id);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFF0B0B12),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0B0B12),
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('Poster Acara'),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${_index + 1} / ${widget.events.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: _zoomed
                          ? const NeverScrollableScrollPhysics()
                          : const PageScrollPhysics(),
                      itemCount: widget.events.length,
                      onPageChanged: (i) => setState(() {
                        _index = i;
                        _zoomed = false;
                      }),
                      itemBuilder: (context, i) => _ZoomablePoster(
                        key: ValueKey(widget.events[i].id),
                        event: widget.events[i],
                        onZoomChanged: (z) {
                          if (z != _zoomed) setState(() => _zoomed = z);
                        },
                      ),
                    ),
                    if (isWide && _index > 0)
                      Positioned(
                        left: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _NavButton(
                            icon: Icons.chevron_left,
                            tooltip: 'Poster sebelumnya',
                            onPressed: () => _go(-1),
                          ),
                        ),
                      ),
                    if (isWide && _index < widget.events.length - 1)
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _NavButton(
                            icon: Icons.chevron_right,
                            tooltip: 'Poster berikutnya',
                            onPressed: () => _go(1),
                          ),
                        ),
                      ),
                    if (!_zoomed)
                      const Positioned(
                        left: 0,
                        right: 0,
                        bottom: 10,
                        child: IgnorePointer(child: Center(child: _ZoomHint())),
                      ),
                  ],
                ),
              ),
              Material(
                color: const Color(0xFF14141F),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${event.typeLabel} • ${event.dateLabel} • ${event.venue}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: registered
                              ? null
                              : () => Navigator.pop(context, event),
                          icon: Icon(
                            registered ? Icons.check_circle : Icons.how_to_reg,
                            size: 18,
                          ),
                          label: Text(registered ? 'Terdaftar' : 'Daftar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}

class _ZoomHint extends StatelessWidget {
  const _ZoomHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x99000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.zoom_in, size: 16, color: Colors.white70),
          SizedBox(width: 6),
          Text(
            'Cubit / klik dua kali untuk zoom',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Satu halaman poster yang dapat di-zoom (InteractiveViewer).
class _ZoomablePoster extends StatefulWidget {
  const _ZoomablePoster({
    super.key,
    required this.event,
    required this.onZoomChanged,
  });

  final EventItem event;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomablePoster> createState() => _ZoomablePosterState();
}

class _ZoomablePosterState extends State<_ZoomablePoster> {
  final TransformationController _controller = TransformationController();
  Offset _tapPosition = Offset.zero;
  bool _zoomed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed = _controller.value.getMaxScaleOnAxis() > 1.02;
    if (zoomed != _zoomed) {
      _zoomed = zoomed;
      widget.onZoomChanged(zoomed);
    }
  }

  void _toggleZoom() {
    if (_zoomed) {
      _controller.value = Matrix4.identity();
    } else {
      const s = 2.5;
      final p = _tapPosition;
      // Skala s, dengan titik ketukan tetap berada di tempatnya.
      _controller.value = Matrix4(
        s, 0, 0, 0, //
        0, s, 0, 0, //
        0, 0, 1, 0, //
        -p.dx * (s - 1), -p.dy * (s - 1), 0, 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _tapPosition = d.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 5,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            widget.event.posterAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image_outlined,
                  color: Colors.white54, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
