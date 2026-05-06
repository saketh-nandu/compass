import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:go_router/go_router.dart';

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
  double _userRotation = 0.0; // User's manual rotation
  bool _manualMode = false; // Manual mode activated by 5 taps
  int _tapCount = 0;
  DateTime? _lastTapTime;
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
        // Only update from compass if NOT in manual mode
        if (mounted && event.heading != null && !_manualMode) {
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

  void _onTap() {
    final now = DateTime.now();

    // Reset tap count if more than 1 second since last tap
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds > 1000) {
      _tapCount = 0;
    }

    _lastTapTime = now;
    _tapCount++;

    // Activate manual mode on 5 taps
    if (_tapCount >= 5) {
      setState(() {
        _manualMode = true;
        _tapCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Manual mode activated! Rotate freely to 127°'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onCompassDrag(DragUpdateDetails details) {
    if (!_manualMode) return;

    // Get the center of the compass
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final center = Offset(size.width / 2, size.height / 2);

    // Calculate angle from center to drag position
    final dx = details.globalPosition.dx - center.dx;
    final dy = details.globalPosition.dy - center.dy;
    final angle = atan2(dy, dx) * 180 / pi + 90; // +90 to align with compass

    final normalizedAngle = angle % 360;

    setState(() {
      _userRotation = normalizedAngle;
    });

    // Check if at unlock angle (127° ± 3°)
    _checkUnlockAngle(normalizedAngle);
  }

  void _checkUnlockAngle(double angle) {
    const targetAngle = 127.0;
    const tolerance = 3.0;

    final isAtTarget =
        (angle >= targetAngle - tolerance && angle <= targetAngle + tolerance);

    if (isAtTarget) {
      _unlockChat();
    }
  }

  void _unlockChat() {
    // Show success feedback
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Unlocked! Opening chat...'),
        duration: Duration(milliseconds: 300),
      ),
    );

    // Navigate to unlock screen immediately
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        context.push('/unlock');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayAngle = _manualMode ? _userRotation : _heading;
    final isNearUnlock =
        _manualMode && displayAngle >= 124 && displayAngle <= 130;

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
          if (_manualMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _manualMode = false;
                  _tapCount = 0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manual mode disabled'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: _onTap,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heading display
              Text(
                '${displayAngle.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: isNearUnlock
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),

              // Cardinal direction
              Text(
                _getCardinalDirection(displayAngle),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isNearUnlock
                          ? Theme.of(context).colorScheme.tertiary
                          : null,
                    ),
              ),

              // Mode indicator
              if (_manualMode) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isNearUnlock
                        ? Theme.of(context).colorScheme.tertiaryContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isNearUnlock
                        ? '🔓 UNLOCK ZONE! (127°)'
                        : '🎯 Manual Mode - Rotate to 127°',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isNearUnlock
                              ? Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Tap 5 times to activate manual mode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],

              // Accuracy indicator (only in auto mode)
              if (_hasPermissions && _accuracy > 0 && !_manualMode) ...[
                const SizedBox(height: 8),
                Text(
                  'Accuracy: ${_getAccuracyText(_accuracy)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getAccuracyColor(_accuracy),
                      ),
                ),
              ],

              const SizedBox(height: 64),

              // Compass dial with draggable pointer
              GestureDetector(
                onPanUpdate: _onCompassDrag,
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isNearUnlock
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withValues(alpha: 0.3),
                          width: isNearUnlock ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isNearUnlock
                                ? Theme.of(context)
                                    .colorScheme
                                    .tertiary
                                    .withValues(alpha: 0.2)
                                : Theme.of(context)
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

                          // Unlock zone indicator (127°)
                          Transform.rotate(
                            angle: 127 * pi / 180,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 6,
                                height: 25,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          // The actual needle (animated or user-controlled)
                          Transform.rotate(
                            angle: -(displayAngle) * pi / 180,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // North pointer (red)
                                Container(
                                  width: 8,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: isNearUnlock
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(context).colorScheme.error,
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
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center pin (draggable indicator)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                color: isNearUnlock
                                    ? Theme.of(context).colorScheme.tertiary
                                    : (_manualMode
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                width: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Instructions
              if (_manualMode) ...[
                Text(
                  'Drag to rotate • Reach 127° to unlock',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ] else if (_hasPermissions) ...[
                Text(
                  'Tap 5 times quickly to enable manual mode',
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
