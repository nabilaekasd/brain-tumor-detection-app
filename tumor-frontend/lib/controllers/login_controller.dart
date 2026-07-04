import 'dart:convert';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/pages/admin/admin_dashboard_page.dart';
import 'package:axon_vision/pages/dashboard/dashboard_page.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/login/login_page.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final box = GetStorage();

  // --- FUNGSI LOGIN ---
  Future<void> login() async {
    String username = emailController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showDialog(
        title: 'Gagal Masuk',
        message: 'Mohon isi Username dan Password terlebih dahulu.',
        isSuccess: false,
      );
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // [2] GUNAKAN BASE URL DARI CONFIG
      var url = Uri.parse('${ApiConfig.baseUrl}/token/');

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );

      if (Get.isDialogOpen ?? false) Get.back();

      // [A] JIKA LOGIN SUKSES
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String token = data['access_token'];

        await box.write('token', token);
        await box.write('username', username);

        String role = data['role'] ?? 'dokter';
        await box.write('role', data['role']);

        debugPrint("Login Berhasil! Role: $role");

        _showDialog(
          title: 'Login Berhasil',
          message: 'Selamat datang kembali, $role!',
          isSuccess: true,
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (Get.isDialogOpen ?? false) Get.back();

          String safeRole = role.toLowerCase().trim();

          if (safeRole == 'admin') {
            Get.offAll(() => const AdminDashboardPage());
          } else if (safeRole == 'radiolog') {
            Get.offAllNamed(AppRoute.radiologDashboard);
          } else if (safeRole == 'dokter') {
            Get.offAllNamed(AppRoute.dokterDashboard);
          }
        });
      }
      // [B] JIKA AKUN DINONAKTIFKAN (TANGKAP BUG 403 DI SINI)
      else if (response.statusCode == 403) {
        debugPrint("Login Failed: Akun Non-aktif (403)");

        var errorData = json.decode(response.body);
        String errorMessage = errorData['detail'] ??
            'Akun Anda telah dinonaktifkan. Silakan hubungi IT System Administrator.';

        _showDialog(
          title: 'Akun Non-aktif',
          message: errorMessage,
          isSuccess: false,
        );
      }
      // [C] JIKA USERNAME/PASSWORD SALAH (400/401 ATAU ERROR LAIN)
      else {
        debugPrint("Login Failed: ${response.statusCode}");

        var errorData = json.decode(response.body);
        String errorMessage = errorData['detail'] ??
            'Username atau Password salah. Silakan coba lagi.';

        _showDialog(
          title: 'Akses Ditolak',
          message: errorMessage,
          isSuccess: false,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showDialog(
        title: 'Kesalahan Koneksi',
        message: 'Gagal terhubung ke server.\nPastikan backend sudah menyala.',
        isSuccess: false,
      );
      debugPrint("Error Login: $e");
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> logout() async {
    try {
      String? token = box.read('token');

      if (token != null) {
        // [3] GUNAKAN BASE URL JUGA DI SINI
        var url = Uri.parse('${ApiConfig.baseUrl}/logout/');

        await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      debugPrint("Gagal lapor logout ke server: $e");
    } finally {
      box.remove('token');
      box.remove('role');
      box.remove('username');

      Get.offAll(() => const LoginPage());
    }
  }

  void _showDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: (isSuccess ? Colors.green : Colors.redAccent)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.close_rounded,
                  color: isSuccess ? Colors.green : Colors.redAccent,
                  size: 80,
                ),
              ),
              const SizedBox(height: 20),
              PoppinsTextView(
                value: title,
                fontWeight: FontWeight.bold,
                size: 22,
                color: AppColors.blueDark,
              ),
              const SizedBox(height: 10),
              PoppinsTextView(
                value: message,
                textAlign: TextAlign.center,
                size: 14,
                color: Colors.grey,
                height: 1.5,
              ),
              const SizedBox(height: 30),
              if (!isSuccess)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const PoppinsTextView(
                      value: "Coba Lagi",
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
