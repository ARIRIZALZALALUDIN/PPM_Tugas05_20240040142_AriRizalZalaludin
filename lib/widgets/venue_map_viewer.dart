import 'package:flutter/material.dart';

/// Denah venue yang dapat digeser dan diperbesar (InteractiveViewer).
class VenueMapViewer extends StatefulWidget {
  const VenueMapViewer({super.key});

  @override
  State<VenueMapViewer> createState() => _VenueMapViewerState();
}

class _VenueMapViewerState extends State<VenueMapViewer> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cubit untuk memperbesar, geser untuk berpindah area.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: InteractiveViewer(
                      transformationController: _controller,
                      minScale: 0.8,
                      maxScale: 5,
                      boundaryMargin: const EdgeInsets.all(48),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: AspectRatio(
                            aspectRatio: 1.25,
                            child: _MapCanvas(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: FloatingActionButton.small(
                  heroTag: null,
                  tooltip: 'Reset zoom',
                  onPressed: () => _controller.value = Matrix4.identity(),
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Room {
  const _Room(this.label, this.icon, this.color, this.x, this.y, this.w, this.h);

  final String label;
  final IconData icon;
  final Color color;
  final double x, y, w, h; // pecahan dari lebar/tinggi denah (0..1)
}

final List<_Room> _rooms = [
  _Room('Aula Utama', Icons.groups, Colors.indigo.shade100, 0.03, 0.03, 0.55, 0.40),
  _Room('Lab AI', Icons.psychology, Colors.purple.shade100, 0.61, 0.03, 0.36, 0.19),
  _Room('Lab IoT', Icons.sensors, Colors.orange.shade100, 0.61, 0.24, 0.36, 0.19),
  _Room('Ruang Workshop Mobile', Icons.phone_android, Colors.teal.shade100, 0.03, 0.47, 0.30, 0.28),
  _Room('Ruang Cyber Range', Icons.security, Colors.red.shade100, 0.35, 0.47, 0.30, 0.28),
  _Room('Area Registrasi', Icons.how_to_reg, Colors.amber.shade100, 0.67, 0.47, 0.30, 0.28),
  _Room('Food Court', Icons.restaurant, Colors.lime.shade100, 0.03, 0.78, 0.30, 0.19),
  _Room('Pintu Masuk', Icons.door_front_door, Colors.green.shade200, 0.35, 0.78, 0.30, 0.19),
  _Room('Toilet & Musala', Icons.wc, Colors.blueGrey.shade100, 0.67, 0.78, 0.30, 0.19),
];

class _MapCanvas extends StatelessWidget {
  const _MapCanvas();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black26),
          ),
          child: Stack(
            children: [
              for (final r in _rooms)
                Positioned(
                  left: w * r.x,
                  top: h * r.y,
                  width: w * r.w,
                  height: h * r.h,
                  child: _RoomTile(room: r),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room});

  final _Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: room.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black38),
      ),
      padding: const EdgeInsets.all(4),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(room.icon, size: 22, color: Colors.black87),
            const SizedBox(height: 2),
            Text(
              room.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
