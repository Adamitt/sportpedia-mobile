/// Konfigurasi untuk API Base URL
/// 
/// Sesuaikan base URL sesuai dengan environment kamu:
/// - Chrome/Web: http://localhost:8000
/// - Android Emulator: http://10.0.2.2:8000
/// - iOS Simulator: http://localhost:8000
/// - Device Fisik: http://[IP_KOMPUTER_KAMU]:8000
///   Contoh: http://192.168.1.100:8000
import 'package:flutter/foundation.dart';

/// Konfigurasi untuk API Base URL
/// 
/// Otomatis menggunakan:
/// - Chrome/Web: http://localhost:8000
/// - Android Emulator: http://10.0.2.2:8000 (10.0.2.2 = alias untuk localhost dari emulator)
/// - iOS Simulator: http://localhost:8000
class ApiConfig {
  // Otomatis detect platform
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk Web (Chrome)
      return 'http://localhost:8000';
    } else {
      // Untuk Android Emulator (10.0.2.2 adalah alias untuk localhost dari emulator)
      // Untuk iOS Simulator, bisa pakai localhost atau IP komputer
      return 'http://10.0.2.2:8000';
    }
  }
}

