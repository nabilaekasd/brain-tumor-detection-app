import 'package:axon_vision/pages/admin/admin_dashboard_page.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/home_dashboard.dart'; // Dashboard lama (opsional)
import 'package:axon_vision/pages/login/login_page.dart';
import 'package:axon_vision/pages/radiolog/radiolog_dashboard_page.dart'; // [WAJIB ADA]
import 'package:get/get.dart';

class AppRoute {
  // 1. DAFTAR NAMA RUTE
  static const String login = '/';
  static const String adminDashboard = '/admin-dashboard';
  static const String radiologDashboard = '/radiolog-dashboard';

  // Dashboard lama (jika masih mau disimpan)
  static const String dashboard = '/dashboard';

  // 2. DAFTAR HALAMAN (GET PAGES)
  static List<GetPage> pages = [
    // Rute Login (Halaman Awal)
    GetPage(
      name: login,
      page: () => const LoginPage(),
    ),

    // Rute Admin
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardPage(),
    ),

    // Rute Radiolog (Halaman Baru Kita)
    GetPage(
      name: radiologDashboard,
      page: () => const RadiologDashboardPage(),
    ),
  ];
}
