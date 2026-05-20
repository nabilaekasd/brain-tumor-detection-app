import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DashboardView extends GetView<AdminController> {
  const DashboardView({super.key});

  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 4 && hour < 10) return 'Selamat Pagi';
    if (hour >= 10 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    String todayDate =
        DateFormat('EEE, d MMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),
      // LAYOUT BUILDER BEBAS DARI KEKANGAN OBX
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Deteksi Real-Time
          bool isMobile = constraints.maxWidth < 850;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0, vertical: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER WELCOME ---
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeText(todayDate),
                      const SizedBox(height: 16),
                      _buildYearBadge(),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWelcomeText(todayDate),
                      _buildYearBadge(),
                    ],
                  ),
                const SizedBox(height: 30),

                // --- 3 KOTAK STATISTIK (LOGIKA ROW/COLUMN BERSIH DARI OBX) ---
                if (isMobile)
                  // TAMPILAN HP: TURUN KE BAWAH (COLUMN)
                  Column(
                    children: [
                      _buildModernStatCard(
                        title: "Total User",
                        valueGetter: () => "${controller.userList.length}",
                        icon: Icons.people_alt_rounded,
                        color: const Color(0xff4facfe),
                      ),
                      const SizedBox(height: 16),
                      _buildModernStatCard(
                        title: "Pasien Aktif",
                        valueGetter: () => "${controller.patientList.length}",
                        icon: Icons.health_and_safety_rounded,
                        color: const Color(0xfffa709a),
                      ),
                      const SizedBox(height: 16),
                      _buildModernStatCard(
                        title: "Total Log",
                        valueGetter: () => "${controller.logList.length}",
                        icon: Icons.analytics_rounded,
                        color: const Color(0xff43e97b),
                      ),
                    ],
                  )
                else
                  // TAMPILAN PC: MENYAMPING (ROW + EXPANDED)
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          title: "Total User",
                          valueGetter: () => "${controller.userList.length}",
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xff4facfe),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildModernStatCard(
                          title: "Pasien Aktif",
                          valueGetter: () => "${controller.patientList.length}",
                          icon: Icons.health_and_safety_rounded,
                          color: const Color(0xfffa709a),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildModernStatCard(
                          title: "Total Log",
                          valueGetter: () => "${controller.logList.length}",
                          icon: Icons.analytics_rounded,
                          color: const Color(0xff43e97b),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                // --- AKTIVITAS TERBARU ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: PoppinsTextView(
                        value: "Aktivitas Terbaru",
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff2C3E50),
                      ),
                    ),
                    InkWell(
                      onTap: () => controller.changeMenu(3),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: PoppinsTextView(
                          value: "Lihat Semua",
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff4facfe),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // --- BOX LIST AKTIVITAS ---
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
                      ]),
                  // OBX HANYA MEMBUNGKUS DAFTARNYA SAJA
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator()),
                      );
                    }

                    if (controller.logList.isEmpty) {
                      return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                                child: PoppinsTextView(
                                    value: "Belum ada aktivitas.",
                                    color: Colors.grey,
                                    fontSize: 14))),
                      );
                    }

                    var recentLogs = controller.logList.take(5).toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentLogs.length,
                      separatorBuilder: (c, i) => const Divider(
                          height: 1,
                          color: Colors.grey,
                          indent: 70,
                          endIndent: 20),
                      itemBuilder: (context, index) {
                        var log = recentLogs[index];
                        return _buildActivityTile(log);
                      },
                    );
                  }),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildWelcomeText(String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              "${getGreeting()}, ${controller.displayName.value}!",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2C3E50),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )),
        const SizedBox(height: 4),
        PoppinsTextView(
          value: "Update hari ini: $date",
          fontSize: 12,
          color: Colors.grey,
        ),
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
          Text(
            "${DateTime.now().year}",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xff2C3E50),
            ),
          ),
        ],
      ),
    );
  }

  // DI SINI RAHASIANYA! value diubah menjadi valueGetter (fungsi)
  // agar Obx bisa ditaruh langsung membungkus angkanya saja.
  Widget _buildModernStatCard({
    required String title,
    required String Function() valueGetter,
    required IconData icon,
    required Color color,
  }) {
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
                  borderRadius: BorderRadius.circular(12),
                ),
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
            color: Colors.grey,
          ),
          const SizedBox(height: 4),
          // OBX HANYA MEMBUNGKUS ANGKA INI
          Obx(() => PoppinsTextView(
                value: valueGetter(),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xff2C3E50),
              )),
        ],
      ),
    );
  }

  Widget _buildActivityTile(dynamic log) {
    Color iconColor;
    IconData iconData;
    String activityLower = log.activity.toLowerCase();

    if (activityLower.contains("login")) {
      iconColor = Colors.green;
      iconData = Icons.login_rounded;
    } else if (activityLower.contains("logout") ||
        activityLower.contains("keluar")) {
      iconColor = Colors.redAccent;
      iconData = Icons.logout_rounded;
    } else if (activityLower.contains("update") ||
        activityLower.contains("edit")) {
      iconColor = Colors.orange;
      iconData = Icons.edit_document;
    } else if (activityLower.contains("delete") ||
        activityLower.contains("hapus")) {
      iconColor = Colors.red;
      iconData = Icons.delete_outline_rounded;
    } else if (activityLower.contains("create") ||
        activityLower.contains("tambah")) {
      iconColor = Colors.blue;
      iconData = Icons.add_circle_outline;
    } else {
      iconColor = Colors.grey;
      iconData = Icons.article_outlined;
    }

    String displayTime = "";
    try {
      // Pastikan string cukup panjang sebelum dipotong (menghindari error)
      if (log.timestamp != null && log.timestamp.length >= 16) {
        // Ambil karakter ke-11 sampai ke-16 (yaitu HH:mm)
        displayTime = log.timestamp.substring(11, 16);
      } else {
        displayTime = "-";
      }
    } catch (e) {
      displayTime = "-";
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: PoppinsTextView(
        value: log.activity,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: const Color(0xff2C3E50),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          "${log.username} • ${log.details}",
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Text(
        displayTime, // 👈 Tampilkan hasil potongan string murninya!
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}
