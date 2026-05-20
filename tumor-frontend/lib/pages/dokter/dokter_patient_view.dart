import 'package:axon_vision/controllers/dokter_controller.dart'; // DIUBAH
import 'package:axon_vision/pages/detail_analisis_page.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DokterPatientView extends GetView<DokterController> {
  // DIUBAH
  const DokterPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.patientViewStep.value == 0) {
        controller.fetchPatients();
      }
    });

    // BUNGKUS DENGAN LAYOUT BUILDER UNTUK RESPONSIVITAS TOTAL
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 650;

        return Obx(() {
          // STEP DISESUAIKAN: HANYA 3 STEP UNTUK DOKTER
          switch (controller.patientViewStep.value) {
            case 0:
              return _buildPatientListView(context, isMobile);
            case 1:
              return _buildPatientDetailView(isMobile);
            case 2:
              return DetailAnalisisPage(
                analysisId: controller.selectedAnalysisId.value,
                role: "DOKTER", // DIUBAH MENJADI DOKTER
              );
            default:
              return _buildPatientListView(context, isMobile);
          }
        });
      },
    );
  }

  // --- 1. HALAMAN DAFTAR PASIEN ---
  Widget _buildPatientListView(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PoppinsTextView(
          value:
              "Pilih pasien untuk melihat detail atau riwayat analisis AI.", // TEKS DIUBAH
          size: 12,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),

        // Search Bar & Refresh
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    onChanged: (val) => controller.searchPatient(val),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey, size: 18),
                      hintText: "Cari Nama atau ID Pasien...",
                      filled: true,
                      fillColor: const Color(0xffF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => controller.fetchPatients(),
                icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                label: const PoppinsTextView(
                  value: "Refresh",
                  size: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueDark,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tabel Data
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
                // Header Tabel
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
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: _headerTabel("ID REKAM MEDIS")),
                      Expanded(flex: 3, child: _headerTabel("NAMA PASIEN")),
                      if (!isMobile)
                        Expanded(flex: 2, child: _headerTabel("GENDER")),
                      if (!isMobile)
                        Expanded(flex: 2, child: _headerTabel("TGL LAHIR")),
                      Expanded(flex: 2, child: _headerTabel("STATUS")),
                      Expanded(
                          flex: 1, child: Center(child: _headerTabel("AKSI"))),
                    ],
                  ),
                ),

                // Isi Tabel
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.filteredPatientList.isEmpty) {
                      return const Center(
                          child: PoppinsTextView(
                              value: "Data tidak ditemukan",
                              size: 12,
                              color: Colors.grey));
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.currentPatients.length,
                      separatorBuilder: (c, i) =>
                          const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final p = controller.currentPatients[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: PoppinsTextView(
                                      value: p.idPasienRs,
                                      size: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blueDark)),
                              Expanded(
                                  flex: 3,
                                  child: PoppinsTextView(
                                      value: p.nama,
                                      size: 12,
                                      fontWeight: FontWeight.w600)),
                              if (!isMobile)
                                Expanded(
                                    flex: 2,
                                    child: PoppinsTextView(
                                        value: p.jenisKelamin,
                                        size: 12,
                                        color: Colors.black87)),
                              if (!isMobile)
                                Expanded(
                                    flex: 2,
                                    child: PoppinsTextView(
                                        value: p.tanggalLahir,
                                        size: 12,
                                        color: Colors.grey)),
                              Expanded(
                                  flex: 2,
                                  child: _buildStatusBadge(p.statusPasien,
                                      alignLeft: true)),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.description_outlined,
                                        color: Colors.blue, size: 18),
                                    tooltip: "Lihat Detail", // TOOLTIP DIUBAH
                                    onPressed: () =>
                                        controller.openPatientDetail(p),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),

                // Pagination
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xffF9FAFB),
                    border: Border(
                        top: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.1))),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => PoppinsTextView(
                            value:
                                "Halaman ${controller.patientCurrentPage} dari ${controller.totalPatientPages} (Total ${controller.filteredPatientList.length})",
                            size: 11,
                            color: Colors.grey,
                          )),
                      Row(
                        children: [
                          IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              onPressed: () => controller.prevPatientPage(),
                              icon: const Icon(Icons.chevron_left,
                                  size: 18, color: Colors.grey)),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: AppColors.blueDark,
                                shape: BoxShape.circle),
                            child: Obx(() => PoppinsTextView(
                                value: "${controller.patientCurrentPage}",
                                size: 11,
                                color: Colors.white)),
                          ),
                          IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              onPressed: () => controller.nextPatientPage(),
                              icon: const Icon(Icons.chevron_right,
                                  size: 18, color: Colors.grey))
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. HALAMAN DETAIL PASIEN (TANPA UPLOAD) ---
  Widget _buildPatientDetailView(bool isMobile) {
    final p = controller.selectedPatient.value!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => controller.backToPreviousStep(),
            icon: const Icon(Icons.arrow_back, color: Colors.grey, size: 16),
            label: const PoppinsTextView(
                value: "Kembali ke Daftar Pasien",
                size: 12,
                color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // KARTU DETAIL PASIEN
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border(left: BorderSide(color: AppColors.blueDark, width: 5)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PoppinsTextView(
                        value: "Detail Pasien",
                        size: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blueDark),
                    _buildStatusBadge(p.statusPasien),
                  ],
                ),
                const SizedBox(height: 16),

                // RESPONSIF: Baris (PC) atau Bertumpuk (Mobile)
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.blue.shade50,
                        child: PoppinsTextView(
                          value: p.nama[0],
                          size: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _detailRow("Nama Lengkap", p.nama),
                      const SizedBox(height: 8),
                      _detailRow("ID Rekam Medis", p.idPasienRs),
                      const SizedBox(height: 8),
                      _detailRow("Jenis Kelamin", p.jenisKelamin),
                      const SizedBox(height: 8),
                      _detailRow("Tanggal Lahir", p.tanggalLahir),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade50,
                        child: PoppinsTextView(
                            value: p.nama[0],
                            size: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blueDark),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _detailRow("Nama Lengkap", p.nama),
                            const SizedBox(height: 8),
                            _detailRow("ID Rekam Medis", p.idPasienRs),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            _detailRow("Jenis Kelamin", p.jenisKelamin),
                            const SizedBox(height: 8),
                            _detailRow("Tanggal lahir", p.tanggalLahir),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // TOMBOL UPLOAD DIHAPUS DARI SINI UNTUK DOKTER
          const SizedBox(height: 24),

          // BAGIAN RIWAYAT SCAN MRI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const PoppinsTextView(
                value: "Riwayat Analisis MRI", // TEKS DIUBAH
                size: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              Row(children: [
                Obx(() {
                  bool isFiltered = controller.selectedDateFilter.value != null;

                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFiltered
                          ? Icons.event_busy
                          : Icons.calendar_month_outlined,
                      color: isFiltered ? Colors.redAccent : Colors.grey,
                      size: 20,
                    ),
                    tooltip: isFiltered
                        ? "Hapus Filter Tanggal"
                        : "Filter berdasarkan Tanggal",
                    onPressed: () async {
                      if (isFiltered) {
                        controller.clearDateFilter();
                      } else {
                        DateTime? pickedDate = await showDatePicker(
                          context: Get.context!,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.blueDark,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black87,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );

                        if (pickedDate != null) {
                          controller.filterHistoryByDate(pickedDate);
                        }
                      }
                    },
                  );
                }),
                const SizedBox(width: 12),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.isSortNewest.value
                              ? 'Terbaru'
                              : 'Terlama',
                          icon: const Icon(Icons.sort,
                              size: 14, color: Colors.grey),
                          items: ['Terbaru', 'Terlama'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: PoppinsTextView(
                                value: value,
                                size: 11,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              controller.sortHistory(newValue);
                            }
                          },
                        ),
                      ),
                    )),
              ])
            ],
          ),
          const SizedBox(height: 12),

          Obx(() {
            final history = controller.sortedPatientHistory;
            if (history.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200)),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off,
                          size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      PoppinsTextView(
                          value: "Belum ada riwayat scan MRI",
                          size: 12,
                          color: Colors.grey.shade600),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (c, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final scan = history[index];
                String hasil = scan['hasil_prediksi'].toString().toLowerCase();

                bool isNormal = hasil.contains("non") ||
                    hasil.contains("normal") ||
                    hasil.contains("aman");

                Color badgeColor = isNormal
                    ? const Color(0xFF5AB678)
                    : const Color(0xFFFA5A5A);
                Color iconColor = isNormal
                    ? const Color(0xFF5AB678)
                    : const Color(0xFFFA5A5A);
                Color iconBgColor = isNormal
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEEEE);

                return InkWell(
                  onTap: () =>
                      controller.openAnalysisResult(scan['id'].toString()),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.document_scanner_outlined,
                              color: iconColor, size: 18),
                        ),
                        const SizedBox(width: 12),

                        // Info Tengah
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PoppinsTextView(
                                value: scan['jenis_mri'] ?? "MRI Scan",
                                fontWeight: FontWeight.bold,
                                size: 13,
                                color: Colors.black87,
                              ),
                              const SizedBox(height: 2),
                              PoppinsTextView(
                                value: "Tanggal: ${scan['tanggal_periksa']}",
                                size: 11,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),

                        // Badge Prediksi Kanan
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PoppinsTextView(
                              value: "Hasil Prediksi",
                              size: 9,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: PoppinsTextView(
                                value: scan['hasil_prediksi'],
                                color: Colors.white,
                                size: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _headerTabel(String title) {
    return PoppinsTextView(
        value: title,
        size: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey);
  }

  Widget _buildStatusBadge(String status, {bool alignLeft = false}) {
    bool isActive = status.toLowerCase() == "aktif";
    return Align(
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: PoppinsTextView(
          value: isActive ? "AKTIF" : "NONAKTIF",
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          size: 10,
        ),
      ),
    );
  }

  // FLEX diimplementasi agar label dan isian teks tidak overflow di HP
  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: PoppinsTextView(value: label, size: 12, color: Colors.grey)),
        const PoppinsTextView(value: ": ", size: 12, color: Colors.grey),
        Expanded(
            flex: 3,
            child: PoppinsTextView(
                value: value,
                size: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87)),
      ],
    );
  }
}
