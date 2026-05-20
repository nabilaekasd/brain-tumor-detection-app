import 'package:axon_vision/controllers/login_controller.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.black,
      colorScaffold: AppColors.bgColor, // Base background color
      statusBarBrightness: Brightness.light,
      view: GetBuilder<LoginController>(
        init: LoginController(),
        builder: (LoginController loginController) => LayoutBuilder(
          builder: (context, constraints) {
            // DETEKSI LEBAR LAYAR
            bool isMobile = constraints.maxWidth < 800;

            if (isMobile) {
              // ============================================
              // 1. TAMPILAN MOBILE & TABLET KECIL (HP)
              // ============================================
              return Stack(
                children: [
                  // Aksen dekoratif untuk background HP
                  Container(
                    height: constraints.maxHeight * 0.45,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.blueDark, AppColors.bgColor],
                      ),
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Menampilkan Logo dan Teks Judul di HP
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              AssetList.axonLogo,
                              width: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const PoppinsTextView(
                            value: 'Sistem Deteksi\nTumor Otak',
                            size: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),

                          // Kotak Form Login
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 400),
                            // Padding disesuaikan agar tidak terlalu sesak
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _buildFormContent(loginController,
                                isMobile: true),
                          ),
                          const SizedBox(height: 30),
                          const PoppinsTextView(
                            value: '© 2026 Axon Vision. All Rights Reserved.',
                            size: 11,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // ============================================
              // 2. TAMPILAN DESKTOP/LAYAR LEBAR (SPLIT SCREEN)
              // ============================================
              return Row(
                children: [
                  // --- PANEL BIRU (KIRI) ---
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.blueDark, AppColors.bgColor],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Dekorasi Lingkaran
                          Positioned(
                            top: -100,
                            right: -100,
                            child: _buildDecorativeCircle(400),
                          ),
                          Positioned(
                            bottom: 50,
                            left: -50,
                            child: _buildDecorativeCircle(250),
                          ),

                          // Konten Teks & Logo Kiri
                          Padding(
                            padding: const EdgeInsets.all(60.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Image.asset(
                                    AssetList.axonLogo,
                                    width: 80,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const PoppinsTextView(
                                  value: 'Sistem Deteksi\nTumor Otak',
                                  size: 42,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: 60,
                                  height: 4,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 24),
                                PoppinsTextView(
                                  value:
                                      'Sistem untuk keperluan diagnostik dan analisis medis.',
                                  size: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                                const SizedBox(height: 8),
                                PoppinsTextView(
                                  value:
                                      'Pastikan Anda memiliki otorisasi untuk mengakses.',
                                  size: 12,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- PANEL PUTIH FORM (KANAN) ---
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFormContent(loginController,
                                    isMobile: false),
                                const SizedBox(height: 60),
                                Center(
                                  child: PoppinsTextView(
                                    value:
                                        '© 2026 Axon Vision. All Rights Reserved.',
                                    size: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // --- WIDGET HELPER DEKORASI ---
  Widget _buildDecorativeCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  // --- WIDGET HELPER FORM UTAMA ---
  Widget _buildFormContent(LoginController loginController,
      {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: 'Selamat Datang Kembali!',
          size: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 6),
        PoppinsTextView(
          value: 'Silakan login ke akun Anda.',
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 36),

        // INPUT USERNAME
        _buildInputField(
          label: 'Username / Email',
          hint: 'Masukkan username',
          controller: loginController.emailController,
          isMobile: isMobile,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),

        // INPUT PASSWORD
        _buildInputField(
          label: 'Password',
          hint: 'Masukkan password',
          controller: loginController.passwordController,
          isObscure: isObscure,
          isMobile: isMobile,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) {
            loginController.login();
          },
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                isObscure = !isObscure;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // LUPA PASSWORD
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () => _showForgotPasswordDialog(context),
            child: PoppinsTextView(
              value: 'Lupa Password?',
              color: AppColors.blueDark,
              fontWeight: FontWeight.w600,
              size: 12,
            ),
          ),
        ),
        const SizedBox(height: 36),

        // TOMBOL LOGIN (Diperbaiki Tingginya)
        SizedBox(
          width: double.infinity,
          height: 45, // Dilangsingkan agar tidak terlihat balok
          child: ElevatedButton(
            onPressed: () {
              loginController.login();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blueDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: PoppinsTextView(
              value: 'Login',
              color: Colors.white,
              size: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER INPUT FIELD BUKAN KUSTOM ---
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isMobile,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.blueDark, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// Dialog Info Lupa Password
void _showForgotPasswordDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.lock_person, color: AppColors.blueDark),
            const SizedBox(width: 10),
            const Text(
              "Akses Terbatas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Untuk alasan keamanan, reset password tidak dapat dilakukan secara mandiri. Silakan hubungi Administrator IT Rumah Sakit.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Mengerti",
              style: TextStyle(color: AppColors.blueDark),
            ),
          ),
        ],
      );
    },
  );
}
