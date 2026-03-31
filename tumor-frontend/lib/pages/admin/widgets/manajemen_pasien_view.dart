import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManajemenPasienView extends GetView<AdminController> {
  const ManajemenPasienView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPatients();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        PoppinsTextView(
          value: "Manajemen Data Pasien",
          size: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 8),
        const PoppinsTextView(
          value: "Tambah, Edit, atau Nonaktifkan data pasien.",
          size: 14,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),

        // Search Bar
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
                  height: 40,
                  child: TextField(
                    onChanged: (val) => controller.searchPatient(val),
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 18,
                      ),
                      hintText: "Cari Nama atau ID Pasien...",
                      filled: true,
                      fillColor: const Color(0xffF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  controller.clearPatientForm();
                  _showDialog(context, isEdit: false);
                },
                icon: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: const PoppinsTextView(
                  value: "Tambah Pasien",
                  size: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blueDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xffF9FAFB),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0xffEEEEEE)),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "ID REKAM MEDIS",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: PoppinsTextView(
                          value: "NAMA PASIEN",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "GENDER",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "TGL LAHIR",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PoppinsTextView(
                          value: "STATUS",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: PoppinsTextView(
                          value: "AKSI",
                          size: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                          size: 13,
                          color: Colors.grey,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: controller.filteredPatientList.length,
                      separatorBuilder: (c, i) =>
                          const Divider(height: 1, color: Color(0xffEEEEEE)),
                      itemBuilder: (context, index) {
                        final p = controller.filteredPatientList[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: PoppinsTextView(
                                  value: p.idPasienRs,
                                  size: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blueDark,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: PoppinsTextView(
                                  value: p.nama,
                                  size: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: PoppinsTextView(
                                  value: p.jenisKelamin,
                                  size: 13,
                                  color: Colors.black87,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: PoppinsTextView(
                                  value: p.tanggalLahir,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: _buildStatusBadge(p.statusPasien),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        controller.fillPatientForm(p);
                                        _showDialog(
                                          context,
                                          isEdit: true,
                                          id: p.id,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        Get.defaultDialog(
                                          title: "Nonaktifkan Pasien",
                                          titleStyle: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.blueDark,
                                          ),
                                          middleText:
                                              "Data medis tidak akan dihapus, hanya dinonaktifkan. Lanjutkan?",
                                          middleTextStyle: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                          ),
                                          textConfirm: "Ya, Nonaktifkan",
                                          confirmTextColor: Colors.white,
                                          buttonColor: Colors.redAccent,
                                          textCancel: "Batal",
                                          cancelTextColor: AppColors.blueDark,
                                          onConfirm: () {
                                            controller.fillPatientForm(p);
                                            controller.statusPasien.value =
                                                "Tidak Aktif";
                                            controller.updatePatient(p.id);
                                            Get.back();
                                          },
                                        );
                                      },
                                    ),
                                  ],
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffF9FAFB),
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => PoppinsTextView(
                              value:
                                  "Halaman ${controller.patientCurrentPage} dari ${controller.totalPatientPages} (Total ${controller.filteredPatientList.length})",
                              size: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(children: [
                            IconButton(
                              onPressed: () => controller.prevPatientPage(),
                              icon: const Icon(
                                Icons.chevron_left,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.blueDark,
                                shape: BoxShape.circle,
                              ),
                              child: Obx(
                                () => PoppinsTextView(
                                  value: "${controller.patientCurrentPage}",
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () => controller.nextPatientPage(),
                                icon: const Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: Colors.grey,
                                ))
                          ])
                        ]))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status == "Aktif";
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  void _showDialog(BuildContext context, {required bool isEdit, int? id}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PoppinsTextView(
                    value: isEdit ? "Edit Data Pasien" : "Tambah Pasien Baru",
                    size: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blueDark,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 24),
              _inputField(
                "ID Rekam Medis (RM)",
                controller.idRmC,
                hint: "Contoh: P001",
              ),
              const SizedBox(height: 16),
              _inputField(
                "Nama Lengkap Pasien",
                controller.namaPasienC,
                hint: "Masukkan nama lengkap",
              ),
              const SizedBox(height: 16),
              _inputField(
                "Tanggal Lahir (DD/MM/YYYY)",
                controller.tglLahirC,
                hint: "Contoh: 12/05/1980",
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PoppinsTextView(
                    value: "Jenis Kelamin",
                    size: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blueDark,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.jenisKelaminPasien.value,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.grey),
                            items:
                                ["Laki-laki", "Perempuan"].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: PoppinsTextView(
                                  value: value,
                                  size: 13,
                                  color: Colors.black87,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                controller.jenisKelaminPasien.value = val;
                                debugPrint("Pilih Gender: $val");
                              }
                            },
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PoppinsTextView(
                          value: "Status",
                          size: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blueDark,
                        ),
                        const SizedBox(height: 6),
                        Obx(
                          () => SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              controller.statusPasien.value,
                              style: const TextStyle(fontSize: 12),
                            ),
                            value: controller.statusPasien.value == "Aktif",
                            onChanged: (val) => controller.statusPasien.value =
                                val ? "Aktif" : "Tidak Aktif",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => isEdit
                      ? controller.updatePatient(id!)
                      : controller.addPatient(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: PoppinsTextView(
                    value: isEdit ? "Simpan Perubahan" : "Simpan Data",
                    size: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController c, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: c,
            style: const TextStyle(fontSize: 13, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}
