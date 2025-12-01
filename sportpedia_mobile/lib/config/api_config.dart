/// Konfigurasi untuk API Base URL
/// 
/// Sesuaikan base URL sesuai dengan environment kamu:
/// - Android Emulator: http://10.0.2.2:8000
/// - iOS Simulator: http://localhost:8000
/// - Device Fisik: http://[IP_KOMPUTER_KAMU]:8000
///   Contoh: http://192.168.1.100:8000
class ApiConfig {
  // TODO: Sesuaikan dengan URL Django server kamu
  static const String baseUrl = 'http://10.0.2.2:8000';
  
  // Untuk device fisik, uncomment dan ganti dengan IP komputer kamu:
  // static const String baseUrl = 'http://192.168.1.100:8000';
}

