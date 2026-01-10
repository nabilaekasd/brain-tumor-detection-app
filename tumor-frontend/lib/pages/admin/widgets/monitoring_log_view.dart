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
        PoppinsTextView(
          value: "Monitoring Log Sistem",
          size: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        PoppinsTextView(
          value: "Pantau aktivitas pengguna untuk audit keamanan.",
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.filter_list_rounded,
                  color: AppColors.blueDark, size: 20),
              const SizedBox(width: 10),
              PoppinsTextView(
                value: "Role:",
                size: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.blueDark,
              ),
              const SizedBox(width: 12),

              // Dropdown Filter
              Obx(() => Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedLogRole.value,
                        icon: const Icon(Icons.arrow_drop_down,
                            color: Colors.grey),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                        items: ["Semua", "Admin", "Dokter", "Radiolog"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => controller.filterLogByRole(val!),
                      ),
                    ),
                  )),

              const SizedBox(width: 16),

              Icon(Icons.calendar_today_rounded,
                  color: AppColors.blueDark, size: 18),
              const SizedBox(width: 8),
              Obx(() {
                bool isDateSelected =
                    controller.selectedDateRange.value != null;
                return InkWell(
                  onTap: () => controller.pickDateRange(context),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      children: [
                        Text(
                          isDateSelected
                              ? "${DateFormat('dd/MM').format(controller.selectedDateRange.value!.start)} - ${DateFormat('dd/MM').format(controller.selectedDateRange.value!.end)}"
                              : "Pilih Tanggal",
                          style: TextStyle(
                              fontSize: 13,
                              color: isDateSelected
                                  ? AppColors.blueDark
                                  : Colors.grey.shade700,
                              fontWeight: isDateSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                        if (isDateSelected) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => controller.clearDateFilter(),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.red),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),

              //Tombol Refresh
              IconButton(
                onPressed: () => controller.fetchLogs(),
                icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                tooltip: "Refresh Data",
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //Header Table
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xffF9FAFB),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    border:
                        Border(bottom: BorderSide(color: Color(0xffEEEEEE))),
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
                // Body Table
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.filteredLogList.isEmpty) {
                      return const Center(
                        child: PoppinsTextView(
                            value: "Belum ada riwayat aktivitas.",
                            color: Colors.grey),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.filteredLogList.length,
                      separatorBuilder: (c, i) =>
                          const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final log = controller.filteredLogList[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: PoppinsTextView(
                                      value: _formatDate(log.timestamp),
                                      size: 12,
                                      color: Colors.grey)),
                              Expanded(
                                  flex: 2,
                                  child: PoppinsTextView(
                                    value: log.username,
                                    size: 13,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _roleBadge(log.role),
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: PoppinsTextView(
                                    value: log.activity,
                                    size: 13,
                                    color: AppColors.blueDark,
                                    fontWeight: FontWeight.w500,
                                  )),
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
      ],
    );
  }

  String _formatDate(String isoString) {
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy\nHH:mm').format(dt);
    } catch (e) {
      return isoString;
    }
  }

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
      child: Text(
        role.toUpperCase(),
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }
}
