import 'package:axon_vision/controllers/radiolog_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RadiologProfileView extends GetView<RadiologController> {
  const RadiologProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan data profil terbaru diambil saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyProfile();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        // Deteksi apakah layar saat ini berukuran mobile/tablet kecil
        bool isMobile = constraints.maxWidth < 850;

        // ===============================================
        // 1. WIDGET KARTU FOTO PROFIL
        // ===============================================
        Widget profileCard = Container(
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
                        color: AppColors.blueCard.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.blueCard.withValues(alpha: 0.2),
                          width: 2,
                        ),
                        image: hasImage
                            ? DecorationImage(
                                image: NetworkImage(
                                    "${ApiConfig.baseUrl}/$url?v=${DateTime.now().millisecondsSinceEpoch}"),
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
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
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
                    size: 14,
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
        );

        // ===============================================
        // 2. WIDGET FORM EDIT DATA
        // ===============================================
        Widget formCard = Container(
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
                size: 14,
                color: Color(0xff2C3E50),
              ),
              const Divider(height: 30),

              // Baris Input Nama & Username (Responsive)
              if (isMobile) ...[
                // Di HP: Tumpuk ke bawah
                _buildTextField(
                  label: "Nama Lengkap",
                  controller: controller.myFullNameC,
                  icon: Icons.badge_outlined,
                  hint: "Masukkan nama lengkap",
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: "Username",
                  controller: controller.myUsernameC,
                  icon: Icons.person_outline,
                  hint: "Masukkan username",
                  readOnly: true,
                ),
              ] else ...[
                // Di Layar Besar: Sebelahan Kiri-Kanan
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
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 30),

              // Header Section 2 (Ganti Password)
              const PoppinsTextView(
                value: "Keamanan (Ganti Password)",
                fontWeight: FontWeight.bold,
                size: 14,
                color: Color(0xff2C3E50),
              ),
              const Divider(height: 30),

              // FIELD PASSWORD LAMA
              _buildPasswordField(
                label: "Password Lama (Opsional)",
                controller: controller.oldPasswordC,
                isObscure: controller.isObscureOld,
                hint: "Masukkan password lama",
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
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const PoppinsTextView(
                              value: "Simpan Perubahan",
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              size: 14,
                            ),
                    )),
              ),
            ],
          ),
        );

        // ===============================================
        // 3. SUSUNAN HALAMAN UTAMA
        // ===============================================
        return SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PoppinsTextView(
                  value: "Perbarui informasi akun dan keamanan Anda.",
                  size: 12,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),

                // --- RENDER RESPONSIF ---
                if (isMobile)
                  Column(
                    children: [
                      profileCard,
                      const SizedBox(height: 24),
                      formCard,
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Agar kotak form tidak terlalu dominan lebarnya,
                      // kita ubah flex perbandingannya menjadi 3 : 5
                      Expanded(flex: 3, child: profileCard),
                      const SizedBox(width: 30),
                      Expanded(flex: 5, child: formCard),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            filled: true,
            prefixIcon: Icon(icon, color: Colors.grey, size: 18),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool isObscure,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller,
              obscureText: isObscure.value,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Colors.grey, size: 18),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscure.value ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => isObscure.toggle(),
                ),
                hintText: hint ?? "Masukkan $label",
                hintStyle: const TextStyle(fontSize: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            )),
      ],
    );
  }
}
