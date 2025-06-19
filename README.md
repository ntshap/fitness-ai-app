# Fitness AI App 🏋️‍♂️🤖

An AI-powered Flutter fitness application that uses pose detection technology to help users track their workouts and improve their form in real-time.

## Features ✨

- **Real-time Pose Detection**: Uses TensorFlow Lite with MoveNet model for accurate pose estimation
- **Workout Tracking**: Monitor your exercise form and count repetitions automatically
- **Cross-platform**: Runs on Android, iOS, Web, Windows, macOS, and Linux
- **Modern UI**: Clean and intuitive interface with custom styling
- **Camera Integration**: Real-time camera feed processing for pose analysis

## Technologies Used 🛠️

- **Flutter**: Cross-platform mobile development framework
- **TensorFlow Lite**: On-device machine learning for pose detection
- **MoveNet**: Google's pose estimation model
- **Camera Plugin**: Real-time camera access and image processing
- **FL Chart**: Beautiful charts and data visualization
- **Google Fonts**: Custom typography

## Getting Started 🚀

### Prerequisites

- Flutter SDK (>=3.2.3)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development on macOS)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/fitness-ai-app.git
   cd fitness-ai-app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── main.dart              # App entry point
├── app.dart              # Main app configuration
├── config/               # App configuration
│   ├── app_colors.dart   # Color scheme
│   └── app_text_styles.dart # Typography
├── screens/              # UI screens
├── services/             # Business logic
│   └── pose_detector_service.dart # AI pose detection
└── widgets/              # Reusable UI components

assets/
├── images/               # Image assets
└── movenet.tflite       # TensorFlow Lite model
```

## Key Components 🔧

### Pose Detection Service
The app uses TensorFlow Lite with the MoveNet model to detect human poses in real-time. The service processes camera frames and returns keypoint coordinates for 17 body joints.

### Supported Platforms
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- Google's MoveNet model for pose detection
- Flutter team for the amazing framework
- TensorFlow Lite team for on-device ML capabilities

## Contact 📧

Natasha - natasharondonuwu@gmail.com

Project Link: [https://github.com/yourusername/fitness-ai-app](https://github.com/yourusername/fitness-ai-app)
