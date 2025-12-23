import 'package:axon_vision/pages/dashboard/dashboard_page.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // 1. Cek Kosong
    if (email.isEmpty || password.isEmpty) {
      _showDialog(
        title: 'Gagal Masuk',
        message: 'Mohon isi Username dan Password terlebih dahulu.',
        isSuccess: false,
      );
      return;
    }

    // 2. Cek Credential (Simulasi)
    if ((email == 'radiolog' || email == 'dokter') && password == '123456') {
      // SUKSES
      _showDialog(
        title: 'Login Berhasil',
        message: 'Mengalihkan ke Dashboard...',
        isSuccess: true,
      );

      // Pindah Halaman
      Future.delayed(const Duration(milliseconds: 1500), () {
        Get.offAll(() => const DashboardPage());
      });
    } else {
      // GAGAL
      _showDialog(
        title: 'Akses Ditolak',
        message: 'Username atau Password yang Anda masukkan salah.',
        isSuccess: false,
      );
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
                    child: PoppinsTextView(
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
