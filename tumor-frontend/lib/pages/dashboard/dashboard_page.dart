import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/hasil_analisis_pasien.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/home_dashboard.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/left_text_menu.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/data_pasien_menu_detail.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/pengaturan_profil.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/upload_scan_mri.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/daftar_pasien_menu.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/login/login_page.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int notificationCount = 3;

    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.black,
      colorScaffold: AppColors.white,
      statusBarBrightness: Brightness.light,
      view: GetBuilder<DashboardController>(
        init: DashboardController(),
        builder: (DashboardController dashboardController) => Center(
          child: Container(
            width: SizeConfig.safeBlockHorizontal * 90,
            height: SizeConfig.safeBlockVertical * 96,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(SizeConfig.safeBlockHorizontal * 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SIDEBAR KIRI
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: dashboardController.isSidebarExpanded.value
                        ? SizeConfig.safeBlockHorizontal * 15
                        : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0F4FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          SizeConfig.safeBlockHorizontal * 1.5,
                        ),
                        bottomLeft: Radius.circular(
                          SizeConfig.safeBlockHorizontal * 1.5,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: SizeConfig.horizontal(2),
                                top: SizeConfig.vertical(3),
                                bottom: SizeConfig.vertical(2),
                              ),
                              child: Image.asset(
                                AssetList.axonLogo,
                                fit: BoxFit.contain,
                                width: SizeConfig.safeBlockHorizontal * 12,
                                height: SizeConfig.safeBlockVertical * 12,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: SizeConfig.horizontal(2),
                              ),
                              child: LeftTextMenu(
                                onMenuTap: (index) {
                                  dashboardController.changeMenu(index);
                                },
                                activeIndex:
                                    dashboardController.activeMenuIndex,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // GARIS PEMBATAS
                Obx(
                  () => dashboardController.isSidebarExpanded.value
                      ? Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.horizontal(1),
                          ),
                          width: 1,
                          height: double.infinity,
                          color: AppColors.greyDisabled.withValues(alpha: 0.5),
                        )
                      : const SizedBox.shrink(),
                ),

                // AREA KONTEN KANAN
                Expanded(
                  child: Column(
                    children: [
                      // HEADER
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.vertical(2),
                          horizontal: SizeConfig.horizontal(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.greyDisabled.withValues(
                                alpha: 0.5,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                dashboardController.toggleSidebar();
                              },
                              icon: Icon(
                                dashboardController.isSidebarExpanded.value
                                    ? Icons.menu_open
                                    : Icons.menu,
                                color: AppColors.black,
                              ),
                              tooltip: 'Toggle Sidebar',
                            ),
                            SpaceSizer(horizontal: 1),

                            PoppinsTextView(
                              value: dashboardController.activeMenuIndex == 0
                                  ? 'Dashboard'
                                  : dashboardController.activeMenuIndex == 5
                                  ? 'Pengaturan Profil'
                                  : 'Detail Pasien',
                              size: SizeConfig.safeBlockHorizontal * 1.2,
                              fontWeight: FontWeight.bold,
                            ),

                            const Spacer(),

                            PoppinsTextView(
                              value: 'Halo, User',
                              size: SizeConfig.safeBlockHorizontal * 0.9,
                              fontWeight: FontWeight.w500,
                            ),
                            SpaceSizer(horizontal: 1),

                            // POPUP MENU USER (AVATAR)
                            PopupMenuButton<String>(
                              offset: const Offset(0, 50),
                              tooltip: 'Profil Menu',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    // HAPUS CONST DI SINI
                                    const PopupMenuItem<String>(
                                      value: 'profil',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 10),
                                          PoppinsTextView(
                                            value: 'Profil Saya',
                                            color: Colors.black87,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'notifikasi',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.notifications_outlined,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 10),
                                          PoppinsTextView(
                                            value: 'Notifikasi',
                                            color: Colors.black87,
                                            size: 14,
                                          ),
                                          Spacer(),
                                          if (notificationCount > 0)
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: Colors.redAccent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: PoppinsTextView(
                                                  value: '$notificationCount',
                                                  color: Colors.white,
                                                  size: 10,
                                                  fontWeight: FontWeight.bold,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    // HAPUS CONST DI SINI
                                    const PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            color: Colors.redAccent,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          PoppinsTextView(
                                            value: 'Keluar',
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                              onSelected: (value) {
                                if (value == 'profil') {
                                  dashboardController.changeMenu(5);
                                } else if (value == 'logout') {
                                  // POPUP LOGOUT
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
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.redAccent
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 20,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.logout_rounded,
                                                color: Colors.redAccent,
                                                size: 80,
                                              ),
                                            ),
                                            const SizedBox(height: 20),

                                            PoppinsTextView(
                                              value: "Konfirmasi Logout",
                                              fontWeight: FontWeight.bold,
                                              size: 22,
                                              color: Colors.black87,
                                            ),
                                            const SizedBox(height: 10),

                                            PoppinsTextView(
                                              value:
                                                  "Apakah Anda yakin ingin keluar dari aplikasi?\nSesi Anda akan diakhiri.",
                                              textAlign: TextAlign.center,
                                              size: 14,
                                              color: Colors.grey,
                                              height: 1.5,
                                            ),
                                            const SizedBox(height: 30),

                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: () => Get.back(),
                                                    style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                        color: AppColors
                                                            .greyDisabled,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 16,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),

                                                    child: PoppinsTextView(
                                                      value: "Batal",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColors.grey,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      Get.back();
                                                      Get.offAll(
                                                        () => const LoginPage(),
                                                      );
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                      foregroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 16,
                                                          ),
                                                    ),

                                                    child: PoppinsTextView(
                                                      value: "Ya, Keluar",
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    barrierDismissible: false,
                                  );
                                }
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.blueCard
                                        .withValues(alpha: 0.1),
                                    radius: 22,
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.blueDark,
                                    ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      child: Text(
                                        '$notificationCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SpaceSizer(horizontal: 1),
                          ],
                        ),
                      ),

                      // ISI KONTEN
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.horizontal(2),
                            vertical: SizeConfig.vertical(2),
                          ),
                          physics: dashboardController.activeMenuIndex == 4
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_buildActiveMenu(dashboardController)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveMenu(DashboardController dashboardController) {
    switch (dashboardController.activeMenuIndex) {
      case 0:
        return Home(dashboardController: dashboardController);
      case 1:
        return const DaftarPasienMenu();
      case 2:
        return DataPasienMenuDetail(
          dashboardController: dashboardController,
          pasienData: dashboardController.selectedPasien!,
          onBack: () {
            dashboardController.backToPasienList();
          },
        );
      case 3:
        return UploadScanMri(
          dashboardController: dashboardController,
          pasienData: dashboardController.selectedPasien!,
          onBack: () {
            dashboardController.backToPasienList();
          },
        );
      case 4:
        return HasilAnalisisPasien(
          dashboardController: dashboardController,
          pasienData: dashboardController.selectedPasien!,
          onBack: () {
            dashboardController.backToPasienList();
          },
        );
      case 5:
        return const PengaturanProfil();

      default:
        return Home(dashboardController: dashboardController);
    }
  }
}
