import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_text_field.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PengaturanProfil extends StatefulWidget {
  const PengaturanProfil({super.key});

  @override
  State<PengaturanProfil> createState() => _PengaturanProfilState();
}

class _PengaturanProfilState extends State<PengaturanProfil> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    nameController.text = "Dr. Dirman Santoso, Sp.Rad";
    usernameController.text = "radiolog_dirman";
    emailController.text = "dirman.santoso@rs-axon.com";
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PoppinsTextView(
                value: 'Pengaturan Profil',
                size: SizeConfig.safeBlockHorizontal * 1.2,
                fontWeight: FontWeight.bold,
                color: AppColors.blueDark,
              ),
              PoppinsTextView(
                value: 'Kelola informasi akun dan keamanan sandi Anda.',
                size: SizeConfig.safeBlockHorizontal * 0.8,
                color: AppColors.grey,
              ),
            ],
          ),

          SpaceSizer(vertical: 3),

          // DATA DIRI
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.horizontal(2)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.greyDisabled),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO PROFIL
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      SpaceSizer(vertical: 2),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.blueCard,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: SizeConfig.safeBlockHorizontal * 5,
                              backgroundColor: AppColors.bgColor.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.blueDark,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.blueDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SpaceSizer(vertical: 1),
                      PoppinsTextView(
                        value: 'RADIOLOG',
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueDark,
                        size: SizeConfig.safeBlockHorizontal * 0.8,
                      ),
                    ],
                  ),
                ),

                SpaceSizer(horizontal: 2),

                // FORM DATA
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Informasi Dasar'),
                      SpaceSizer(vertical: 2),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: nameController,
                              title: 'Nama Lengkap',
                              titleFontWeight: FontWeight.w600,
                              borderRadius: 0.8,
                            ),
                          ),
                          SpaceSizer(horizontal: 2),
                          Expanded(
                            child: CustomTextField(
                              controller: usernameController,
                              title: 'Username',
                              titleFontWeight: FontWeight.w600,
                              borderRadius: 0.8,
                            ),
                          ),
                        ],
                      ),
                      SpaceSizer(vertical: 2),

                      CustomTextField(
                        controller: emailController,
                        title: 'Email Resmi',
                        titleFontWeight: FontWeight.w600,
                        borderRadius: 0.8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SpaceSizer(vertical: 3),

          // PASSWORD
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(SizeConfig.horizontal(2)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.greyDisabled),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Keamanan Kata Sandi'),
                SpaceSizer(vertical: 2),

                CustomTextField(
                  controller: oldPassController,
                  title: 'Password Saat Ini',
                  hintText: 'Masukkan password lama',
                  borderRadius: 0.8,
                  obscureText: obscureOld,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureOld ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => obscureOld = !obscureOld),
                  ),
                ),
                SpaceSizer(vertical: 2),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: newPassController,
                        title: 'Password Baru',
                        hintText: 'Minimal 8 karakter',
                        borderRadius: 0.8,
                        obscureText: obscureNew,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => obscureNew = !obscureNew),
                        ),
                      ),
                    ),
                    SpaceSizer(horizontal: 2),
                    Expanded(
                      child: CustomTextField(
                        controller: confirmPassController,
                        title: 'Konfirmasi Password',
                        hintText: 'Ulangi password baru',
                        borderRadius: 0.8,
                        obscureText: obscureConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => obscureConfirm = !obscureConfirm),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SpaceSizer(vertical: 3),

          // TOMBOL AKSI
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text("Reset", style: TextStyle(color: AppColors.grey)),
              ),
              SpaceSizer(horizontal: 2),

              CustomFlatButton(
                icon: Icons.check_circle_outline,
                text: 'Simpan Perubahan',
                onTap: () {
                  Get.dialog(
                    Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white,
                      elevation: 10,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 80,
                              ),
                            ),
                            const SizedBox(height: 20),

                            PoppinsTextView(
                              value: "Berhasil Disimpan",
                              fontWeight: FontWeight.bold,
                              size: 22,
                              color: AppColors.blueDark,
                            ),
                            const SizedBox(height: 10),

                            PoppinsTextView(
                              value:
                                  "Data profil Anda telah berhasil diperbarui ke dalam sistem.",
                              textAlign: TextAlign.center,
                              size: 14,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blueDark,
                                  foregroundColor: AppColors.blueDark,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: PoppinsTextView(
                                  value: "OK",
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
                },

                width: SizeConfig.blockSizeHorizontal * 12,
                height: SizeConfig.safeBlockVertical * 5.0,
                backgroundColor: AppColors.blueDark,
                textColor: Colors.white,
                colorIconImage: Colors.white,
                radius: 0.8,
                textSize: SizeConfig.safeBlockHorizontal * 0.75,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, color: AppColors.blueDark),
        SizedBox(width: 8),
        PoppinsTextView(
          value: title,
          fontWeight: FontWeight.bold,
          size: SizeConfig.safeBlockHorizontal * 0.9,
          color: AppColors.black,
        ),
      ],
    );
  }
}
