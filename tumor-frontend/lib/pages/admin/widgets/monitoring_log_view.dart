import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MonitoringLogView extends GetView<AdminController> {
  const MonitoringLogView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLogs();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER ---
        const PoppinsTextView(
          value: "Pantau aktivitas pengguna untuk audit keamanan.",
          size: 12, // Standar isi 12
          color: Colors.grey,
        ),
        const SizedBox(height: 24),

        // --- FILTER BAR & REFRESH (RESPONSIF) ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: LayoutBuilder(builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 700;

            // 1. Widget Filter Role
            Widget filterRole = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list_rounded,
                    color: AppColors.blueDark, size: 18),
                const SizedBox(width: 8),
                PoppinsTextView(
                    value: "Role:",
                    size: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F7FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedLogRole.value,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Colors.grey, size: 18),
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: Colors.black87),
                            items: ["Semua", "Admin", "Dokter", "Radiolog"]
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) =>
                                controller.filterLogByRole(val!),
                          ),
                        ),
                      )),
                ),
              ],
            );

            // 2. Widget Filter Kalender
            Widget filterDate = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: AppColors.blueDark, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() {
                    bool isDateSelected =
                        controller.selectedDateRange.value != null;
                    return InkWell(
                      onTap: () => controller.pickDateRange(context),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.only(left: 14, right: 10),
                        decoration: BoxDecoration(
                          color: isDateSelected
                              ? AppColors.blueDark.withValues(alpha: 0.1)
                              : const Color(0xffF5F7FA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isDateSelected
                                  ? AppColors.blueDark
                                  : Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isDateSelected
                                  ? "${DateFormat('dd/MM').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd/MM').format(controller.selectedDateRange.value!.end)}"
                                  : "Pilih Tanggal",
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                color: isDateSelected
                                    ? AppColors.blueDark
                                    : Colors.grey.shade700,
                                fontWeight: isDateSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (isDateSelected)
                              InkWell(
                                onTap: () => controller.clearDateFilter(),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.red),
                              )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );

            // 3. Widget Tombol Refresh
            Widget btnRefresh = SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => controller.fetchLogs(),
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 16),
                label: const PoppinsTextView(
                    value: "Refresh",
                    size: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            );

            // Responsive Logic
            if (isMobile) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  filterRole,
                  const SizedBox(height: 12),
                  filterDate,
                  const SizedBox(height: 12),
                  btnRefresh,
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(flex: 3, child: filterRole),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: filterDate,
                    ),
                  ),
                  const SizedBox(width: 16),
                  btnRefresh,
                ],
              );
            }
          }),
        ),
        const SizedBox(height: 20),

        // --- TABEL DATA LOG (RESPONSIF) ---
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              double minTableWidth = 900;
              double tableWidth = constraints.maxWidth > minTableWidth
                  ? constraints.maxWidth
                  : minTableWidth;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // HEADER TABEL
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: const BoxDecoration(
                                color: Color(0xffF9FAFB),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                border: Border(
                                    bottom:
                                        BorderSide(color: Color(0xffEEEEEE))),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "WAKTU",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "USER",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "ROLE",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 3,
                                      child: PoppinsTextView(
                                          value: "AKTIFITAS",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 4,
                                      child: PoppinsTextView(
                                          value: "DETAIL",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                ],
                              ),
                            ),

                            // ISI TABEL
                            Expanded(
                              child: Obx(() {
                                if (controller.isLoading.value) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (controller.filteredLogList.isEmpty) {
                                  return const Center(
                                    child: PoppinsTextView(
                                        value: "Belum ada riwayat aktivitas.",
                                        size: 12,
                                        color: Colors.grey),
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: controller.filteredLogList.length,
                                  separatorBuilder: (c, i) => const Divider(
                                      height: 1, color: Color(0xffEEEEEE)),
                                  itemBuilder: (context, index) {
                                    final log =
                                        controller.filteredLogList[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      color: Colors.white,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start, // Agar sejajar atas jika detailnya panjang
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: PoppinsTextView(
                                                  value: _formatDate(
                                                      log.timestamp),
                                                  size: 12,
                                                  color: Colors.grey)),
                                          Expanded(
                                              flex: 2,
                                              child: PoppinsTextView(
                                                  value: log.username,
                                                  size: 12,
                                                  fontWeight: FontWeight.w600)),
                                          Expanded(
                                              flex: 2,
                                              child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: _roleBadge(log.role))),
                                          Expanded(
                                              flex: 3,
                                              child: PoppinsTextView(
                                                  value: log.activity,
                                                  size: 12,
                                                  color: AppColors.blueDark,
                                                  fontWeight: FontWeight.w600)),
                                          Expanded(
                                              flex: 4,
                                              child: PoppinsTextView(
                                                  value: log.details,
                                                  size: 12,
                                                  color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  // --- HELPER FORMAT TANGGAL ---
  String _formatDate(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy\nHH:mm').format(dt);
    } catch (e) {
      return isoString;
    }
  }

  // --- HELPER ROLE BADGE ---
  Widget _roleBadge(String role) {
    Color bg;
    Color text;
    String r = role.toLowerCase();

    if (r == 'admin') {
      bg = Colors.purple.withValues(alpha: 0.1);
      text = Colors.purple;
    } else if (r == 'dokter') {
      bg = Colors.blue.withValues(alpha: 0.1);
      text = Colors.blue;
    } else if (r == 'radiolog') {
      bg = Colors.orange.withValues(alpha: 0.1);
      text = Colors.orange;
    } else {
      bg = Colors.grey.withValues(alpha: 0.1);
      text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: PoppinsTextView(
        value: role.toUpperCase(),
        size: 10,
        fontWeight: FontWeight.bold,
        color: text,
      ),
    );
  }
}
