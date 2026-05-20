import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/admin/widgets/manajemen_user_menu.dart';
import 'package:axon_vision/pages/admin/widgets/manajemen_pasien_view.dart';
import 'package:axon_vision/pages/admin/widgets/monitoring_log_view.dart';
import 'package:axon_vision/pages/admin/widgets/profile_settings_view.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/admin/widgets/dashboard_view.dart';
import 'package:axon_vision/helpers/snackbar.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    // GUNAKAN MEDIA QUERY AGAR REAL-TIME SAAT BROWSER DI-RESIZE
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 850;
    bool showAdminName =
        screenWidth > 1000; // Trik Baru: Sembunyikan nama kalau layar < 1000px

    // =========================================================
    // 1. TAMPILAN HP (NATIVE MURNI ANDROID/IOS)
    // =========================================================
    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xffF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: AppColors.black),
          title: Obx(() {
            var _ = controller.activeMenuIndex.value;
            return PoppinsTextView(
              value: controller.headerTitle.value,
              size: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.blueDark,
            );
          }),
          actions: [
            _buildProfileMenu(controller),
            const SizedBox(width: 16),
          ],
        ),
        drawer: Drawer(
          child: _buildSidebarContent(context, controller, true),
        ),
        body: Obx(() {
          var _ = controller.activeMenuIndex.value;
          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ClipRRect(child: _buildContent(controller)),
          );
        }),
      );
    }

    // =========================================================
    // 2. TAMPILAN DESKTOP/PC (FRAME MELAYANG)
    // =========================================================
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
            width: screenWidth * 0.95, // Lebar 95% dari layar real-time
            height: screenHeight * 0.95, // Tinggi 95% dari layar real-time
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SIDEBAR KIRI (ANIMATED)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: controller.isSidebarExpanded.value ? 250 : 0,
                  decoration: const BoxDecoration(
                    color: Color(0xFFf0F4FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 250,
                      child: _buildSidebarContent(context, controller, false),
                    ),
                  ),
                ),

                // GARIS PEMBATAS SIDEBAR
                if (controller.isSidebarExpanded.value)
                  Container(
                      width: 1,
                      color: AppColors.greyDisabled.withValues(alpha: 0.5)),

                // KONTEN KANAN
                Expanded(
                  child: Column(
                    children: [
                      // HEADER KANAN ATAS
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: controller.isSidebarExpanded.value
                              ? const BorderRadius.only(
                                  topRight: Radius.circular(20))
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                          border: Border(
                              bottom: BorderSide(
                                  color: AppColors.greyDisabled
                                      .withValues(alpha: 0.5),
                                  width: 1)),
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
                            // Expanded ini agar Judul tidak jebol kalau didesak
                            Expanded(
                              child: PoppinsTextView(
                                value: controller.headerTitle.value,
                                size: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueDark,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // TRIK BARU: Teks Administrator disembunyikan kalau layar sempit!
                            if (showAdminName) ...[
                              Column(
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
                              ),
                              const SizedBox(width: 12),
                            ],

                            // Avatar selalu muncul
                            _buildProfileMenu(controller),
                          ],
                        ),
                      ),
                      // ISI KONTEN ADMIN
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(
                            child: _buildContent(controller),
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

  // ===============================================
  // KUMPULAN WIDGET HELPER (SIDEBAR, MENU, DLL)
  // ===============================================

  Widget _buildSidebarContent(
      BuildContext context, AdminController controller, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Image.asset(
            AssetList.axonLogo,
            fit: BoxFit.contain,
            height: 120,
            errorBuilder: (c, e, s) =>
                Icon(Icons.shield, size: 90, color: AppColors.blueDark),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Column(
                  children: [
                    _buildMenuItem(
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      isActive: controller.activeMenuIndex.value == 0,
                      onTap: () {
                        controller.changeMenu(0);
                        if (isMobile) Get.back();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      label: 'Kelola Akun',
                      icon: Icons.manage_accounts_outlined,
                      isActive: controller.activeMenuIndex.value == 1,
                      onTap: () {
                        controller.changeMenu(1);
                        if (isMobile) Get.back();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      label: 'Manajemen Data Pasien',
                      icon: Icons.people_outline,
                      isActive: controller.activeMenuIndex.value == 2,
                      onTap: () {
                        controller.changeMenu(2);
                        if (isMobile) Get.back();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      label: 'Monitoring Log',
                      icon: Icons.receipt_long_outlined,
                      isActive: controller.activeMenuIndex.value == 3,
                      onTap: () {
                        controller.changeMenu(3);
                        if (isMobile) Get.back();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      label: 'Pengaturan Profil',
                      icon: Icons.settings_rounded,
                      isActive: controller.activeMenuIndex.value == 4,
                      onTap: () {
                        controller.changeMenu(4);
                        if (isMobile) Get.back();
                      },
                    ),
                  ],
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                  color: AppColors.grey.withValues(alpha: 0.5), thickness: 0.5),
              const SizedBox(height: 10),
              PoppinsTextView(
                  value: "Axon Vision v1.0.0", size: 10, color: AppColors.grey),
              const SizedBox(height: 4),
              PoppinsTextView(
                  value: "© 2026 All Rights Reserved",
                  size: 10,
                  color: AppColors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(AdminController controller) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'profil') controller.navigateToProfile();
        if (value == 'logout') _showLogoutDialog();
      },
      child: Obx(() {
        String url = controller.profileImageUrl.value;
        return CircleAvatar(
          backgroundColor: AppColors.blueCard.withValues(alpha: 0.1),
          radius: 18,
          backgroundImage:
              url.isNotEmpty ? NetworkImage("${ApiConfig.baseUrl}/$url") : null,
          child: url.isEmpty
              ? Icon(Icons.person, color: AppColors.blueDark, size: 20)
              : null,
        );
      }),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profil',
          child: Row(children: [
            Icon(Icons.person_outline, color: Colors.grey, size: 18),
            SizedBox(width: 12),
            PoppinsTextView(
                value: "Profil Saya", size: 12, color: Colors.black87),
          ]),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout, color: Colors.red, size: 18),
            SizedBox(width: 12),
            PoppinsTextView(value: "Keluar", color: Colors.red, size: 12),
          ]),
        ),
      ],
    );
  }

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

  Widget _buildMenuItem({
    required String label,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CustomRippleButton(
      onTap: onTap,
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
            Icon(icon,
                size: 20,
                color: isActive ? AppColors.blueDark : AppColors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: PoppinsTextView(
                value: label,
                size: 12,
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
                    borderRadius: BorderRadius.circular(2)),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    SnackbarHelper.showConfirmDialog(
        title: "Konfirmasi Logout",
        description:
            "Apakah Anda yakin ingin keluar dari Admin Panel? Sesi Anda akan berakhir.",
        confirmText: "Ya, Keluar",
        icon: Icons.power_settings_new_rounded,
        iconColor: Colors.redAccent,
        onConfirm: () {
          Get.find<AdminController>().logout();
        });
  }
}
