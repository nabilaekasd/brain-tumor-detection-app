import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/admin/widgets/manajemen_user_menu.dart';
import 'package:axon_vision/pages/admin/widgets/manajemen_pasien_view.dart';
import 'package:axon_vision/pages/admin/widgets/monitoring_log_view.dart';
import 'package:axon_vision/pages/admin/widgets/profile_settings_view.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/admin/widgets/dashboard_view.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final AdminController controller = Get.put(AdminController());

    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.black,
      colorScaffold: AppColors.white,
      statusBarBrightness: Brightness.light,
      view: Obx(
        () => Center(
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
                // ===============================================
                // 1. SIDEBAR KIRI (FIXED SIZE)
                // ===============================================
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: controller.isSidebarExpanded.value
                      ? 250 // Lebar Sidebar Fixed (250px)
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
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ====================================================
                          // LOGO AREA (DIUBAH: LEBIH BESAR & TENGAH)
                          // ====================================================
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                            ), // Padding vertikal lebih lega
                            alignment: Alignment.center, // POSISI KE TENGAH
                            child: Image.asset(
                              AssetList.axonLogo,
                              fit: BoxFit.contain,
                              height:
                                  120, // UKURAN DIPERBESAR (dari 60 jadi 120)
                              errorBuilder: (c, e, s) => Icon(
                                Icons.shield,
                                size: 90,
                                color: AppColors.blueDark,
                              ),
                            ),
                          ),
                          // ====================================================

                          // MENU LIST
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _AdminLeftMenu(
                              activeIndex: controller.activeMenuIndex.value,
                              onMenuTap: (index) =>
                                  controller.changeMenu(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // GARIS PEMBATAS
                if (controller.isSidebarExpanded.value)
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: AppColors.greyDisabled.withValues(alpha: 0.5),
                  ),

                // ===============================================
                // 2. KONTEN KANAN
                // ===============================================
                Expanded(
                  child: Column(
                    children: [
                      // --- HEADER ---
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: controller.isSidebarExpanded.value
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
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
                          children: [
                            IconButton(
                              onPressed: () => controller.toggleSidebar(),
                              icon: Icon(
                                controller.isSidebarExpanded.value
                                    ? Icons.menu_open
                                    : Icons.menu,
                                color: AppColors.black,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Judul Dinamis
                            Obx(
                              () => PoppinsTextView(
                                value: controller.headerTitle.value,
                                size: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueDark,
                              ),
                            ),

                            const Spacer(),

                            // Info Admin
                            Obx(() => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    PoppinsTextView(
                                      value: controller.displayName.value,
                                      size: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blueDark,
                                    ),
                                    PoppinsTextView(
                                      value: controller.displayRole.value
                                          .toUpperCase(),
                                      size: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ],
                                )),
                            const SizedBox(width: 12),

                            // Avatar Dropdown
                            PopupMenuButton<String>(
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (value) {
                                if (value == 'profil') {
                                  controller.navigateToProfile();
                                }
                                if (value == 'logout') {
                                  _showLogoutDialog();
                                }
                              },
                              child: Obx(() {
                                String url = controller.profileImageUrl.value;
                                return CircleAvatar(
                                  backgroundColor:
                                      AppColors.blueCard.withValues(alpha: 0.1),
                                  radius: 20,
                                  backgroundImage: url.isNotEmpty
                                      ? NetworkImage(
                                          "${ApiConfig.baseUrl}/$url")
                                      : null,
                                  child: url.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: AppColors.blueDark,
                                          size: 20,
                                        )
                                      : null,
                                );
                              }),
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
                                      PoppinsTextView(
                                        value: "Profil Saya",
                                        size: 14,
                                        color: Colors.black87,
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
                                      PoppinsTextView(
                                        value: "Keluar",
                                        color: Colors.red,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- ISI KONTEN ---
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: _buildContent(controller),
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

  // Content Switcher
  Widget _buildContent(AdminController controller) {
    switch (controller.activeMenuIndex.value) {
      case 0:
        return const DashboardView();
      case 1:
        return const ManajemenUserMenu();
      case 2:
        return const ManajemenPasienView();
      case 3:
        return const MonitoringLogView();
      case 4:
        return const ProfileSettingsView();
      default:
        return const SizedBox();
    }
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: "Konfirmasi Logout",
      titleStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      middleText: "Apakah Anda yakin ingin keluar?",
      middleTextStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      radius: 12,
      onConfirm: () {
        Get.back();
        Get.find<AdminController>().logout();
      },
    );
  }
}

// =========================================================
// WIDGET SIDEBAR KHUSUS ADMIN (FIXED SIZES)
// =========================================================
class _AdminLeftMenu extends StatelessWidget {
  final Function(int) onMenuTap;
  final int activeIndex;

  const _AdminLeftMenu({required this.onMenuTap, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        _buildMenuItem(
          index: 0,
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          isActive: activeIndex == 0,
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          index: 1,
          label: 'Kelola Akun',
          icon: Icons.manage_accounts_outlined,
          isActive: activeIndex == 1,
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          index: 2,
          label: 'Manajemen Data Pasien',
          icon: Icons.people_outline,
          isActive: activeIndex == 2,
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          index: 3,
          label: 'Monitoring Log',
          icon: Icons.receipt_long_outlined,
          isActive: activeIndex == 3,
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          index: 4,
          label: 'Pengaturan Profil',
          icon: Icons.settings_outlined,
          isActive: activeIndex == 4,
        ),
        const SizedBox(height: 40),
        Divider(color: AppColors.grey.withValues(alpha: 0.5), thickness: 0.5),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PoppinsTextView(
                value: 'Axon Vision v1.0.0',
                size: 11,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 4),
              PoppinsTextView(
                value: '© 2025 All Rights Reserved',
                size: 10,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Style Menu Item
  Widget _buildMenuItem({
    required int index,
    required String label,
    required bool isActive,
    required IconData icon,
  }) {
    return CustomRippleButton(
      onTap: () => onMenuTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
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
              color: isActive ? AppColors.blueDark : AppColors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PoppinsTextView(
                value: label,
                size: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.blueDark : AppColors.grey,
              ),
            ),
            if (isActive)
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
