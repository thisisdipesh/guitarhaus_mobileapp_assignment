import 'package:flutter/material.dart';
import '../../../../core/services/sensor_service.dart';

class SensorSettingsScreen extends StatefulWidget {
  const SensorSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SensorSettingsScreen> createState() => _SensorSettingsScreenState();
}

class _SensorSettingsScreenState extends State<SensorSettingsScreen> {
  final SensorService _sensorService = SensorService();
  bool _isAutoBrightnessEnabled = false;
  bool _isShakeDetectionEnabled = false;
  double _currentBrightness = 0.5;

  @override
  void initState() {
    super.initState();
    _initializeSensors();
  }

  Future<void> _initializeSensors() async {
    await _sensorService.initialize();
    setState(() {
      _isAutoBrightnessEnabled = _sensorService.isAutoBrightnessEnabled;
      _isShakeDetectionEnabled = _sensorService.isShakeDetectionEnabled;
    });

    // Initialize shake detection if it was previously enabled
    if (_isShakeDetectionEnabled) {
      _sensorService.enableShakeDetection(() {
        _showShakeDetectedSnackBar();
      });
    }
  }

  @override
  void dispose() {
    _sensorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Settings'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto Brightness Section
            _buildSectionCard(
              title: 'Auto Brightness',
              subtitle:
                  'Automatically adjust screen brightness based on time of day',
              icon: Icons.brightness_auto,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Auto Brightness'),
                    subtitle: const Text('Adjust brightness automatically'),
                    value: _isAutoBrightnessEnabled,
                    onChanged: (value) async {
                      if (value) {
                        await _sensorService.enableAutoBrightness();
                      } else {
                        await _sensorService.disableAutoBrightness();
                      }
                      setState(() {
                        _isAutoBrightnessEnabled = value;
                      });
                    },
                  ),
                  if (_isAutoBrightnessEnabled) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.brightness_auto,
                            color: Colors.blue[700],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Auto brightness active',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    const Text('Manual Brightness Control'),
                    Slider(
                      value: _currentBrightness,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_currentBrightness * 100).round()}%',
                      onChanged: (value) async {
                        setState(() {
                          _currentBrightness = value;
                        });
                        await _sensorService.setBrightness(value);
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Shake Detection Section
            _buildSectionCard(
              title: 'Shake to Refresh',
              subtitle: 'Shake your phone to refresh content in the app',
              icon: Icons.screen_rotation,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Enable Shake Detection'),
                    subtitle: const Text('Shake phone to refresh'),
                    value: _isShakeDetectionEnabled,
                    onChanged: (value) {
                      if (value) {
                        _sensorService.enableShakeDetection(() {
                          _showShakeDetectedSnackBar();
                        });
                      } else {
                        _sensorService.disableShakeDetection();
                      }
                      setState(() {
                        _isShakeDetectionEnabled = value;
                      });
                    },
                  ),
                  if (_isShakeDetectionEnabled) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Active - Try shaking your phone!',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Information Section
            _buildSectionCard(
              title: 'How it Works',
              subtitle: 'Learn about the sensor features',
              icon: Icons.info,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoItem(
                    icon: Icons.brightness_auto,
                    title: 'Auto Brightness',
                    description:
                        'Adjusts screen brightness based on time of day:\n• Daytime (6 AM - 6 PM): 80% brightness\n• Evening (7 PM - 10 PM): 60% brightness\n• Night (11 PM - 5 AM): 40% brightness',
                  ),
                  SizedBox(height: 16),
                  _InfoItem(
                    icon: Icons.screen_rotation,
                    title: 'Shake to Refresh',
                    description:
                        'Shake your phone to refresh content:\n• Works on home screen, product listings\n• Requires moderate shake motion\n• Helps save battery by avoiding manual refresh',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Demo Button
            Container(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.green[600]!.withOpacity(0.3),
                ),
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  "Try Sensor Demo",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/sensor-demo');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.yellow[700], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  void _showShakeDetectedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Shake detected! Refreshing content...'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.yellow[700], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
