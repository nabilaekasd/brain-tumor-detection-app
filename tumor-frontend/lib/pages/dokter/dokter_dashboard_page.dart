import 'package:axon_vision/controllers/login_controller.dart';
import 'package:axon_vision/controllers/dokter_controller.dart';
import 'package:axon_vision/controllers/notification_controller.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/dokter/dokter_patient_view.dart';
import 'package:axon_vision/pages/dokter/dokter_profile_view.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// WIDGET KONTEN DASHBOARD (HOME) DOKTER
class DokterHomeView extends StatelessWidget {
  const DokterHomeView({super.key});

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) return 'Selamat Pagi';
    if (hour >= 10 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final DokterController controller = Get.find<DokterController>();
    String todayDate =
        DateFormat('EEE, d MMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => PoppinsTextView(
                          value:
                              "${getGreeting()}, ${controller.displayName.value}!",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2C3E50),
                        )),
                    const SizedBox(height: 4),
                    PoppinsTextView(
                      value: "Update hari ini: $todayDate",
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 16, color: Color(0xff2C3E50)),
                      const SizedBox(width: 8),
                      Text(
                        "${DateTime.now().year}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff2C3E50),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 30),
            Obx(() => Row(
                  children: [
                    _buildModernStatCard(
                      title: "Total Pasien",
                      value: "${controller.dashboardSummary['total_pasien']}",
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xff4facfe),
                    ),
                    const SizedBox(width: 20),
                    _buildModernStatCard(
                      title: "Menunggu Hasil MRI",
                      value: "${controller.dashboardSummary['total_menunggu']}",
                      icon: Icons.hourglass_top_rounded,
                      color: const Color(0xffff9a9e),
                    ),
                    const SizedBox(width: 20),
                    _buildModernStatCard(
                      title: "Hasil Tersedia",
                      value: "${controller.dashboardSummary['total_selesai']}",
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xff43e97b),
                    ),
                  ],
                )),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PoppinsTextView(
                  value: "Riwayat Analisis Terbaru",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2C3E50),
                ),
                InkWell(
                  onTap: () => controller.changeMenu(1),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: PoppinsTextView(
                      value: "Lihat Semua",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff4facfe),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator()));
                }
                if (controller.riwayatScanList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: PoppinsTextView(
                          value: "Belum ada riwayat scan.",
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                var recentHistory = controller.riwayatScanList.take(5).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentHistory.length,
                  separatorBuilder: (c, i) => const Divider(
                      height: 1, color: Colors.grey, indent: 70, endIndent: 20),
                  itemBuilder: (context, index) {
                    var item = recentHistory[index];
                    bool isTumor = item['hasil_prediksi']
                            .toString()
                            .contains("Tumor") ||
                        item['hasil_prediksi'].toString().contains("Cancer");

                    return ListTile(
                      onTap: () {
                        controller.activeIndex.value = 1;
                        controller.openAnalysisResult(item['id'].toString());
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isTumor
                              ? Colors.red.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.document_scanner,
                            color: isTumor ? Colors.red : Colors.green,
                            size: 20),
                      ),
                      title: PoppinsTextView(
                        value: item['nama_pasien'] ?? 'Tanpa Nama',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xff2C3E50),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: PoppinsTextView(
                          value:
                              "${item['jenis_mri']} • ${item['hasil_prediksi']}",
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: PoppinsTextView(
                        value: item['tanggal_periksa'],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.trending_up, color: Colors.grey[300], size: 20)
              ],
            ),
            const SizedBox(width: 20),
            PoppinsTextView(
              value: title,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            const SizedBox(height: 4),
            PoppinsTextView(
              value: value,
              size: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C3E50),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================================================
// 2. KERANGKA UTAMA DASHBOARD DOKTER
// ========================================================================
class DokterDashboardPage extends StatelessWidget {
  const DokterDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final DokterController controller = Get.put(DokterController());

    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.white,
      colorScaffold: AppColors.white,
      statusBarBrightness: Brightness.light,
      view: Obx(
        () => Center(
          child: Container(
            width: SizeConfig.safeBlockHorizontal * 90,
            height: SizeConfig.safeBlockVertical * 96,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(SizeConfig.safeBlockHorizontal * 1.5),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: controller.isSidebarExpanded.value ? 250 : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf0F4FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        SizeConfig.safeBlockHorizontal * 1.5,
                      ),
                      bottomLeft:
                          Radius.circular(SizeConfig.safeBlockHorizontal * 1.5),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 40,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              AssetList.axonLogo,
                              fit: BoxFit.contain,
                              height: 120,
                              errorBuilder: (c, e, s) => Icon(
                                Icons.medical_services,
                                size: 90,
                                color: AppColors.blueDark,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                _buildMenuItem(
                                  index: 0,
                                  label: 'Dashboard',
                                  icon: Icons.dashboard_outlined,
                                  isActive: controller.activeIndex.value == 0,
                                  onTap: () => controller.changeMenu(0),
                                ),
                                const SizedBox(height: 8),
                                _buildMenuItem(
                                  index: 1,
                                  label: 'Data Pasien & Analisis',
                                  icon: Icons.people_outline,
                                  isActive: controller.activeIndex.value == 1,
                                  onTap: () => controller.changeMenu(1),
                                ),
                                const SizedBox(height: 8),
                                _buildMenuItem(
                                  index: 2,
                                  label: 'Pengaturan Profil',
                                  icon: Icons.settings_outlined,
                                  isActive: controller.activeIndex.value == 2,
                                  onTap: () => controller.changeMenu(2),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(
                                    color:
                                        AppColors.grey.withValues(alpha: 0.5),
                                    thickness: 0.5),
                                const SizedBox(height: 10),
                                PoppinsTextView(
                                  value: "Axon Vision v1.0.0",
                                  size: 11,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(height: 4),
                                PoppinsTextView(
                                  value: "© 2025 All Rights Reserved",
                                  size: 10,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.isSidebarExpanded.value)
                  Container(
                    width: 1,
                    height: double.infinity,
                    color: AppColors.greyDisabled.withValues(alpha: 0.5),
                  ),
                Expanded(
                  child: Column(
                    children: [
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
                            Obx(() => PoppinsTextView(
                                value: controller.currentHeaderTitle,
                                size: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blueDark)),
                            const Spacer(),
                            const NotificationBell(role: 'Dokter'),
                            const SizedBox(width: 24),
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
                            PopupMenuButton<String>(
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onSelected: (val) {
                                if (val == 'profil') {
                                  controller.navigateToProfile();
                                }
                                if (val == 'notifikasi') {
                                  Get.snackbar(
                                    "Info",
                                    "Tidak ada notifikasi baru.",
                                    backgroundColor: Colors.blue.shade50,
                                    colorText: AppColors.blueDark,
                                    margin: const EdgeInsets.all(20),
                                  );
                                }
                                if (val == 'logout') _showLogoutDialog();
                              },
                              child: Obx(() {
                                String url = controller.profileImageUrl.value;
                                return CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      AppColors.blueCard.withValues(alpha: 0.1),
                                  backgroundImage: url.isNotEmpty
                                      ? NetworkImage(
                                          "${ApiConfig.baseUrl}/$url")
                                      : null,
                                  child: url.isEmpty
                                      ? Icon(Icons.person,
                                          color: AppColors.blueDark, size: 20)
                                      : null,
                                );
                              }),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'profil',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_outline,
                                          color: Colors.grey, size: 20),
                                      SizedBox(width: 12),
                                      PoppinsTextView(
                                        value: "Profil Saya",
                                        size: 14,
                                        color: Colors.black87,
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'notifikasi',
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_outlined,
                                          color: Colors.grey, size: 20),
                                      SizedBox(width: 12),
                                      PoppinsTextView(
                                        value: "Notifikasi",
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
                                      Icon(Icons.logout,
                                          color: Colors.red, size: 20),
                                      SizedBox(width: 12),
                                      PoppinsTextView(
                                        value: "Keluar",
                                        size: 14,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
  Widget _buildContent(DokterController controller) {
    if (controller.activeIndex.value == 0) return const DokterHomeView();
    if (controller.activeIndex.value == 1) return const DokterPatientView();
    if (controller.activeIndex.value == 2) return const DokterProfileView();
    return const SizedBox();
  }

  Widget _buildMenuItem({
    required int index,
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
                      borderRadius: BorderRadius.circular(2))),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final DokterController controller = Get.find<DokterController>();
    Get.defaultDialog(
        title: "Konfirmasi Logout",
        middleText: "Yakin ingin keluar?",
        textConfirm: "Ya",
        textCancel: "Batal",
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        onConfirm: () {
          Get.back();
          Get.delete<NotificationController>();
          controller.logout();
        });
  }
}

class NotificationBell extends StatelessWidget {
  final String role;
  const NotificationBell({super.key, required this.role});

  void _showNotificationPopup(
      BuildContext context, NotificationController notifCtrl) {
    Get.dialog(
      Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(
              top: SizeConfig.safeBlockVertical * 10,
              right: SizeConfig.safeBlockHorizontal * 5),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 350,
              constraints: const BoxConstraints(minWidth: 300, maxHeight: 450),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  // HEADER POPUP
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PoppinsTextView(
                            value: "Notifikasi",
                            fontWeight: FontWeight.bold,
                            size: 16,
                            color: AppColors.black),
                        InkWell(
                            onTap: () => Get.back(),
                            child: const Icon(Icons.close,
                                size: 20, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Divider(
                      height: 1,
                      color: AppColors.greyDisabled.withValues(alpha: 0.5)),

                  // ISI NOTIFIKASI
                  Expanded(
                    child: Obx(() {
                      if (notifCtrl.isLoading.value &&
                          notifCtrl.notifications.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (notifCtrl.notifications.isEmpty) {
                        return const Center(
                            child: PoppinsTextView(
                                value: "Belum ada notifikasi baru.",
                                color: Colors.grey,
                                size: 13));
                      }
                      return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: notifCtrl.notifications.length,
                          separatorBuilder: (c, i) => Divider(
                              height: 1,
                              color: AppColors.greyDisabled
                                  .withValues(alpha: 0.5)),
                          itemBuilder: (c, i) {
                            var notif = notifCtrl.notifications[i];
                            return InkWell(
                              onTap: () {
                                notifCtrl.markAsRead(notif.id);
                                Get.back(); // Tutup popup

                                // NAVIGASI CEPAT KE DETAIL PASIEN
                                if (notif.analysisId != null) {
                                  if (role == 'Dokter') {
                                    final ctrl = Get.find<DokterController>();
                                    ctrl.activeIndex.value =
                                        1; // Pindah ke menu Data Pasien
                                    ctrl.openAnalysisResult(
                                        notif.analysisId.toString());
                                  } else {
                                    final ctrl = Get.find<DokterController>();
                                    ctrl.activeIndex.value =
                                        1; // Pindah ke menu Data Pasien
                                    ctrl.openAnalysisResult(
                                        notif.analysisId.toString());
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                color: notif.isRead
                                    ? Colors.transparent
                                    : AppColors.blueDark
                                        .withValues(alpha: 0.05),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ICON
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: notif.isRead
                                            ? Colors.grey.withValues(alpha: 0.1)
                                            : AppColors.blueDark
                                                .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.notifications_active,
                                          size: 18,
                                          color: notif.isRead
                                              ? Colors.grey
                                              : AppColors.blueDark),
                                    ),
                                    const SizedBox(width: 12),
                                    // TEKS
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          PoppinsTextView(
                                              value: notif.title,
                                              fontWeight: notif.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              size: 13,
                                              color: AppColors.black),
                                          const SizedBox(height: 4),
                                          PoppinsTextView(
                                              value: notif.message,
                                              size: 12,
                                              color: Colors.black87),
                                          const SizedBox(height: 8),
                                          PoppinsTextView(
                                              value: notif.createdAt,
                                              size: 10,
                                              color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                    // TITIK MERAH (Jika belum dibaca)
                                    if (!notif.isRead)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: CircleAvatar(
                                            radius: 4,
                                            backgroundColor: Colors.red),
                                      )
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors
          .transparent, // Biar background gak gelap (seperti dropdown asli)
    );
  }

  @override
  Widget build(BuildContext context) {
    final NotificationController notifCtrl = Get.put(NotificationController());
    return Obx(() {
      int count = notifCtrl.unreadCount;
      return InkWell(
        onTap: () => _showNotificationPopup(context, notifCtrl),
        borderRadius: BorderRadius.circular(50),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(Icons.notifications_outlined, color: AppColors.grey, size: 26),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
