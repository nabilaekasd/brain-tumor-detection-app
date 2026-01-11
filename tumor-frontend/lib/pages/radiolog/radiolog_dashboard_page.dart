import 'package:axon_vision/controllers/login_controller.dart';
import 'package:axon_vision/controllers/radiolog_controller.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/pages/radiolog/radiolog_patient_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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
        DateFormat('EE, dd MMM yyyy', 'id_ID').format(DateTime.now());

    return SingleChildScrollView(
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
                  PoppinsTextView(
                    value: "${getGreeting()}, Radiolog!",
                    size: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff2C3E50),
                  ),
                  const SizedBox(height: 4),
                  PoppinsTextView(
                    value: "Update hari ini: $todayDate",
                    size: 14,
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
                        blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xff2C3E50)),
                    const SizedBox(width: 8),
                    Text("2026",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff2C3E50))),
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
                    title: "Menunggu Analisis",
                    value: "${controller.dashboardSummary['total_menunggu']}",
                    icon: Icons.hourglass_top_rounded,
                    color: const Color(0xffff919e),
                  ),
                  const SizedBox(width: 20),
                  _buildModernStatCard(
                    title: "Selesai",
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
                size: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff2C3E50),
              ),
              InkWell(
                onTap: () => controller.changeMenu(1),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: PoppinsTextView(
                    value: "Lihat Semua",
                    size: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff4facfe),
                  ),
                ),
              )
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
                        child: PoppinsTextView(
                            value: "Belum ada riwayat scan.",
                            size: 14,
                            color: Colors.grey)));
              }

              var recentHistory = controller.riwayatScanList.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentHistory.length,
                separatorBuilder: (c, i) =>
                    const Divider(height: 1, color: Colors.grey, endIndent: 20),
                itemBuilder: (context, index) {
                  var item = recentHistory[index];
                  bool isTumor =
                      item['hasil_prediksi'].toString().contains("Tumor");

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isTumor
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.document_scanner,
                          color: isTumor ? Colors.red : Colors.green, size: 20),
                    ),
                    title: Text(item['nama_pasien'] ?? "Tanpa Nama",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(
                        "${item['jenis_mri']} • ${item['hasil_prediksi']}",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey)),
                    trailing: Text(item['tanggal_periksa'],
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  );
                },
              );
            }),
          )
        ],
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
            const SizedBox(width: 20),
            PoppinsTextView(
                value: title,
                size: 13,
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
      ),
    );
  }
}

class RadiologDashboardPage extends StatelessWidget {
  const RadiologDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final RadiologController controller = Get.put(RadiologController());

    return FrameScaffold(
        heightBar: 0,
        elevation: 0,
        color: AppColors.black,
        statusBarColor: AppColors.black,
        colorScaffold: AppColors.white,
        statusBarBrightness: Brightness.light,
        view: Obx(() => Center(
            child: Container(
                width: SizeConfig.safeBlockHorizontal * 90,
                height: SizeConfig.safeBlockVertical * 96,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                      SizeConfig.safeBlockHorizontal * 1.5),
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
                      //Sidebar Kiri
                      Container(
                        width: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf0F4FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                SizeConfig.safeBlockHorizontal * 1.5),
                            bottomLeft: Radius.circular(
                                SizeConfig.safeBlockHorizontal * 1.5),
                          ),
                        ),
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
                                    Icons.medical_services,
                                    size: 90,
                                    color: AppColors.blueDark),
                              ),
                            ),

                            // Menu List
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                    label: 'Data Pasien dan Analisis',
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
                            const SizedBox(height: 40),
                            Divider(
                                color: AppColors.grey.withValues(alpha: 0.5),
                                thickness: 0.5),
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
                        ),
                      ),
                      Expanded()
                    ])))));
  }
}
