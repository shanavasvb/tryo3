# Tryo3 - Smart Environmental Monitoring App

A modern Flutter application for monitoring and analyzing environmental sensor data in real-time. Track temperature, humidity, CO2 levels, and more across multiple sensor clusters with beautiful visualizations and intelligent insights.

![Flutter](https://img.shields.io/badge/Flutter-3.10.3-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.3-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Features

### Core Functionality
- **Real-time Monitoring**: Track environmental metrics across multiple sensor clusters
- **Interactive Dashboard**: View live sensor data with color-coded status indicators
- **Historical Analysis**: Visualize trends with interactive charts and graphs
- **Environmental Score**: Get an overall environmental quality score (0-100)
- **Detailed Insights**: Deep dive into individual sensor metrics with comprehensive analysis

### Sensor Metrics
- 🌡️ **Temperature** - Monitor ambient temperature levels
- 💧 **Humidity** - Track moisture levels in the air
- 🌬️ **CO2** - Carbon dioxide concentration monitoring
- ☠️ **Carbon Monoxide** - Detect dangerous CO levels
- 💡 **Light/Luminosity** - Measure illumination levels
- 🔊 **Noise** - Monitor sound levels in decibels

### User Experience
- **Theme Support**: Light, Dark, and System theme modes
- **Responsive Design**: Optimized for various screen sizes
- **Smooth Animations**: Fluid transitions and interactive elements
- **Navigation Drawer**: Easy access to all app sections
- **Bottom Navigation**: Quick switching between Dashboard, History, and Settings

### Screens
1. **Landing Screen**: Welcome page with app introduction
2. **Dashboard**: Real-time sensor data and cluster overview
3. **History**: Historical data visualization with charts and daily summaries
4. **Sensor Detail**: In-depth view of individual sensor metrics with dynamic graphs
5. **Settings**: Theme customization, notifications, and account management

## 🎨 Design

The app features a modern, clean design with:
- **Typography**: Manrope font family for excellent readability
- **Color Scheme**: 
  - Primary: `#2D5F4D` (Forest Green)
  - Light Background: `#F5F5F5`
  - Dark Background: `#060E10`
- **Components**: Custom cards, charts, and interactive widgets
- **Animations**: Smooth transitions and micro-interactions

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** 3.10.3 - UI framework
- **Dart** 3.10.3 - Programming language

### State Management
- **flutter_riverpod** 2.6.1 - Reactive state management

### UI & Design
- **google_fonts** 6.2.1 - Custom typography (Manrope)
- **Material Design 3** - Modern UI components

### Data Visualization
- **fl_chart** 0.69.0 - Beautiful, interactive charts

### Architecture
- **Provider Pattern** - Clean separation of business logic
- **Repository Pattern** - Data layer abstraction
- **Widget Composition** - Reusable, modular components

## 📦 Installation

### Prerequisites
- Flutter SDK 3.10.3 or higher
- Dart SDK 3.10.3 or higher
- Android Studio / VS Code with Flutter extensions
- iOS development tools (for iOS builds)

### Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd tryo3_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# For development
flutter run

# For specific platform
flutter run -d chrome      # Web
flutter run -d macos       # macOS
flutter run -d linux       # Linux
flutter run -d windows     # Windows
```

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point
├── providers/                     # Riverpod providers
│   ├── dashboard_providers.dart   # Dashboard state management
│   ├── history_providers.dart     # History data providers
│   └── theme_provider.dart        # Theme management
├── screens/                       # App screens
│   ├── landing_screen.dart        # Welcome/intro screen
│   ├── dashboard_screen.dart      # Main dashboard
│   ├── history_screen.dart        # Historical data view
│   ├── sensor_detail_screen.dart  # Detailed sensor view
│   └── settings_screen.dart       # App settings
├── services/                      # Business logic
│   └── placeholder_data_service.dart  # Mock data service
├── themes/                        # Theme configuration
│   └── theme.dart                 # Light/Dark themes
└── widgets/                       # Reusable widgets
    ├── common/                    # Shared widgets
    ├── dashboard/                 # Dashboard-specific widgets
    │   ├── aqi_wave_chart.dart
    │   ├── cluster_selector.dart
    │   ├── metric_card.dart
    │   └── sensor_cluster_card.dart
    ├── app_bottom_nav_bar.dart    # Bottom navigation
    ├── app_drawer.dart            # Navigation drawer
    └── app_menu_button.dart       # Menu button widget
```

## 🚀 Running the App

### Development Mode
```bash
flutter run
```

### Production Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build macos --release
flutter build linux --release
flutter build windows --release
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📊 Key Features Explained

### Dashboard
- **Cluster Selector**: Switch between different sensor locations
- **Metric Cards**: Real-time data with color-coded status
  - Green: Optimal
  - Orange: Elevated
  - Red: Critical
- **AQI Wave Chart**: Visual representation of air quality index

### History
- **Environmental Score**: Overall quality rating
- **Trend Charts**: 7-day historical data visualization
- **Daily Summaries**: Detailed breakdown by day
- **Time Range Selector**: View data for different periods

### Sensor Detail
- **Dynamic Charts**: Interactive graphs that update based on time range
- **Status Indicators**: Clear visual feedback on current conditions
- **Expandable Sections**: 
  - "What does this mean?" - Explanation of current readings
  - "About this Sensor" - Detailed sensor information
- **Device Info**: Location, status, and last sync time

### Settings
- **Theme Management**: Choose Light, Dark, or System theme
- **Notifications**: Toggle notification preferences
- **Account**: Profile and password management
- **About**: App information and privacy policy

## 🎯 Future Enhancements

- [ ] Real sensor integration (Currently using mock data)
- [ ] User authentication and profiles
- [ ] Push notifications for critical alerts
- [ ] Export data to CSV/PDF
- [ ] Multi-language support
- [ ] Widget customization
- [ ] Historical data comparison
- [ ] Sensor calibration tools
- [ ] Help & Support section



## 📝 Code Style

This project follows the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints` for code analysis.

```bash
# Run the analyzer
flutter analyze

# Format code
flutter format .
```


**Note**: This application currently uses placeholder data for demonstration purposes. Integration with actual sensor hardware is planned for future releases.
