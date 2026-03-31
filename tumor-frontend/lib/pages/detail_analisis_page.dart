import 'package:axon_vision/controllers/radiolog_controller.dart';
import 'package:axon_vision/controllers/dokter_controller.dart';
import 'package:axon_vision/utils/api_config.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_text_field.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailAnalisisPage extends StatefulWidget {
  final String analysisId;
  final String role;

  const DetailAnalisisPage({
    super.key,
    required this.analysisId,
    required this.role,
  });

  @override
  State<DetailAnalisisPage> createState() => _DetailAnalisisPageState();
}

class _DetailAnalisisPageState extends State<DetailAnalisisPage> {
  dynamic get activeController {
    if (widget.role.toUpperCase() == 'DOKTER') {
      return Get.find<DokterController>();
    } else {
      return Get.find<RadiologController>();
    }
  }

  final TransformationController _transformationController =
      TransformationController();
  final TextEditingController doctorNotesController = TextEditingController();

  String viewMode = '2D';
  int _quarterTurns = 0;
  bool _isInverted = false;

  @override
  void initState() {
    super.initState();
    final currentCtrl = activeController;

    if (currentCtrl.detailAnalysisData.isEmpty ||
        currentCtrl.detailAnalysisData['id'].toString() != widget.analysisId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentCtrl.fetchAnalysisDetail(widget.analysisId);
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    doctorNotesController.dispose();
    super.dispose();
  }

  // --- LOGIKA GAMBAR ---
  void _zoomIn() =>
      _transformationController.value *= Matrix4.diagonal3Values(1.2, 1.2, 1.0);
  void _zoomOut() =>
      _transformationController.value *= Matrix4.diagonal3Values(0.8, 0.8, 1.0);
  void _rotateImage() =>
      setState(() => _quarterTurns = (_quarterTurns + 1) % 4);
  void _toggleContrast() => setState(() => _isInverted = !_isInverted);
  void _resetView() {
    setState(() {
      _transformationController.value = Matrix4.identity();
      _quarterTurns = 0;
      _isInverted = false;
    });
  }

  void _openFullscreen(String imageUrl) {
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: InteractiveViewer(
            transformationController: TransformationController(),
            minScale: 0.1,
            maxScale: 5.0,
            child: _buildImageContent(imageUrl, BoxFit.contain),
          ),
        ),
      ),
      barrierColor: Colors.black,
    );
  }

  Widget _buildImageContent(String url, BoxFit fit) {
    return RotatedBox(
      quarterTurns: _quarterTurns,
      child: _isInverted
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                -1,
                0,
                0,
                0,
                255,
                0,
                -1,
                0,
                0,
                255,
                0,
                0,
                -1,
                0,
                255,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: Image.network(url, fit: fit),
            )
          : Image.network(url, fit: fit),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDokter = widget.role.toUpperCase() == 'DOKTER';
    final currentCtrl = activeController;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (currentCtrl.isLoadingDetail.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = currentCtrl.detailAnalysisData;
                if (data.isEmpty) {
                  return Center(
                      child: PoppinsTextView(
                          value: "Data tidak tersedia", color: AppColors.grey));
                }

                String fullPath = data['image_url'].toString();
                String filename = fullPath.split('/').last;
                String rawUrl = "${ApiConfig.baseUrl}/get-image/$filename";
                String imageUrl = Uri.encodeFull(rawUrl);

                if (data['notes_dokter'] != null &&
                    doctorNotesController.text.isEmpty) {
                  doctorNotesController.text = data['notes_dokter'];
                }

                String resString = data['result'].toString().toLowerCase();
                bool isCancer = (resString.contains("cancer") ||
                        resString.contains("tumor") ||
                        resString.contains("malignant") ||
                        resString.contains("glioma")) &&
                    !resString.contains("non");

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === KIRI: IMAGE VIEWER (60%) ===
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.greyDisabled),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8))
                          ],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          children: [
                            Center(
                              child: viewMode == '2D'
                                  ? InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      minScale: 0.1,
                                      maxScale: 5.0,
                                      child: _buildImageContent(
                                          imageUrl, BoxFit.contain),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.view_in_ar,
                                            size: 60, color: Colors.white24),
                                        const SizedBox(height: 16),
                                        PoppinsTextView(
                                            value:
                                                "Visualisasi 3D Belum Tersedia",
                                            color: Colors.white54,
                                            size: 16)
                                      ],
                                    ),
                            ),
                            // Label Mode
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(6)),
                                child: PoppinsTextView(
                                    value: 'Mode: $viewMode',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    size: 12),
                              ),
                            ),
                            // Fullscreen
                            Positioned(
                              top: 20,
                              right: 20,
                              child: InkWell(
                                onTap: () => _openFullscreen(imageUrl),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(6)),
                                  child: const Icon(Icons.fullscreen,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            // Toolbar
                            Positioned(
                              bottom: 24,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2C)
                                          .withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(50)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildToolIcon(Icons.zoom_in,
                                          onTap: _zoomIn),
                                      const SizedBox(width: 12),
                                      _buildToolIcon(Icons.zoom_out,
                                          onTap: _zoomOut),
                                      const SizedBox(width: 12),
                                      _buildToolIcon(Icons.rotate_right,
                                          onTap: _rotateImage),
                                      const SizedBox(width: 12),
                                      _buildToolIcon(Icons.contrast,
                                          onTap: _toggleContrast),
                                      const SizedBox(width: 12),
                                      _buildToolIcon(Icons.refresh,
                                          onTap: _resetView),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SpaceSizer(horizontal: 2.5),

                    // === KANAN: PANEL INFO (40%) ===
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(right: 4),
                                child: Column(
                                  children: [
                                    // KARTU 1: INFO PASIEN
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                          SizeConfig.horizontal(1.5)),
                                      decoration: _boxDecorationStyle(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle(
                                              'Informasi Pasien'),
                                          SpaceSizer(vertical: 1.5),
                                          _buildInfoRow('Nama Pasien',
                                              data['nama_pasien'] ?? "-",
                                              isBold: true),
                                          _buildInfoRow(
                                              'ID Medis', data['id_rm'] ?? "-"),
                                          _buildInfoRow('Waktu Scan',
                                              data['waktu_scan'] ?? "-"),
                                        ],
                                      ),
                                    ),

                                    SpaceSizer(vertical: 2),

                                    // KARTU 2: PREDIKSI AI
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                          SizeConfig.horizontal(1.5)),
                                      decoration: _boxDecorationStyle(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('Prediksi AI'),
                                          SpaceSizer(vertical: 1.5),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: isCancer
                                                  ? AppColors.redAlert
                                                      .withValues(alpha: 0.1)
                                                  : Colors.green
                                                      .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isCancer
                                                    ? AppColors.redAlert
                                                        .withValues(alpha: 0.3)
                                                    : Colors.green
                                                        .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isCancer
                                                      ? Icons
                                                          .warning_amber_rounded
                                                      : Icons
                                                          .check_circle_outline,
                                                  color: isCancer
                                                      ? AppColors.redAlert
                                                      : Colors.green,
                                                  size: 30,
                                                ),
                                                SpaceSizer(horizontal: 1),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      PoppinsTextView(
                                                        value: isCancer
                                                            ? (data['result'] ??
                                                                "CANCER DETECTED")
                                                            : "NON-CANCER",
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isCancer
                                                            ? AppColors.redAlert
                                                            : Colors.green,
                                                        size: SizeConfig
                                                                .safeBlockHorizontal *
                                                            1.0,
                                                      ),
                                                      PoppinsTextView(
                                                        value:
                                                            'Confidence: ${data['confidence']}%',
                                                        size: SizeConfig
                                                                .safeBlockHorizontal *
                                                            0.8,
                                                        color: AppColors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SpaceSizer(vertical: 1.5),
                                          PoppinsTextView(
                                              value:
                                                  "Catatan Teknis (Radiolog):",
                                              size: SizeConfig
                                                      .safeBlockHorizontal *
                                                  0.8,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.grey),
                                          SpaceSizer(vertical: 0.5),
                                          PoppinsTextView(
                                              value:
                                                  data['notes_radiolog'] ?? "-",
                                              size: SizeConfig
                                                      .safeBlockHorizontal *
                                                  0.9,
                                              color: AppColors.black),
                                        ],
                                      ),
                                    ),

                                    SpaceSizer(vertical: 2),

                                    // KARTU 3: MODE TAMPILAN
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                          SizeConfig.horizontal(1.5)),
                                      decoration: _boxDecorationStyle(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionTitle('Mode Tampilan'),
                                          SpaceSizer(vertical: 1.5),
                                          Row(
                                            children: [
                                              Expanded(
                                                  child: _buildModeButton(
                                                      '2D Slice',
                                                      viewMode == '2D')),
                                              SpaceSizer(horizontal: 1),
                                              Expanded(
                                                  child: _buildModeButton(
                                                      '3D Volume',
                                                      viewMode == '3D')),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    SpaceSizer(vertical: 2),

                                    // KARTU 4: CATATAN DOKTER
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(
                                          SizeConfig.horizontal(1.5)),
                                      decoration: _boxDecorationStyle(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              _buildSectionTitle(
                                                  'Catatan Dokter'),
                                              if (isDokter)
                                                Icon(Icons.edit,
                                                    size: 16,
                                                    color: AppColors.blueDark)
                                              else
                                                Icon(Icons.lock_outline,
                                                    size: 16,
                                                    color: AppColors.grey),
                                            ],
                                          ),
                                          SpaceSizer(vertical: 1.5),
                                          if (isDokter)
                                            CustomTextField(
                                              controller: doctorNotesController,
                                              title: '',
                                              hintText: 'Tulis diagnosis...',
                                              minLines: 4,
                                              maxLines: 6,
                                              borderRadius: 0.5,
                                              fillColor: AppColors.greySecond
                                                  .withValues(alpha: 0.1),
                                            )
                                          else
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  color: AppColors.greySecond
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: AppColors
                                                          .greyDisabled)),
                                              child: PoppinsTextView(
                                                  value: (data['notes_dokter'] ==
                                                              null ||
                                                          data['notes_dokter'] ==
                                                              "")
                                                      ? 'Belum ada catatan dari dokter.'
                                                      : data['notes_dokter'],
                                                  color: AppColors.black
                                                      .withValues(alpha: 0.7),
                                                  size: SizeConfig
                                                          .safeBlockHorizontal *
                                                      0.8),
                                            ),
                                        ],
                                      ),
                                    ),

                                    SpaceSizer(vertical: 2),
                                  ],
                                ),
                              ),
                            ),

                            // TOMBOL AKSI DI BAGIAN BAWAH PANEL
                            SpaceSizer(vertical: 1),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomFlatButton(
                                    text: 'Kembali',
                                    onTap: () =>
                                        currentCtrl.backToPreviousStep(),
                                    height: SizeConfig.safeBlockVertical * 4.5,
                                    backgroundColor: AppColors.greySecond
                                        .withValues(alpha: 0.2),
                                    borderColor: Colors.transparent,
                                    textColor:
                                        AppColors.black.withValues(alpha: 0.7),
                                    radius: 0.8,
                                    textSize:
                                        SizeConfig.safeBlockHorizontal * 0.75,
                                  ),
                                ),
                                if (isDokter) ...[
                                  SpaceSizer(horizontal: 1),
                                  Expanded(
                                    child: CustomFlatButton(
                                      text: 'Simpan',
                                      onTap: () {
                                        String isiCatatan =
                                            doctorNotesController.text;
                                        currentCtrl.saveDoctorNotes(
                                            widget.analysisId, isiCatatan);
                                      },
                                      height:
                                          SizeConfig.safeBlockVertical * 4.5,
                                      backgroundColor: AppColors.blueDark,
                                      textColor: Colors.white,
                                      colorIconImage: Colors.white,
                                      radius: 0.8,
                                      textSize:
                                          SizeConfig.safeBlockHorizontal * 0.75,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---
  BoxDecoration _boxDecorationStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.greyDisabled),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4))
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return PoppinsTextView(
        value: title,
        fontWeight: FontWeight.bold,
        size: SizeConfig.safeBlockHorizontal * 0.95,
        color: AppColors.black);
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PoppinsTextView(
              value: label,
              color: AppColors.grey,
              size: SizeConfig.safeBlockHorizontal * 0.75),
          PoppinsTextView(
              value: value,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              size: SizeConfig.safeBlockHorizontal * 0.8,
              color: isBold
                  ? AppColors.black
                  : AppColors.black.withValues(alpha: 0.8)),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive) {
    return InkWell(
      onTap: () =>
          setState(() => viewMode = label.contains('2D') ? '2D' : '3D'),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: SizeConfig.vertical(1.5)),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blueDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isActive ? AppColors.blueDark : AppColors.greyDisabled),
        ),
        child: PoppinsTextView(
            value: label,
            color: isActive ? Colors.white : AppColors.grey,
            fontWeight: FontWeight.bold,
            size: SizeConfig.safeBlockHorizontal * 0.75),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
