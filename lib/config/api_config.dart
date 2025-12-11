/// Konfigurasi untuk API Base URL
/// 
/// IMPORTANT: Saat deploy, pastikan baseUrl sesuai dengan URL production Django server!
/// 
/// Sesuaikan base URL sesuai dengan environment:
/// - Chrome/Web (Development): http://localhost:8000
/// - Android Emulator: http://10.0.2.2:8000
/// - iOS Simulator: http://localhost:8000
/// - Device Fisik: http://[IP_KOMPUTER_KAMU]:8000
///   Contoh: http://192.168.1.100:8000
/// - Production: https://your-domain.com (atau sesuai URL Django production)
/// 
/// Untuk deployment, gunakan environment variable atau build configuration
/// untuk mengubah baseUrl secara otomatis berdasarkan environment.
class ApiConfig {
  // TODO: Sesuaikan dengan URL Django server kamu
  // Untuk Chrome/Web (Development), gunakan localhost
  static const String baseUrl = 'http://localhost:8000';
  
  // Untuk Android Emulator, uncomment ini:
  // static const String baseUrl = 'http://10.0.2.2:8000';
  
  // Untuk device fisik, uncomment dan ganti dengan IP komputer kamu:
  // static const String baseUrl = 'http://192.168.1.100:8000';
  
  // Untuk Production, uncomment dan ganti dengan URL Django production:
  // static const String baseUrl = 'https://your-domain.com';
}

