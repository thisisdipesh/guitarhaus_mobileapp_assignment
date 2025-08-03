import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'theme_service.dart';

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  // Brightness variables
  double _originalBrightness = 0.5;
  bool _isAutoBrightnessEnabled = false;
  bool _isDarkModeEnabled = false;

  // Accelerometer variables
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final List<double> _accelerometerReadings = [];
  static const int _shakeThreshold = 15;
  static const int _maxReadings = 10;

  // Shake detection callback
  Function? _onShakeDetected;

  // Dark mode callback
  Function? _onDarkModeChanged;

  // Initialize sensors
  Future<void> initialize() async {
    try {
      // Get current brightness
      _originalBrightness = await ScreenBrightness().current;
      print(
        'Sensor service initialized successfully. Original brightness: $_originalBrightness',
      );
    } catch (e) {
      print('Error initializing sensor service: $e');
    }
  }

  // Brightness adjustment methods
  Future<void> enableAutoBrightness() async {
    if (_isAutoBrightnessEnabled) return;

    _isAutoBrightnessEnabled = true;
    // For now, we'll use a simple brightness adjustment
    // In a real implementation, you'd need a light sensor package
    await _adjustBrightnessForEnvironment();
  }

  Future<void> disableAutoBrightness() async {
    if (!_isAutoBrightnessEnabled) return;

    _isAutoBrightnessEnabled = false;

    // Restore original brightness
    try {
      await ScreenBrightness().setScreenBrightness(_originalBrightness);
    } catch (e) {
      print('Error restoring brightness: $e');
    }
  }

  Future<void> _adjustBrightnessForEnvironment() async {
    if (!_isAutoBrightnessEnabled) return;

    try {
      // Get current time to estimate lighting conditions
      DateTime now = DateTime.now();
      int hour = now.hour;

      double newBrightness;

      // Adjust brightness based on time of day
      if (hour >= 6 && hour <= 18) {
        // Daytime - brighter
        newBrightness = 0.8;
      } else if (hour >= 19 && hour <= 22) {
        // Evening - medium
        newBrightness = 0.6;
      } else {
        // Night - dimmer
        newBrightness = 0.4;
      }

      print('Adjusting brightness to: $newBrightness (hour: $hour)');
      await ScreenBrightness().setScreenBrightness(newBrightness);
    } catch (e) {
      print('Error adjusting brightness: $e');
    }
  }

  // Manual brightness adjustment
  Future<void> setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  // Accelerometer methods
  void enableShakeDetection(Function onShakeDetected) {
    _onShakeDetected = onShakeDetected;
    _accelerometerSubscription = accelerometerEventStream().listen(
      _handleAccelerometerEvent,
    );
  }

  void disableShakeDetection() {
    _onShakeDetected = null;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _accelerometerReadings.clear();
  }

  void _handleAccelerometerEvent(AccelerometerEvent event) {
    // Calculate acceleration magnitude
    double acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Add to readings list
    _accelerometerReadings.add(acceleration);

    // Keep only recent readings
    if (_accelerometerReadings.length > _maxReadings) {
      _accelerometerReadings.removeAt(0);
    }

    // Check for shake pattern
    if (_detectShake()) {
      print('Shake detected! Acceleration: $acceleration');
      _onShakeDetected?.call();
      _accelerometerReadings.clear(); // Reset after shake detected
    }
  }

  bool _detectShake() {
    if (_accelerometerReadings.length < 3) return false;

    // Check if we have significant acceleration changes
    int shakeCount = 0;
    for (int i = 1; i < _accelerometerReadings.length; i++) {
      double difference =
          (_accelerometerReadings[i] - _accelerometerReadings[i - 1]).abs();
      if (difference > _shakeThreshold) {
        shakeCount++;
      }
    }

    // Require at least 2 significant changes for a shake
    return shakeCount >= 2;
  }

  // Dark mode detection methods
  void enableDarkModeDetection(Function onDarkModeChanged) {
    _onDarkModeChanged = onDarkModeChanged;
    _isDarkModeEnabled = true;
    _startDarkModeDetection();
  }

  void disableDarkModeDetection() {
    _onDarkModeChanged = null;
    _isDarkModeEnabled = false;
  }

  void _startDarkModeDetection() {
    // Check for dark mode every 30 seconds
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isDarkModeEnabled) {
        timer.cancel();
        return;
      }
      _checkDarkMode();
    });
  }

  void _checkDarkMode() {
    // Get current time to determine if it's dark mode time
    DateTime now = DateTime.now();
    int hour = now.hour;

    // Consider dark mode from 6 PM to 6 AM
    bool isDarkMode = hour >= 18 || hour < 6;

    // Call the callback with the dark mode status
    _onDarkModeChanged?.call(isDarkMode);

    // Automatically update theme service
    ThemeService().setDarkMode(isDarkMode);

    print('Dark mode check: $isDarkMode (hour: $hour)');
  }

  // Get current sensor status
  bool get isAutoBrightnessEnabled => _isAutoBrightnessEnabled;
  bool get isShakeDetectionEnabled => _accelerometerSubscription != null;
  bool get isDarkModeEnabled => _isDarkModeEnabled;

  // Dispose resources
  void dispose() {
    _accelerometerSubscription?.cancel();
    _accelerometerReadings.clear();
    disableDarkModeDetection();
  }
}
