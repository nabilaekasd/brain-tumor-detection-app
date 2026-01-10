import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileSettingsView extends GetView<AdminController> {
  const ProfileSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyProfile();
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PoppinsTextView(
            value: "Pengaturan Profil",
            size: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.blueDark,
          ),
          const SizedBox(height: 8),
          PoppinsTextView(
            value: "Perbarui informasi akun dan keamanan Anda.",
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- KARTU FOTO PROFIL ---
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
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => controller.pickAndUploadImage(),
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
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            blurRadius: 5,
                                            offset: const Offset(0, 3))
                                      ]),
                                  child: const Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      PoppinsTextView(
                        value: controller.usernameC.text.isNotEmpty
                            ? controller.usernameC.text
                            : "Administrator",
                        fontWeight: FontWeight.bold,
                        size: 18,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const PoppinsTextView(
                        value: "Admin",
                        size: 12,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 30),

              // --- FORM EDIT ---
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
                          offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PoppinsTextView(
                          value: "Edit Informasi",
                          size: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2C3E50)),
                      const Divider(height: 30),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: "Nama Lengkap",
                              controller: controller.fullNameC,
                              icon: Icons.badge_outlined,
                              hint: "Masukkan nama lengkap",
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              label: "Username",
                              controller: controller.usernameC,
                              icon: Icons.person_outline,
                              hint: "Masukkan username",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const PoppinsTextView(
                          value: "Keamanan (Ganti Password)",
                          size: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2C3E50)),
                      const Divider(height: 30),

                      // [FIX] Ditambahkan parameter hint di pemanggilan ini
                      _buildPasswordField(
                        label: "Password Lama (Opsional)",
                        controller: controller.oldPasswordC,
                        isObscure: controller.isObscureOld,
                        hint: "Kosongkan jika tidak ingin ganti",
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        label: "Password Baru (Opsional)",
                        controller: controller.newPasswordC,
                        isObscure: controller.isObscureNew,
                        hint: "Masukkan password baru",
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => controller.saveProfile(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueDark,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                            alignment: Alignment.center,
                          ),
                          child: const PoppinsTextView(
                            value: "Simpan Perubahan",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: 16,
                          ),
                        ),
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

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required IconData icon,
      required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
            value: label,
            size: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.blueDark),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  // [FIX] Ditambahkan String? hint di parameter
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool isObscure,
    String? hint, // <--- INI YANG TADI HILANG
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
            value: label,
            size: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.blueDark),
        const SizedBox(height: 8),
        Obx(() => TextField(
              controller: controller,
              obscureText: isObscure.value,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Colors.grey, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                      isObscure.value ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 20),
                  onPressed: () => isObscure.toggle(),
                ),
                hintText: hint ?? "Masukkan $label", // Gunakan hint
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            )),
      ],
    );
  }
}
