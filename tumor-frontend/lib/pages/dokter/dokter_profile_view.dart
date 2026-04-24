import 'package:axon_vision/controllers/dokter_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DokterProfileView extends GetView<DokterController> {
  const DokterProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan data profil terbaru diambil saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyProfile();
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER JUDUL ---
          PoppinsTextView(
            value: "Pengaturan Profil",
            size: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.blueDark,
          ),
          const SizedBox(height: 8),
          const PoppinsTextView(
            value: "Perbarui informasi akun dan keamanan Anda.",
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),

          // --- KONTEN UTAMA (ROW: KIRI FOTO, KANAN FORM) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===============================================
              // 1. KARTU FOTO PROFIL (KIRI)
              // ===============================================
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Lingkaran Foto
                          Obx(() {
                            String url = controller.profileImageUrl.value;
                            bool hasImage = url.isNotEmpty;
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.blueCard.withValues(alpha: 0.1),
                                border: Border.all(
                                  color:
                                      AppColors.blueCard.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                image: hasImage
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            "${ApiConfig.baseUrl}/$url"),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: hasImage
                                  ? null
                                  : Icon(Icons.person,
                                      size: 60, color: AppColors.blueDark),
                            );
                          }),

                          // Tombol Kamera Kecil
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => controller.pickAndUploadAvatar(),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.blueDark,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: const Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Nama & Role di bawah foto
                      Obx(() => PoppinsTextView(
                            value: controller.displayName.value,
                            fontWeight: FontWeight.bold,
                            size: 18,
                            color: AppColors.blueDark,
                            textAlign: TextAlign.center,
                          )),
                      const SizedBox(height: 4),
                      Obx(() => PoppinsTextView(
                            value: controller.displayRole.value.toUpperCase(),
                            size: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 30),

              // ===============================================
              // 2. FORM EDIT DATA (KANAN)
              // ===============================================
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section 1
                      const PoppinsTextView(
                        value: "Edit Informasi",
                        fontWeight: FontWeight.bold,
                        size: 18,
                        color: Color(0xff2C3E50),
                      ),
                      const Divider(height: 30),

                      // Baris Input Nama & Username
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: "Nama Lengkap",
                              controller: controller.myFullNameC,
                              icon: Icons.badge_outlined,
                              hint: "Masukkan nama lengkap",
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              label: "Username",
                              controller: controller.myUsernameC,
                              icon: Icons.person_outline,
                              hint: "Masukkan username",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Header Section 2 (Ganti Password)
                      const PoppinsTextView(
                        value: "Keamanan (Ganti Password)",
                        fontWeight: FontWeight.bold,
                        size: 18,
                        color: Color(0xff2C3E50),
                      ),
                      const Divider(height: 30),

                      // FIELD PASSWORD LAMA
                      _buildPasswordField(
                        label: "Password Lama (Opsional)",
                        controller: controller.oldPasswordC,
                        isObscure: controller.isObscureOld,
                        hint: "Kosongkan jika tidak ingin ganti",
                      ),

                      const SizedBox(height: 20),

                      // FIELD PASSWORD BARU
                      _buildPasswordField(
                        label: "Password Baru (Opsional)",
                        controller: controller.newPasswordC,
                        isObscure: controller.isObscureNew,
                        hint: "Masukkan password baru",
                      ),

                      const SizedBox(height: 40),

                      // TOMBOL SIMPAN
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(() => ElevatedButton(
                              onPressed: () => controller.saveProfile(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueDark,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                                alignment: Alignment.center,
                              ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const PoppinsTextView(
                                      value: "Simpan Perubahan",
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      size: 16,
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            hintText: hint,
            // Style Admin (Outline Border, Content Padding)
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPER PASSWORD FIELD (DENGAN MATA & STYLE ADMIN) ---
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool isObscure, // Parameter Reactive Boolean
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller,
              obscureText: isObscure.value, // Terhubung ke Controller
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Colors.grey, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscure.value ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => isObscure.toggle(), // Toggle per field
                ),
                hintText: hint ?? "Masukkan $label",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )),
      ],
    );
  }
}
