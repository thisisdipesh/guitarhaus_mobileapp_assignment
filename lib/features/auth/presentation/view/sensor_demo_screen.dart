import 'package:flutter/material.dart';
import '../../../../core/services/sensor_service.dart';

class SensorDemoScreen extends StatefulWidget {
  const SensorDemoScreen({Key? key}) : super(key: key);

  @override
  State<SensorDemoScreen> createState() => _SensorDemoScreenState();
}

class _SensorDemoScreenState extends State<SensorDemoScreen> {
  final SensorService _sensorService = SensorService();
  bool _isAutoBrightnessEnabled = false;
  bool _isShakeDetectionEnabled = false;
  int _shakeCount = 0;
  double _currentBrightness = 0.5;
  String _lastShakeTime = '';

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
  }

  void _onShakeDetected() {
    setState(() {
      _shakeCount++;
      _lastShakeTime = DateTime.now().toString().substring(11, 19);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.screen_rotation, color: Colors.white),
            const SizedBox(width: 8),
            Text('Shake detected! Count: $_shakeCount'),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 1),
      ),
    );
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
        title: const Text('Sensor Demo'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.blue[100]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Shake Detection Demo
              _buildDemoCard(
                title: 'Shake Detection Demo',
                icon: Icons.screen_rotation,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Shake Detection'),
                      value: _isShakeDetectionEnabled,
                      onChanged: (value) {
                        if (value) {
                          _sensorService.enableShakeDetection(_onShakeDetected);
                        } else {
                          _sensorService.disableShakeDetection();
                        }
                        setState(() {
                          _isShakeDetectionEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Shake Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Total Shakes',
                                _shakeCount.toString(),
                              ),
                              _buildStatItem(
                                'Last Shake',
                                _lastShakeTime.isEmpty
                                    ? 'None'
                                    : _lastShakeTime,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        _onShakeDetected();
                      },
                      icon: const Icon(Icons.touch_app),
                      label: const Text('Test Shake Detection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '💡 Tip: Shake your phone or tap the test button to see the counter increase!',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Brightness Control Demo
              _buildDemoCard(
                title: 'Brightness Control Demo',
                icon: Icons.brightness_6,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Auto Brightness'),
                      subtitle: const Text('Adjusts based on time of day'),
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
                    if (!_isAutoBrightnessEnabled) ...[
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Auto brightness adjusts based on time:\n• Day (6 AM - 6 PM): 80%\n• Evening (7 PM - 10 PM): 60%\n• Night (11 PM - 5 AM): 40%',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Instructions
              _buildDemoCard(
                title: 'How to Test',
                icon: Icons.help_outline,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InstructionItem(
                      number: '1',
                      title: 'Shake Detection',
                      description:
                          'Enable shake detection and shake your phone to see the counter increase.',
                    ),
                    SizedBox(height: 12),
                    _InstructionItem(
                      number: '2',
                      title: 'Auto Brightness',
                      description:
                          'Enable auto brightness to see the screen adjust based on time of day.',
                    ),
                    SizedBox(height: 12),
                    _InstructionItem(
                      number: '3',
                      title: 'Manual Brightness',
                      description:
                          'Use the slider to manually control screen brightness when auto is disabled.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required String title,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _InstructionItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.yellow[700],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
