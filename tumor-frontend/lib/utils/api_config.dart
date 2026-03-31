import 'package:flutter/foundation.dart';

class ApiConfig {
  // Ganti IP ini jika sudah ada VPS
  static const String _vpsUrl = "http://103.xxx.xxx.xxx:8000";

  // URL untuk di laptop (Development)
  static const String _localUrl = "http://127.0.0.1:8000";

  static String get baseUrl {
    if (kReleaseMode) {
      return _vpsUrl;
    } else {
      return _localUrl;
    }
  }
}
