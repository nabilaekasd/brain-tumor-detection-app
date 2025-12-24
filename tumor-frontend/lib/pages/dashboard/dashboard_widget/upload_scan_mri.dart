import 'dart:ui' as ui;
import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/models/data_pasien_model.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';

class UploadScanMri extends StatefulWidget {
  const UploadScanMri({
    super.key,
    required this.dashboardController,
    required this.pasienData,
    required this.onBack,
  });

  final DashboardController dashboardController;
  final DataPasienModel pasienData;
  final VoidCallback onBack;

  @override
  State<UploadScanMri> createState() => _UploadScanMriState();
}

class _UploadScanMriState extends State<UploadScanMri> {
  PlatformFile? pickedFile;
  String selectedMriType = 'T1 Weighted';
  bool isHovering = false;

  TextEditingController catatanController = TextEditingController();

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'dcm', 'nii', 'gz'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadToBackend() async {
    if (pickedFile == null) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    // Pastikan alamat IP Backend benar
    var uri = Uri.parse('http://127.0.0.1:8000/upload-mri/');

    var request = http.MultipartRequest('POST', uri);

    request.fields['nama'] = widget.pasienData.namePatient;
    request.fields['id_pasien'] = widget.pasienData.idPatient;
    request.fields['tgl_lahir'] = widget.pasienData.tanggalLahir;
    request.fields['status'] = widget.pasienData.status;
    request.fields['jenis_mri'] = selectedMriType;
    request.fields['catatan'] = catatanController.text;

    if (pickedFile!.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          pickedFile!.bytes!,
          filename: pickedFile!.name,
        ),
      );
    }
    try {
      var response = await request.send();
      Get.back(); // Tutup Loading

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        Get.snackbar("Gagal", "Server menolak: ${response.statusCode}");
      }
    } catch (e) {
      Get.back(); // Tutup Loading
      Get.snackbar("Error Koneksi", "Pastikan Backend sudah nyala!\nError: $e");
    }
  }

  // LOGIKA POPUP
  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 80,
              ),
              const SizedBox(height: 20),
              PoppinsTextView(
                value: "Berhasil Dikirim",
                fontWeight: FontWeight.bold,
                size: 22,
                color: AppColors.blueDark,
              ),
              const SizedBox(height: 10),
              PoppinsTextView(
                value:
                    "File MRI sedang dalam antrean analisis AI.\nAnda akan menerima notifikasi saat hasil siap.",
                textAlign: TextAlign.center,
                size: 14,
                color: AppColors.grey,
                height: 1.5,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    widget.dashboardController.backToPasienList();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: PoppinsTextView(
                    value: "Selesai",
                    fontWeight: FontWeight.w600,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _handleBackNavigation() {
    if (pickedFile != null) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 20),
                PoppinsTextView(
                  value: "Batalkan Upload?",
                  fontWeight: FontWeight.bold,
                  size: 22,
                  color: Colors.black87,
                ),
                const SizedBox(height: 10),
                PoppinsTextView(
                  value:
                      "Anda memiliki file yang belum dikirim.\nJika kembali sekarang, data ini akan hilang.",
                  textAlign: TextAlign.center,
                  size: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.greyDisabled),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: PoppinsTextView(
                          value: "Lanjutkan Edit",
                          color: AppColors.grey,
                          fontWeight: FontWeight.w600,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          widget.onBack();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: PoppinsTextView(
                          value: "Ya, Batalkan",
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } else {
      widget.onBack();
    }
  }

  Widget _buildMiniInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PoppinsTextView(value: label, color: AppColors.grey, size: 12),
        PoppinsTextView(value: value, fontWeight: FontWeight.w600, size: 13),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: PoppinsTextView(
        value: status,
        size: 11,
        fontWeight: FontWeight.bold,
        color: isActive ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: _handleBackNavigation,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: AppColors.grey,
                ),
              ),
            ),
            SpaceSizer(horizontal: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PoppinsTextView(
                  value: 'Upload Scan MRI',
                  size: SizeConfig.safeBlockHorizontal * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueDark,
                ),
                PoppinsTextView(
                  value: 'Pastikan file dalam format DICOM atau High-Res JPG',
                  size: SizeConfig.safeBlockHorizontal * 0.8,
                  color: AppColors.grey,
                ),
              ],
            ),
          ],
        ),
        SpaceSizer(vertical: 3),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(SizeConfig.horizontal(1.5)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyDisabled),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: AppColors.blueDark,
                              size: 40,
                            ),
                            SpaceSizer(horizontal: 1),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PoppinsTextView(
                                  value: widget.pasienData.namePatient,
                                  fontWeight: FontWeight.bold,
                                  size: SizeConfig.safeBlockHorizontal * 0.9,
                                ),
                                PoppinsTextView(
                                  value: 'ID: ${widget.pasienData.idPatient}',
                                  color: AppColors.grey,
                                  size: SizeConfig.safeBlockHorizontal * 0.75,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          height: SizeConfig.vertical(3),
                          color: AppColors.greyDisabled,
                        ),
                        _buildMiniInfo(
                          'Tanggal Lahir',
                          widget.pasienData.tanggalLahir,
                        ),
                        SpaceSizer(vertical: 1.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PoppinsTextView(
                              value: 'Status Pasien',
                              color: AppColors.grey,
                              size: 12,
                            ),
                            _buildStatusBadge(widget.pasienData.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SpaceSizer(vertical: 2),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(SizeConfig.horizontal(1.5)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyDisabled),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PoppinsTextView(
                          value: 'Detail Pemeriksaan',
                          fontWeight: FontWeight.w600,
                          size: SizeConfig.safeBlockHorizontal * 0.9,
                        ),
                        SpaceSizer(vertical: 2),

                        PoppinsTextView(
                          value: 'Jenis Sequence',
                          size: 12,
                          color: AppColors.grey,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.greyDisabled),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedMriType,
                              isExpanded: true,
                              items:
                                  [
                                        'T1 Weighted',
                                        'T2 Weighted',
                                        'FLAIR',
                                        'Disfussion',
                                      ]
                                      .map(
                                        (String value) => DropdownMenuItem(
                                          value: value,
                                          child: PoppinsTextView(
                                            value: value,
                                            size: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedMriType = v!),
                            ),
                          ),
                        ),
                        SpaceSizer(vertical: 2),

                        PoppinsTextView(
                          value: 'Catatan Teknis (Opsional)',
                          size: 12,
                          color: AppColors.grey,
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: catatanController,
                          decoration: InputDecoration(
                            hintText: 'Misal: Pasien bergerak, Kontras 5ml...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: AppColors.greySecond.withValues(
                              alpha: 0.05,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          maxLines: 3,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SpaceSizer(horizontal: 3),

            Expanded(
              flex: 6,
              child: Column(
                children: [
                  InkWell(
                    onTap: _pickFile,
                    onHover: (val) => setState(() => isHovering = val),
                    child: CustomPaint(
                      painter: DottedBorderPainter(
                        color: isHovering ? AppColors.blueDark : AppColors.grey,
                      ),
                      child: Container(
                        width: double.infinity,
                        height: SizeConfig.safeBlockVertical * 55,
                        decoration: BoxDecoration(
                          color: isHovering
                              ? AppColors.blueCard.withValues(alpha: 0.05)
                              : AppColors.greySecond.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: pickedFile == null
                            ? _buildEmptyState()
                            : _buildSelectedState(),
                      ),
                    ),
                  ),
                  SpaceSizer(vertical: 3),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomFlatButton(
                        text: 'Batalkan',
                        onTap: _handleBackNavigation,
                        width: SizeConfig.blockSizeHorizontal * 8,
                        height: SizeConfig.safeBlockVertical * 6.0,
                        backgroundColor: Colors.white,
                        borderColor: AppColors.grey,
                        textColor: AppColors.grey,
                        radius: 0.8,
                        textSize: SizeConfig.safeBlockHorizontal * 0.75,
                      ),
                      SpaceSizer(horizontal: 2),

                      CustomFlatButton(
                        text: 'Mulai Analisis',
                        onTap: () {
                          if (pickedFile != null) {
                            _uploadToBackend();
                          } else {
                            Get.snackbar(
                              "Belum ada file",
                              "Harap pilih file MRI terlebih dahulu!",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              margin: EdgeInsets.all(20),
                            );
                          }
                        },
                        width: SizeConfig.blockSizeHorizontal * 12,
                        height: SizeConfig.safeBlockVertical * 6.0,
                        backgroundColor: pickedFile != null
                            ? AppColors.blueDark
                            : AppColors.greyDisabled,
                        textColor: Colors.white,
                        radius: 0.8,
                        textSize: SizeConfig.safeBlockHorizontal * 0.75,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_rounded,
          size: SizeConfig.safeBlockHorizontal * 4,
          color: AppColors.blueDark,
        ),
        SpaceSizer(vertical: 2),
        PoppinsTextView(
          value: 'Klik untuk Pilih File MRI',
          size: SizeConfig.safeBlockHorizontal * 1.1,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        SpaceSizer(vertical: 1),
        PoppinsTextView(
          value: 'Format: JPG, PNG, JPEG, DICOM, NII, GZ',
          size: SizeConfig.safeBlockHorizontal * 0.8,
          color: AppColors.grey,
        ),
      ],
    );
  }

  Widget _buildSelectedState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.insert_drive_file, size: 60, color: AppColors.blueDark),
        SpaceSizer(vertical: 2),
        PoppinsTextView(
          value: pickedFile!.name,
          size: SizeConfig.safeBlockHorizontal * 1.0,
          fontWeight: FontWeight.bold,
        ),
        PoppinsTextView(
          value:
              '${(pickedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB • Siap Upload',
          size: SizeConfig.safeBlockHorizontal * 0.8,
          color: Colors.green,
        ),
        SpaceSizer(vertical: 2),
        TextButton.icon(
          onPressed: () => setState(() => pickedFile = null),
          icon: Icon(Icons.close, color: Colors.red, size: 18),
          label: PoppinsTextView(
            value: 'Ganti File',
            color: Colors.red,
            size: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class DottedBorderPainter extends CustomPainter {
  final Color color;
  DottedBorderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final double dashWidth = 8, dashSpace = 6, radius = 16;
    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );
    Path dashPath = Path();
    double distance = 0.0;
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
