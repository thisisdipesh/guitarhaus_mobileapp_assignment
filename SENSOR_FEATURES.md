# 🎸 GuitarHaus Sensor Features

This document describes the sensor features implemented in the GuitarHaus mobile app.

## 📱 Implemented Sensors

### 1. **Auto Brightness Control** 🌟
- **Feature**: Automatically adjusts screen brightness based on time of day
- **Implementation**: Uses `screen_brightness` package
- **Brightness Levels**:
  - **Daytime** (6 AM - 6 PM): 80% brightness
  - **Evening** (7 PM - 10 PM): 60% brightness  
  - **Night** (11 PM - 5 AM): 40% brightness
- **Manual Control**: Slider for manual brightness adjustment when auto is disabled

### 2. **Shake to Refresh** 📳
- **Feature**: Shake your phone to refresh content
- **Implementation**: Uses `sensors_plus` package with accelerometer
- **Usage**: 
  - Works on home screen and product listings
  - Requires moderate shake motion
  - Shows snackbar notification when shake is detected
- **Benefits**: Saves battery by avoiding manual refresh buttons

## 🛠️ Technical Implementation

### Dependencies Added
```yaml
dependencies:
  sensors_plus: ^4.0.2
  screen_brightness: ^0.2.2+1
```

### Core Service
- **File**: `lib/core/services/sensor_service.dart`
- **Features**:
  - Singleton pattern for global access
  - Automatic resource management
  - Error handling for sensor failures
  - Configurable shake detection sensitivity

### UI Components
1. **Sensor Settings Screen** (`lib/features/auth/presentation/view/sensor_settings_screen.dart`)
   - Toggle switches for enabling/disabling features
   - Manual brightness slider
   - Information about how features work
   - Demo button to test sensors

2. **Sensor Demo Screen** (`lib/features/auth/presentation/view/sensor_demo_screen.dart`)
   - Interactive demo of shake detection
   - Real-time shake counter
   - Brightness control testing
   - Step-by-step instructions

3. **Home Page Integration** (`lib/features/home/view/HomePage.dart`)
   - Automatic shake detection enabled
   - Shows refresh notification when shaken
   - Ready for content refresh implementation

## 🎯 How to Use

### Accessing Sensor Settings
1. Open the GuitarHaus app
2. Navigate to **Profile** tab
3. Tap **"Sensor Settings"** button
4. Configure your preferred sensor features

### Testing Sensors
1. In Sensor Settings, tap **"Try Sensor Demo"**
2. Enable shake detection and shake your phone
3. Watch the shake counter increase
4. Test auto brightness by enabling it
5. Use manual brightness slider when auto is disabled

### Shake to Refresh
- **On Home Screen**: Shake your phone to refresh content
- **Sensitivity**: Moderate shake motion required
- **Feedback**: Green snackbar notification appears
- **Future**: Can be extended to refresh product listings, orders, etc.

## 🔧 Configuration

### Shake Detection Sensitivity
```dart
static const int _shakeThreshold = 15;  // Adjust for sensitivity
static const int _maxReadings = 10;     // Number of readings to analyze
```

### Brightness Levels
```dart
// Daytime (6 AM - 6 PM): 80% brightness
// Evening (7 PM - 10 PM): 60% brightness  
// Night (11 PM - 5 AM): 40% brightness
```

## 🚀 Future Enhancements

### Potential Sensor Additions
1. **Microphone Sensor**: Guitar tuning assistance
2. **GPS**: Store locator and local deals
3. **Camera**: Visual search for guitars
4. **NFC**: Quick product information
5. **Bluetooth**: Smart guitar connectivity

### Advanced Features
1. **Gesture Recognition**: Swipe gestures for navigation
2. **Proximity Sensor**: Auto-pause when phone is near face
3. **Light Sensor**: Real-time ambient light detection
4. **Heart Rate Monitor**: Performance anxiety tracking

## 📋 Requirements

### Android Permissions
```xml
<!-- Already included in AndroidManifest.xml -->
<uses-permission android:name="android.permission.WRITE_SETTINGS" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

### iOS Permissions
- No additional permissions required for basic sensor features
- Screen brightness control works automatically

## 🐛 Troubleshooting

### Common Issues
1. **Shake not detected**: Try shaking more vigorously
2. **Brightness not changing**: Check if auto brightness is enabled
3. **App crashes**: Ensure sensors_plus package is properly installed

### Debug Information
- Sensor service includes error logging
- Check console for sensor initialization messages
- Verify permissions are granted on Android

## 📱 User Experience

### Benefits
- **Battery Saving**: Auto brightness reduces power consumption
- **Convenience**: Shake to refresh eliminates manual tapping
- **Accessibility**: Adaptive brightness improves readability
- **Modern Feel**: Sensor features make the app feel more interactive

### User Feedback
- Intuitive controls with toggle switches
- Clear visual feedback for shake detection
- Informative settings screen with explanations
- Demo mode for testing features

---

**Note**: These sensor features enhance the GuitarHaus app by making it more interactive and user-friendly while maintaining the guitar-themed aesthetic and functionality. 