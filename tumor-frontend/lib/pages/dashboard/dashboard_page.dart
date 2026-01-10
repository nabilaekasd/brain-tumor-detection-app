import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/hasil_analisis_pasien.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/home_dashboard.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/data_pasien_menu_detail.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/pengaturan_profil.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/upload_scan_mri.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/daftar_pasien_menu.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
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
    int notificationCount = 3; // Variabel ini sekarang akan TERPAKAI

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
              borderRadius: BorderRadius.circular(
                SizeConfig.safeBlockHorizontal * 1.5,
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
                // SIDEBAR
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width:
                        dashboardController.isSidebarExpanded.value ? 250 : 0,
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
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AssetList.axonLogo,
                                fit: BoxFit.contain,
                                height: 120,
                                errorBuilder: (c, e, s) => Icon(
                                  Icons.shield,
                                  size: 80,
                                  color: AppColors.blueDark,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _RadiologLeftMenu(
                                activeIndex:
                                    dashboardController.activeMenuIndex,
                                onMenuTap: (index) =>
                                    dashboardController.changeMenu(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Obx(
                  () => dashboardController.isSidebarExpanded.value
                      ? Container(
                          width: 1,
                          color: AppColors.greyDisabled.withValues(alpha: 0.5),
                        )
                      : const SizedBox.shrink(),
                ),

                // KONTEN KANAN
                Expanded(
                  child: Column(
                    children: [
                      // HEADER
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.greyDisabled.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          borderRadius:
                              dashboardController.isSidebarExpanded.value
                                  ? const BorderRadius.only(
                                      topRight: Radius.circular(20),
                                    )
                                  : const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () =>
                                  dashboardController.toggleSidebar(),
                              icon: Icon(
                                dashboardController.isSidebarExpanded.value
                                    ? Icons.menu_open
                                    : Icons.menu,
                                color: AppColors.black,
                                size: 24,
                              ),
                            ),
                            SpaceSizer(horizontal: 1),
                            PoppinsTextView(
                              value: _getTitle(
                                dashboardController.activeMenuIndex,
                              ),
                              size: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blueDark,
                            ),
                            const Spacer(),
                            const PoppinsTextView(
                              value: 'Halo, Radiolog',
                              size: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            SpaceSizer(horizontal: 1),

                            // --- POPUP MENU (YANG DIPERBAIKI) ---
                            PopupMenuButton<String>(
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'profil',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Profil Saya",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                // --- MENU NOTIFIKASI DITAMBAHKAN DI SINI ---
                                PopupMenuItem(
                                  value: 'notifikasi',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        "Notifikasi",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      const Spacer(),
                                      // Logika Badge Merah (Variable notificationCount terpakai di sini)
                                      if (notificationCount > 0)
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$notificationCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'logout',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        "Keluar",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (val) {
                                if (val == 'profil') {
                                  dashboardController.changeMenu(5);
                                }
                                if (val == 'logout') {
                                  _showLogoutDialog();
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: AppColors.blueCard.withValues(
                                  alpha: 0.1,
                                ),
                                radius: 20,
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.blueDark,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ISI KONTEN
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: _buildActiveMenu(dashboardController),
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

  String _getTitle(int index) {
    if (index == 0) return 'Dashboard';
    if (index == 1) return 'Daftar Pasien';
    if (index == 2) return 'Detail Pasien';
    if (index == 3) return 'Upload Scan';
    if (index == 4) return 'Hasil Analisis';
    if (index == 5) return 'Pengaturan Profil';
    return 'Menu';
  }

  Widget _buildActiveMenu(DashboardController dashboardController) {
    Widget scrollable(Widget child) => SingleChildScrollView(child: child);

    switch (dashboardController.activeMenuIndex) {
      case 0:
        return scrollable(Home(dashboardController: dashboardController));
      case 1:
        return const DaftarPasienMenu();
      case 2:
        return scrollable(
          DataPasienMenuDetail(
            dashboardController: dashboardController,
            pasienData: dashboardController.selectedPasien!,
            onBack: () => dashboardController.backToPasienList(),
          ),
        );
      case 3:
        return scrollable(
          UploadScanMri(
            dashboardController: dashboardController,
            pasienData: dashboardController.selectedPasien!,
            onBack: () => dashboardController.backToPasienList(),
          ),
        );
      case 4:
        return scrollable(
          HasilAnalisisPasien(
            dashboardController: dashboardController,
            pasienData: dashboardController.selectedPasien!,
            onBack: () => dashboardController.backToPasienList(),
          ),
        );
      case 5:
        return scrollable(const PengaturanProfil());
      default:
        return scrollable(Home(dashboardController: dashboardController));
    }
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Konfirmasi Logout",
      middleText: "Yakin ingin keluar?",
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        Get.offAll(() => const LoginPage());
      },
    );
  }
}

class _RadiologLeftMenu extends StatelessWidget {
  final Function(int) onMenuTap;
  final int activeIndex;
  const _RadiologLeftMenu({required this.onMenuTap, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _item(0, 'Dashboard', Icons.dashboard_outlined),
        const SizedBox(height: 8),
        _item(
          1,
          'Data Pasien',
          Icons.people_outline,
          isActive: [1, 2, 3, 4].contains(activeIndex),
        ),
        const SizedBox(height: 8),
        _item(5, 'Pengaturan Profil', Icons.settings_outlined),
        const SizedBox(height: 40),
        Divider(color: AppColors.grey.withValues(alpha: 0.5), thickness: 0.5),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PoppinsTextView(
                value: 'Axon Vision v1.0.0',
                size: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 4),
              PoppinsTextView(
                value: '© 2025 All Rights Reserved',
                size: 10,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _item(int index, String label, IconData icon, {bool? isActive}) {
    bool active = isActive ?? (activeIndex == index);
    return CustomRippleButton(
      onTap: () => onMenuTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: active
              ? AppColors.blueDark.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? AppColors.blueDark : AppColors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PoppinsTextView(
                value: label,
                size: 13,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? AppColors.blueDark : AppColors.grey,
              ),
            ),
            if (active)
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.blueDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
