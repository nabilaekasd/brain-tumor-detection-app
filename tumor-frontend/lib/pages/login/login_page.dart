import 'package:axon_vision/controllers/login_controller.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_text_field.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
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
    SizeConfig().init(context);

    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.black,
      colorScaffold: AppColors.white,
      statusBarBrightness: Brightness.light,
      view: GetBuilder<LoginController>(
        init: LoginController(),
        builder: (LoginController loginController) => Row(
          children: [
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
                    // Dekorasi Lingkaran 1 (Pojok Kanan Atas)
                    Positioned(
                      top: -SizeConfig.safeBlockHorizontal * 10,
                      right: -SizeConfig.safeBlockHorizontal * 10,
                      child: Container(
                        width: SizeConfig.safeBlockHorizontal * 40,
                        height: SizeConfig.safeBlockHorizontal * 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Dekorasi Lingkaran 2 (Pojok Kiri Bawah)
                    Positioned(
                      bottom: SizeConfig.safeBlockVertical * 5,
                      left: -SizeConfig.safeBlockHorizontal * 5,
                      child: Container(
                        width: SizeConfig.safeBlockHorizontal * 25,
                        height: SizeConfig.safeBlockHorizontal * 25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ),

                    // Konten Teks & Logo
                    Padding(
                      padding: EdgeInsets.all(SizeConfig.horizontal(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo Container
                          Container(
                            padding: EdgeInsets.all(SizeConfig.horizontal(1)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              AssetList.axonLogo,
                              width: SizeConfig.safeBlockHorizontal * 8,
                              color: Colors.white,
                            ),
                          ),
                          SpaceSizer(vertical: 3),

                          PoppinsTextView(
                            value: 'Sistem Deteksi\nTumor Otak',
                            size: SizeConfig.safeBlockHorizontal * 2.2,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          SpaceSizer(vertical: 2),

                          Container(
                            width: SizeConfig.safeBlockHorizontal * 5,
                            height: 4,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          SpaceSizer(vertical: 2),

                          PoppinsTextView(
                            value:
                                'Sistem untuk keperluan diagnostik dan analisis medis.',
                            size: SizeConfig.safeBlockHorizontal * 0.9,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w400,
                          ),
                          SpaceSizer(vertical: 0.5),
                          PoppinsTextView(
                            value:
                                'Pastikan Anda memiliki otorisasi untuk mengakses.',
                            size: SizeConfig.safeBlockHorizontal * 0.8,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 5,
              child: Container(
                color: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.horizontal(3),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PoppinsTextView(
                            value: 'Selamat Datang Kembali!',
                            size: SizeConfig.safeBlockHorizontal * 1.8,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blueDark,
                          ),
                          SpaceSizer(vertical: 0.5),
                          PoppinsTextView(
                            value: 'Silakan login ke akun Anda.',
                            size: SizeConfig.safeBlockHorizontal * 0.9,
                            color: AppColors.grey,
                          ),

                          SpaceSizer(vertical: 4),

                          // INPUT USERNAME
                          CustomTextField(
                            controller: loginController.emailController,
                            title: 'Username/Email',
                            hintText: 'Masukkan username',
                            fillColor: AppColors.bgColor.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: 0.8,
                            width: 100,
                          ),

                          SpaceSizer(vertical: 2),

                          // INPUT PASSWORD
                          CustomTextField(
                            controller: loginController.passwordController,
                            title: 'Password',
                            hintText: 'Masukkan password',
                            fillColor: AppColors.bgColor.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: 0.8,
                            width: 100,
                            obscureText: isObscure,
                            maxLines: 1,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            ),
                          ),

                          SpaceSizer(vertical: 1.5),

                          // Lupa Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => _showForgotPasswordDialog(context),
                              child: PoppinsTextView(
                                value: 'Lupa Password?',
                                color: AppColors.blueDark,
                                fontWeight: FontWeight.w600,
                                size: SizeConfig.safeBlockHorizontal * 0.8,
                              ),
                            ),
                          ),

                          SpaceSizer(vertical: 3),

                          // Tombol Login
                          CustomFlatButton(
                            width: double.infinity,
                            height: SizeConfig.safeBlockVertical * 6,
                            text: 'Login',
                            radius: 0.8,
                            onTap: () {
                              loginController.login();
                            },
                            backgroundColor: AppColors.blueDark,
                            textColor: Colors.white,
                            textSize: SizeConfig.safeBlockHorizontal * 0.9,
                          ),

                          SpaceSizer(vertical: 5),

                          Center(
                            child: PoppinsTextView(
                              value: '© 2025 Axon Vision. All Rights Reserved.',
                              size: SizeConfig.safeBlockHorizontal * 0.7,
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
        ),
      ),
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
            SizedBox(width: 10),
            Text(
              "Akses Terbatas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
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
