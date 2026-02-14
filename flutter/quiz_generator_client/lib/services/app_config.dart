import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;  // Tylko dla !kIsWeb

const bool showLogs = false;

class ApiConfig {
  static const int _port = 5284;

  static String get baseUrl {
    // Web zawsze localhost (Chrome ma dostęp do localhost hosta)
    if (kIsWeb) {
      return 'http://localhost:$_port';
    }
    
    // Mobile/Desktop - używamy Platform tylko poza web
    else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port';  // Android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:$_port';  // iOS simulator
    } else {
      // Windows, macOS, Linux (fizyczne urządzenie/emulator)
      return 'http://localhost:$_port';
    }
  }
}
