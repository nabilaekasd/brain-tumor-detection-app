import 'package:axon_vision/controllers/login_controller.dart';
import 'package:axon_vision/controllers/radiolog_controller.dart';
import 'package:axon_vision/controllers/notification_controller.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/radiolog/radiolog_patient_view.dart';
import 'package:axon_vision/pages/radiolog/radiolog_profile_view.dart';
import 'package:axon_vision/helpers/snackbar.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ========================================================================
// 1. WIDGET KONTEN DASHBOARD (HOME)
// ========================================================================
class RadiologHomeView extends StatelessWidget {
  const RadiologHomeView({super.key});

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) return 'Selamat Pagi';
    if (hour >= 10 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final RadiologController controller = Get.find<RadiologController>();
    String todayDate =
        DateFormat('EEE, d MMM yyyy', 'id_ID').format(DateTime.now());

    return LayoutBuilder(
      builder: (context, constraints) {
        // DETEKSI LAYAR
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          backgroundColor: const Color(0xffF7F9FC),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER WELCOME ---
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeText(controller, todayDate),
                          const SizedBox(height: 16),
                          _buildYearBadge(),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildWelcomeText(controller, todayDate),
                          _buildYearBadge(),
                        ],
                      ),
                const SizedBox(height: 30),

                // --- STATISTIK CARD (AMAN GETX) ---
                Obx(() {
                  // Memancing GetX dengan variabel Rx asli agar tidak error
                  // ignore: unused_local_variable
                  var trigger = controller.isLoading.value;
                  // ignore: unused_local_variable
                  var trigger2 = controller.isSidebarExpanded.value;

                  var pasientTotal =
                      controller.dashboardSummary['total_pasien'] ?? 0;
                  var pasientNunggu =
                      controller.dashboardSummary['total_menunggu'] ?? 0;
                  var pasientSelesai =
                      controller.dashboardSummary['total_selesai'] ?? 0;

                  if (isMobile) {
                    return Column(
                      children: [
                        _buildStatCardContainer(
                            title: "Total Pasien",
                            value: "$pasientTotal",
                            icon: Icons.people_alt_rounded,
                            color: const Color(0xff4facfe)),
                        const SizedBox(height: 16),
                        _buildStatCardContainer(
                            title: "Menunggu Analisis",
                            value: "$pasientNunggu",
                            icon: Icons.hourglass_top_rounded,
                            color: const Color(0xffff9a9e)),
                        const SizedBox(height: 16),
                        _buildStatCardContainer(
                            title: "Selesai",
                            value: "$pasientSelesai",
                            icon: Icons.check_circle_rounded,
                            color: const Color(0xff43e97b)),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                            child: _buildStatCardContainer(
                                title: "Total Pasien",
                                value: "$pasientTotal",
                                icon: Icons.people_alt_rounded,
                                color: const Color(0xff4facfe))),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildStatCardContainer(
                                title: "Menunggu Analisis",
                                value: "$pasientNunggu",
                                icon: Icons.hourglass_top_rounded,
                                color: const Color(0xffff9a9e))),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildStatCardContainer(
                                title: "Selesai",
                                value: "$pasientSelesai",
                                icon: Icons.check_circle_rounded,
                                color: const Color(0xff43e97b))),
                      ],
                    );
                  }
                }),
                const SizedBox(height: 40),

                // --- RIWAYAT ANALISIS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Riwayat Analisis Terbaru",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff2C3E50)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.changeMenu(1),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Text("Lihat Semua",
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff4facfe))),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // BOX LIST RIWAYAT
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
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
                              child: PoppinsTextView(
                                  value: "Belum ada riwayat scan.",
                                  color: Colors.grey,
                                  fontSize: 12)));
                    }

                    var recentHistory =
                        controller.riwayatScanList.take(5).toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentHistory.length,
                      separatorBuilder: (c, i) => const Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: 70,
                          endIndent: 20),
                      itemBuilder: (context, index) {
                        var item = recentHistory[index];
                        bool isTumor = item['hasil_prediksi']
                                .toString()
                                .contains("Tumor") ||
                            item['hasil_prediksi']
                                .toString()
                                .contains("Cancer");

                        return ListTile(
                          onTap: () {
                            controller.activeIndex.value = 1;
                            controller
                                .openAnalysisResult(item['id'].toString());
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: isTumor
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                shape: BoxShape.circle),
                            child: Icon(Icons.document_scanner,
                                color: isTumor ? Colors.red : Colors.green,
                                size: 20),
                          ),
                          title: Text(item['nama_pasien'] ?? 'Tanpa Nama',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: const Color(0xff2C3E50)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                                "${item['jenis_mri']} • ${item['hasil_prediksi']}",
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          trailing: isMobile
                              ? null
                              : PoppinsTextView(
                                  value: item['tanggal_periksa'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                        );
                      },
                    );
                  }),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText(RadiologController controller, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text("${getGreeting()}, ${controller.displayName.value}!",
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2C3E50)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 4),
        PoppinsTextView(
            value: "Update hari ini: $date", fontSize: 12, color: Colors.grey),
      ],
    );
  }

  Widget _buildYearBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10)
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 16, color: Color(0xff2C3E50)),
          const SizedBox(width: 8),
          Text("${DateTime.now().year}",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff2C3E50))),
        ],
      ),
    );
  }

  Widget _buildStatCardContainer(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8))
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
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              Icon(Icons.trending_up, color: Colors.grey[300], size: 20)
            ],
          ),
          const SizedBox(height: 20),
          PoppinsTextView(
              value: title,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey),
          const SizedBox(height: 4),
          PoppinsTextView(
              value: value,
              size: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C3E50)),
        ],
      ),
    );
  }
}

