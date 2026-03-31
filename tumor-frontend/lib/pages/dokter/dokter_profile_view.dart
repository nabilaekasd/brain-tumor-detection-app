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
          const PoppinsTextView(
            value: "Kelola informasi profil dan keamanan akun Anda.",
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 32),

          // KARTU PROFIL UTAMA
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO PROFIL (KIRI)
                Column(
                  children: [
                    Obx(() {
                      String url = controller.profileImageUrl.value;
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blueCard.withValues(alpha: 0.1),
                          border:
                              Border.all(color: Colors.blue.shade100, width: 4),
                          image: url.isNotEmpty
                              ? DecorationImage(
                                  image:
                                      NetworkImage("${ApiConfig.baseUrl}/$url"),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: url.isEmpty
                            ? Icon(Icons.person,
                                size: 60, color: AppColors.blueDark)
                            : null,
                      );
                    }),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => controller.pickAndUploadAvatar(),
                      icon: const Icon(Icons.camera_alt_outlined, size: 16),
                      label: const PoppinsTextView(
                        value: "Ubah Foto",
                        size: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.blueDark,
                        side: BorderSide(color: AppColors.blueDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 40),

                // FORMULIR PROFIL (KANAN)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField("Nama Lengkap", controller.myFullNameC,
                          Icons.badge_outlined),
                      const SizedBox(height: 20),
                      _buildTextField("Username", controller.myUsernameC,
                          Icons.alternate_email),
                      const SizedBox(height: 20),
                      const Divider(height: 40),
                      const PoppinsTextView(
                        value: "Ubah Password (Opsional)",
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => _buildPasswordField(
                                  "Password Lama",
                                  controller.oldPasswordC,
                                  controller.isObscureOld.value,
                                  () => controller.isObscureOld.toggle(),
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => _buildPasswordField(
                                  "Password Baru",
                                  controller.newPasswordC,
                                  controller.isObscureNew.value,
                                  () => controller.isObscureNew.toggle(),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.saveProfile(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const PoppinsTextView(
                                      value: "Simpan Perubahan",
                                      color: Colors.white,
                                      size: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                            )),
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
            value: label,
            size: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: const Color(0xffF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      bool isObscure, VoidCallback toggleEye) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
            value: label,
            size: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
              onPressed: toggleEye,
            ),
            filled: true,
            fillColor: const Color(0xffF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
