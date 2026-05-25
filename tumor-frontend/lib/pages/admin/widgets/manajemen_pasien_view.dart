import 'package:axon_vision/controllers/admin_controller.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
        const PoppinsTextView(
          value: "Tambah, Edit, atau Nonaktifkan data pasien.",
          size: 12,
          color: Colors.grey,
        ),
        const SizedBox(height: 24),

        // --- SEARCH BAR & TOMBOL ---
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 700;

              Widget searchBar = SizedBox(
                height: 38,
                child: TextField(
                  onChanged: (val) => controller.searchPatient(val),
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12),
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.grey, size: 18),
                    hintText: "Cari Nama atau ID Pasien...",
                    hintStyle:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xffF5F7FA),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );

              Widget refreshButton = SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () => controller.fetchPatients(),
                  icon:
                      const Icon(Icons.refresh, color: Colors.white, size: 16),
                  label: const PoppinsTextView(
                    value: "Refresh",
                    size: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              );

              Widget addButton = SizedBox(
                height: 38,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.clearPatientForm();
                    _showDialog(context, isEdit: false);
                  },
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 18),
                  label: const PoppinsTextView(
                    value: "Tambah Pasien",
                    size: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueDark,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              );

              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    searchBar,
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: refreshButton),
                        const SizedBox(width: 8),
                        Expanded(child: addButton),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(child: searchBar),
                    const SizedBox(width: 12),
                    refreshButton,
                    const SizedBox(width: 8),
                    addButton,
                  ],
                );
              }
            },
          ),
        ),
        const SizedBox(height: 20),

        // --- TABEL DATA (RESPONSIF) ---
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
                                          value: "ID RM",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 3,
                                      child: PoppinsTextView(
                                          value: "NAMA PASIEN",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "GENDER",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "TGL LAHIR",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 2,
                                      child: PoppinsTextView(
                                          value: "STATUS",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Expanded(
                                      flex: 1,
                                      child: PoppinsTextView(
                                          value: "AKSI",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          textAlign: TextAlign.center)),
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
                                if (controller.filteredPatientList.isEmpty) {
                                  return const Center(
                                    child: PoppinsTextView(
                                        value: "Data tidak ditemukan",
                                        size: 12,
                                        color: Colors.grey),
                                  );
                                }
                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      controller.filteredPatientList.length,
                                  separatorBuilder: (c, i) => const Divider(
                                      height: 1, color: Color(0xffEEEEEE)),
                                  itemBuilder: (context, index) {
                                    final p =
                                        controller.filteredPatientList[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      color: Colors.white,
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
                                          Expanded(
                                              flex: 2,
                                              child: PoppinsTextView(
                                                  value: p.jenisKelamin,
                                                  size: 12)),
                                          Expanded(
                                              flex: 2,
                                              child: PoppinsTextView(
                                                  value: p.tanggalLahir,
                                                  size: 12,
                                                  color: Colors.grey)),
                                          Expanded(
                                              flex: 2,
                                              child: _buildStatusBadge(
                                                  p.statusPasien)),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  constraints:
                                                      const BoxConstraints(),
                                                  padding: EdgeInsets.zero,
                                                  icon: const Icon(
                                                      Icons.edit_rounded,
                                                      color: Colors.blue,
                                                      size: 18),
                                                  onPressed: () {
                                                    controller
                                                        .fillPatientForm(p);
                                                    _showDialog(context,
                                                        isEdit: true, id: p.id);
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
                          ],
                        ),
                      ),
                    ),
                  ),

                  // PAGINATION FOOTER
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                              size: 12,
                              color: Colors.grey,
                            )),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => controller.prevPatientPage(),
                              icon: const Icon(Icons.chevron_left,
                                  size: 20, color: Colors.grey),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: AppColors.blueDark,
                                  shape: BoxShape.circle),
                              child: Obx(() => PoppinsTextView(
                                    value: "${controller.patientCurrentPage}",
                                    color: Colors.white,
                                    size: 12,
                                  )),
                            ),
                            IconButton(
                              onPressed: () => controller.nextPatientPage(),
                              icon: const Icon(Icons.chevron_right,
                                  size: 20, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
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

  // --- HELPER STATUS BADGE ---
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

  // --- DIALOG FORM PASIEN ---
  void _showDialog(BuildContext context, {required bool isEdit, int? id}) {
    if (!isEdit) {
      // Auto-Generate ID Pasien Baru
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      controller.idRmC.text = "RM-${timestamp.substring(timestamp.length - 6)}";
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PoppinsTextView(
                      value: isEdit ? "Edit Data Pasien" : "Tambah Pasien Baru",
                      size: 14,
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

                // Input ID RM (Otomatis & Terkunci)
                _inputField("ID Rekam Medis (RM)", controller.idRmC,
                    readOnly: true, hint: "Terisi otomatis"),
                const SizedBox(height: 16),

                // Input Nama
                _inputField("Nama Lengkap Pasien", controller.namaPasienC,
                    hint: "Masukkan nama lengkap"),
                const SizedBox(height: 16),

                // Input Tanggal Lahir (Menggunakan Kalender Premium)
                _datePickerField(context),
                const SizedBox(height: 16),

                // ROLE & STATUS (KINI MENGGUNAKAN SWITCH UNTUK STATUS)
                Row(
                  children: [
                    Expanded(
                      child: Column(
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
                                    icon: const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.grey,
                                        size: 18),
                                    items: ["Laki-laki", "Perempuan"]
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: PoppinsTextView(
                                          value: value,
                                          size: 12,
                                          color: Colors.black87,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.jenisKelaminPasien.value =
                                            val;
                                      }
                                    },
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),

                    // 👇 PERUBAHAN DI SINI: STATUS MENGGUNAKAN SWITCH KONSISTEN DENGAN USER
                    if (isEdit) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PoppinsTextView(
                              value: "Status Pasien",
                              size: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blueDark,
                            ),
                            SizedBox(
                              height: 40,
                              child: Obx(
                                () => SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    controller.statusPasien.value == "Aktif"
                                        ? "Aktif"
                                        : "Nonaktif",
                                    style: const TextStyle(
                                        fontSize: 12, fontFamily: 'Poppins'),
                                  ),
                                  value:
                                      controller.statusPasien.value == "Aktif",
                                  activeColor: AppColors.blueDark,
                                  onChanged: (val) => controller.statusPasien
                                      .value = val ? "Aktif" : "Tidak Aktif",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => isEdit
                        ? controller.updatePatient(id!)
                        : controller.addPatient(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: PoppinsTextView(
                      value: isEdit ? "Simpan Perubahan" : "Simpan Data",
                      size: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER INPUT TEXT ---
  Widget _inputField(String label, TextEditingController c,
      {bool readOnly = false, String? hint}) {
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
            readOnly: readOnly,
            style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              filled: readOnly,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
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

  // --- HELPER DATE PICKER ---
  Widget _datePickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: "Tanggal Lahir",
          size: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.blueDark,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller.tglLahirC,
            readOnly: true, // Wajib agar tidak bisa diketik asal
            onTap: () async {
              var config = CalendarDatePicker2WithActionButtonsConfig(
                calendarType: CalendarDatePicker2Type.single,
                selectedDayHighlightColor: const Color(0xff2C3E50),
                yearTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                dayTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                weekdayLabelTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.grey),
                controlsTextStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 15),
                okButton: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: PoppinsTextView(
                      value: "APPLY",
                      color: Color(0xff2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                cancelButton: const PoppinsTextView(
                    value: "CANCEL",
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                centerAlignModePicker: true,
              );

              var results = await showCalendarDatePicker2Dialog(
                context: context,
                config: config,
                dialogSize: const Size(375, 400),
                value: [DateTime.now()],
                borderRadius: BorderRadius.circular(16),
              );

              // Jika user memilih tanggal dan menekan APPLY
              if (results != null && results.isNotEmpty && results[0] != null) {
                DateTime picked = results[0]!;
                String day = picked.day.toString().padLeft(2, '0');
                String month = picked.month.toString().padLeft(2, '0');
                String year = picked.year.toString();

                controller.tglLahirC.text = "$day/$month/$year";
              }
            },
            style: const TextStyle(fontSize: 12, fontFamily: 'Poppins'),
            decoration: InputDecoration(
              hintText: "Pilih tanggal dari kalender...",
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(Icons.calendar_month_rounded,
                  color: Colors.grey, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
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
