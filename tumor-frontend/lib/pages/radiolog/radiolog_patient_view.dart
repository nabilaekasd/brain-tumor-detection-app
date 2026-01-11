import 'package:axon_vision/controllers/radiolog_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RadiologPatientView extends GetView<RadiologController> {
  const RadiologPatientView({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic Pindah Wajah (List vs Detail)
    return Obx(() {
      if (controller.isDetailView.value) {
        return _buildDetailAndUploadView();
      } else {
        return _buildPatientListView();
      }
    });
  }

  // --- WAJAH 1: TABEL DAFTAR PASIEN ---
  Widget _buildPatientListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header & Search
        Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Cari Nama Pasien atau ID RM...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (val) {
                    // Tambahkan logic search di controller jika perlu
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchPatients(),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text("Refresh Data",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Tabel Data
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                // Header Tabel
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Text("ID RM",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 3,
                          child: Text("NAMA LENGKAP",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text("JENIS KELAMIN",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 2,
                          child: Text("STATUS",
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                          flex: 1,
                          child: Center(
                              child: Text("AKSI",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)))),
                    ],
                  ),
                ),
                // Isi Tabel
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value)
                      return const Center(child: CircularProgressIndicator());
                    if (controller.allPatientList.isEmpty)
                      return const Center(
                          child: Text("Belum ada data pasien."));

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.allPatientList.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = controller.allPatientList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(p.idPasienRs,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blueDark))),
                              Expanded(flex: 3, child: Text(p.nama)),
                              Expanded(flex: 2, child: Text(p.jenisKelamin)),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: p.statusPasien == 'Aktif'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.statusPasien,
                                    style: TextStyle(
                                        color: p.statusPasien == 'Aktif'
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(
                                        Icons.remove_red_eye_rounded,
                                        color: Colors.blue),
                                    tooltip: "Lihat Detail & Upload",
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WAJAH 2: DETAIL PASIEN & FORM UPLOAD ---
  Widget _buildDetailAndUploadView() {
    final p = controller.selectedPatient.value!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tombol Kembali
          TextButton.icon(
            onPressed: () => controller.backToPatientList(),
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            label: const Text("Kembali ke Daftar Pasien",
                style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 10),

          // 1. INFO PASIEN (HEADER)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border(left: BorderSide(color: AppColors.blueDark, width: 6)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade50,
                  child: Text(p.nama[0],
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blueDark)),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.nama,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        "ID Rekam Medis: ${p.idPasienRs}  •  ${p.jenisKelamin}  •  ${p.tanggalLahir}",
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. KOLOM KIRI: FORM UPLOAD
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Upload Scan MRI Baru",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.blueDark)),
                      const SizedBox(height: 20),

                      // Dropdown Jenis MRI
                      const Text("Jenis MRI",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.selectedJenisMRI.value,
                                isExpanded: true,
                                items: [
                                  "T1 Weighted",
                                  "T2 Weighted",
                                  "FLAIR",
                                  "Diffusion Weighted"
                                ]
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) =>
                                    controller.selectedJenisMRI.value = val!,
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),

                      // Catatan Teknis
                      const Text("Catatan Klinis (Opsional)",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: controller.catatanC,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              "Contoh: Pasien mengeluh pusing di bagian frontal...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Area Upload File
                      InkWell(
                        onTap: () => controller.pickMRIFile(),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.blue.shade200,
                                style: BorderStyle.solid),
                          ),
                          child: Obx(() => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    controller.selectedFile.value == null
                                        ? Icons.cloud_upload_rounded
                                        : Icons.check_circle,
                                    size: 40,
                                    color: controller.selectedFile.value == null
                                        ? Colors.blue
                                        : Colors.green,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    controller.selectedFile.value == null
                                        ? "Klik untuk Pilih File MRI (JPG/PNG)"
                                        : controller.selectedFileName.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          controller.selectedFile.value == null
                                              ? Colors.blue
                                              : Colors.green,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Analisa
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.uploadAndAnalyze(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueDark,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text("Mulai Analisa AI",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            )),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // 3. KOLOM KANAN: RIWAYAT SCAN (Timeline)
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Riwayat Pemeriksaan",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      const SizedBox(height: 20),
                      Obx(() {
                        final history = controller.selectedPatientHistory;
                        if (history.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                  "Belum ada riwayat scan untuk pasien ini.",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: history.length,
                          separatorBuilder: (c, i) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final scan = history[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade200),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.document_scanner,
                                        color: Colors.blue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(scan['jenis_mri'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        Text(scan['tanggal_periksa'],
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: scan['hasil_prediksi']
                                              .toString()
                                              .contains("Tumor")
                                          ? Colors.red.withOpacity(0.1)
                                          : Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      scan['hasil_prediksi'],
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: scan['hasil_prediksi']
                                                .toString()
                                                .contains("Tumor")
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
