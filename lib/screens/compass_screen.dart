import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with TickerProviderStateMixin {
  double _heading = 0.0;
  double _accuracy = 0.0;
  bool _hasPermissions = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _initializeCompass();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _initializeCompass() {
    // Initialize compass with error handling for web/emulators
    try {
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted && event.heading != null) {
          final newHeading = event.heading!;

          // Smooth rotation animation
          _rotationAnimation = Tween<double>(
            begin: _heading,
            end: newHeading,
          ).animate(CurvedAnimation(
            parent: _rotationController,
            curve: Curves.easeInOut,
          ));

          setState(() {
            _heading = newHeading;
            _accuracy = event.accuracy ?? 0.0;
            _hasPermissions = true;
          });

          _rotationController.forward(from: 0);
        }
      });
    } catch (e) {
      debugPrint('Compass initialization failed: $e');
      setState(() {
        _hasPermissions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        centerTitle: true,
        actions: [
          if (!_hasPermissions)
            IconButton(
              icon: const Icon(Icons.warning_amber),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Compass requires device sensors. Not available on web/emulator.'),
                  ),
                );
              },
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading display
            Text(
              '${_heading.toStringAsFixed(1)}°',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),

            // Cardinal direction
            Text(
              _getCardinalDirection(_heading),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // Accuracy indicator
            if (_hasPermissions && _accuracy > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Accuracy: ${_getAccuracyText(_accuracy)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getAccuracyColor(_accuracy),
                    ),
              ),
            ],

            const SizedBox(height: 64),

            // Compass dial
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .shadow
                            .withValues(alpha: 0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer compass dial with cardinal points
                      ...List.generate(12, (index) {
                        final isCardinal = index % 3 == 0;
                        return Transform.rotate(
                          angle: (index * 30) * pi / 180,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: isCardinal ? 4 : 2,
                              height: isCardinal ? 16 : 8,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        );
                      }),

                      // N, E, S, W labels
                      _buildCardinalLabel('N', 0, context),
                      _buildCardinalLabel('E', 90, context),
                      _buildCardinalLabel('S', 180, context),
                      _buildCardinalLabel('W', 270, context),

                      // The actual needle (animated)
                      Transform.rotate(
                        angle: -(_hasPermissions
                                ? _rotationAnimation.value
                                : _heading) *
                            pi /
                            180,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // North pointer (red)
                            Container(
                              width: 8,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                            // South pointer (white/secondary)
                            Container(
                              width: 8,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Center pin
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Calibration hint
            if (_hasPermissions) ...[
              Text(
                'Hold device flat and move in figure-8 pattern to calibrate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'Compass not available on this device',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardinalLabel(String label, double angle, BuildContext context) {
    return Transform.rotate(
      angle: angle * pi / 180,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: Transform.rotate(
            angle: -angle * pi / 180,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight:
                        label == 'N' ? FontWeight.bold : FontWeight.normal,
                    color: label == 'N'
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = (((heading + 22.5) % 360) / 45).floor();
    return directions[index];
  }

  String _getAccuracyText(double accuracy) {
    if (accuracy < 15) return 'High';
    if (accuracy < 30) return 'Medium';
    return 'Low';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 15) return Colors.green;
    if (accuracy < 30) return Colors.orange;
    return Colors.red;
  }
}
