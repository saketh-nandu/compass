import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../config/app_config.dart';

class TiltDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onUnlockTriggered;

  const TiltDetector({
    super.key,
    required this.child,
    required this.onUnlockTriggered,
  });

  @override
  State<TiltDetector> createState() => _TiltDetectorState();
}

class _TiltDetectorState extends State<TiltDetector> {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  // Track state
  bool _isConditionMet = false;
  DateTime? _conditionStartTime;

  // Cooldown
  bool _isInCooldown = false;

  // Latest gyro data to check for low motion
  double _gx = 0;
  double _gy = 0;
  double _gz = 0;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    try {
      _gyroSub = gyroscopeEventStream().listen((GyroscopeEvent event) {
        _gx = event.x;
        _gy = event.y;
        _gz = event.z;
      });

      _accelSub = accelerometerEventStream().listen((AccelerometerEvent event) {
        if (_isInCooldown) return;

        // Calculate pitch and roll
        // event.x, y, z are in m/s^2
        double x = event.x;
        double y = event.y;
        double z = event.z;

        // Using standard formulas
        double pitch = atan2(y, sqrt(x * x + z * z)) * 180 / pi;
        double roll = atan2(-x, z) * 180 / pi;

        // Compute tilt = sqrt(pitch^2 + roll^2)
        double tilt = sqrt(pitch * pitch + roll * roll);

        // Check conditions using app configuration
        bool isTiltCorrect = AppConfig.isTiltAngleValid(tilt);

        // Low motion check (gyro threshold)
        double gyroMagnitude = sqrt(_gx * _gx + _gy * _gy + _gz * _gz);
        bool isLowMotion = AppConfig.isLowMotion(gyroMagnitude);

        if (isTiltCorrect && isLowMotion) {
          if (!_isConditionMet) {
            _isConditionMet = true;
            _conditionStartTime = DateTime.now();
          } else {
            // Held for required duration?
            final holdDuration =
                DateTime.now().difference(_conditionStartTime!).inMilliseconds;
            if (holdDuration >= AppConfig.tiltHoldDuration.inMilliseconds) {
              _triggerUnlock();
            }
          }
        } else {
          _isConditionMet = false;
          _conditionStartTime = null;
        }
      });
    } catch (e) {
      debugPrint('Tilt detector sensor error: $e');
    }
  }

  void _triggerUnlock() {
    // Reset state
    _isConditionMet = false;
    _conditionStartTime = null;

    // Set cooldown using app configuration
    _isInCooldown = true;
    Future.delayed(AppConfig.unlockCooldown, () {
      if (mounted) {
        _isInCooldown = false;
      }
    });

    widget.onUnlockTriggered();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