// ========================================================================
// 2. KERANGKA UTAMA DASHBOARD (SOLUSI NATIVE SPLIT!)
// ========================================================================
class RadiologDashboardPage extends StatelessWidget {
  const RadiologDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final RadiologController controller = Get.put(RadiologController());

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    bool isMobile = screenWidth < 850;
    bool showRadiologName = screenWidth > 1000;

    if (isMobile) {
      return Scaffold(
        backgroundColor: const Color(0xffF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: IconThemeData(color: AppColors.black),
          title: Obx(() {
            var _ = controller.activeIndex.value;
            return Text(
              controller.currentHeaderTitle,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.blueDark,
              ),
            );
          }),
          actions: [
            const NotificationBell(role: 'Radilog'),
            const SizedBox(width: 8),
            _buildProfileMenu(controller),
            const SizedBox(width: 16),
          ],
        ),
        drawer: Drawer(
          child: _buildSidebarContent(context, controller, true),
        ),
        body: Obx(() {
          var _ = controller.activeIndex.value;
          return Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ClipRRect(child: _buildContent(controller)),
          );
        }),
      );
    }

    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.white,
      statusBarBrightness: Brightness.light,
      view: Obx(
        () => Center(
          child: Container(
            width: screenWidth * 0.95,
            height: screenHeight * 0.95,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
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
                          vertical: 16,
                          horizontal: 24,
                        ),
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
                              color:
                                  AppColors.greyDisabled.withValues(alpha: 0.5),
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
                            Expanded(
                              child: PoppinsTextView(
                                value: controller.currentHeaderTitle,
                                size: 14,
                                fontWeight: FontWeight.bold,
                                maxLines: 1,
                                color: AppColors.blueDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const NotificationBell(role: 'Radiolog'),
                            const SizedBox(width: 16),
                            if (showRadiologName) ...[
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
                            _buildProfileMenu(controller),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(24),
                          child: ClipRRect(child: _buildContent(controller)),
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

  Widget _buildSidebarContent(
      BuildContext context, RadiologController controller, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40),
          alignment: Alignment.center,
          child: Image.asset(AssetList.axonLogo,
              fit: BoxFit.contain,
              height: 120,
              errorBuilder: (c, e, s) => Icon(Icons.medical_services,
                  size: 90, color: AppColors.blueDark)),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Column(
                  children: [
                    _buildMenuItem(
                      index: 0,
                      label: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      isActive: controller.activeIndex.value == 0,
                      onTap: () {
                        controller.changeMenu(0);
                        if (isMobile) Get.back();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      index: 1,
                      label: 'Data Pasien & Analisis',
                      icon: Icons.people_outline,
                      isActive: controller.activeIndex.value == 1,
                      onTap: () {
                        controller.changeMenu(1);
                        if (isMobile) Get.back();
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      index: 2,
                      label: 'Pengaturan Profil',
                      icon: Icons.settings_rounded,
                      isActive: controller.activeIndex.value == 2,
                      onTap: () {
                        controller.changeMenu(2);
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
                color: AppColors.grey.withValues(alpha: 0.5),
                thickness: 0.5,
              ),
              const SizedBox(height: 10),
              PoppinsTextView(
                value: "Axon Vision v1.0.0",
                size: 10,
                color: AppColors.grey,
              ),
              const SizedBox(height: 4),
              PoppinsTextView(
                value: "© 2026 All Rights Reserved",
                size: 10,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenu(RadiologController controller) {
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'profil') {
          controller.changeMenu(2);
        }
        if (val == 'logout') {
          _showLogoutDialog(controller);
        }
      },
      child: Obx(() {
        String url = controller.profileImageUrl.value;
        bool hasImage = url.isNotEmpty;
        return CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.blueCard.withValues(alpha: 0.1),
          backgroundImage: hasImage
              ? NetworkImage(
                  "${ApiConfig.baseUrl}/$url?v=${DateTime.now().millisecondsSinceEpoch}")
              : null,
          child: hasImage
              ? null
              : Icon(Icons.person, color: AppColors.blueDark, size: 20),
        );
      }),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profil',
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.grey, size: 18),
              SizedBox(width: 12),
              PoppinsTextView(
                value: "Profil Saya",
                size: 12,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            Icon(Icons.logout, color: Colors.red, size: 18),
            SizedBox(width: 12),
            PoppinsTextView(
              value: "Keluar",
              size: 12,
              color: Colors.red,
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildContent(RadiologController controller) {
    if (controller.activeIndex.value == 0) return const RadiologHomeView();
    if (controller.activeIndex.value == 1) return const RadiologPatientView();
    if (controller.activeIndex.value == 2) return const RadiologProfileView();
    return const SizedBox();
  }

  Widget _buildMenuItem(
      {required int index,
      required String label,
      required bool isActive,
      required IconData icon,
      required VoidCallback onTap}) {
    return CustomRippleButton(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: isActive
                ? AppColors.blueDark.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(RadiologController controller) {
    SnackbarHelper.showConfirmDialog(
        title: "Konfirmasi Logout",
        description:
            "Apakah Anda yakin ingin keluar dari aplikasi Axon Vision? Sesi Anda akan berakhir.",
        confirmText: "Ya, Keluar",
        icon: Icons.power_settings_new_rounded,
        iconColor: Colors.redAccent,
        onConfirm: () {
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
            right: SizeConfig.safeBlockHorizontal * 5,
          ),
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
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PoppinsTextView(
                          value: "Notifikasi",
                          fontWeight: FontWeight.bold,
                          size: 14,
                          color: AppColors.black,
                        ),
                        InkWell(
                          onTap: () => Get.back(),
                          child: const Icon(Icons.close,
                              size: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.greyDisabled.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (notifCtrl.isLoading.value &&
                          notifCtrl.notifications.isEmpty) {
                        return const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      }
                      return ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: notifCtrl.notifications.length,
                          separatorBuilder: (c, i) => Divider(
                                height: 1,
                                color: AppColors.greyDisabled
                                    .withValues(alpha: 0.5),
                              ),
                          itemBuilder: (c, i) {
                            var notif = notifCtrl.notifications[i];
                            return InkWell(
                              onTap: () {
                                notifCtrl.markAsRead(notif.id);
                                Get.back();

                                if (notif.analysisId != null) {
                                  final ctrl = Get.find<RadiologController>();
                                  ctrl.activeIndex.value = 1;
                                  ctrl.openAnalysisResult(
                                      notif.analysisId.toString());
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
                                            size: 12,
                                            color: AppColors.black,
                                          ),
                                          const SizedBox(height: 4),
                                          PoppinsTextView(
                                            value: notif.message,
                                            size: 11,
                                            color: Colors.black87,
                                          ),
                                          const SizedBox(height: 8),
                                          PoppinsTextView(
                                            value: notif.createdAt,
                                            size: 10,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: CircleAvatar(
                                          radius: 4,
                                          backgroundColor: Colors.red,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          });
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
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
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
