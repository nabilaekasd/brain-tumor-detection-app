import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/models/data_pasien_model.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_text_field.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';

class HasilAnalisisPasien extends StatefulWidget {
  const HasilAnalisisPasien({
    super.key,
    required this.dashboardController,
    required this.pasienData,
    required this.onBack,
  });

  final DashboardController dashboardController;
  final DataPasienModel pasienData;
  final VoidCallback onBack;

  @override
  State<HasilAnalisisPasien> createState() => _HasilAnalisisPasienState();
}

class _HasilAnalisisPasienState extends State<HasilAnalisisPasien> {
  String viewMode = '3D';
  final TextEditingController doctorNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    doctorNotesController.text =
        "Pasien menunjukkan gejala massa di area frontal lobe...";
  }

  @override
  Widget build(BuildContext context) {
    bool isDokter = widget.dashboardController.userRole == 'dokter';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: widget.onBack,
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
                  value: 'Hasil Analisis AI',
                  size: SizeConfig.safeBlockHorizontal * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueDark,
                ),
                PoppinsTextView(
                  value: 'Visualisasi 3D/2D dan Laporan Prediksi',
                  size: SizeConfig.safeBlockHorizontal * 0.8,
                  color: AppColors.grey,
                ),
              ],
            ),
          ],
        ),

        SpaceSizer(vertical: 2),

        SizedBox(
          height: SizeConfig.safeBlockVertical * 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyDisabled),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.8,
                          child: Icon(
                            viewMode == '3D' ? Icons.view_in_ar : Icons.image,
                            size: 120,
                            color: Colors.white24,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: PoppinsTextView(
                            value: 'Mode: $viewMode',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            size: SizeConfig.safeBlockHorizontal * 0.8,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 20,
                        right: 20,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Masuk ke Mode Fullscreen...'),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      // Toolbar Simulasi
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greySecond.withValues(
                                alpha: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildToolIcon(Icons.zoom_in),
                                SpaceSizer(horizontal: 2),
                                _buildToolIcon(Icons.zoom_out),
                                SpaceSizer(horizontal: 2),
                                _buildToolIcon(Icons.rotate_right),
                                SpaceSizer(horizontal: 2),
                                _buildToolIcon(Icons.contrast),
                                SpaceSizer(horizontal: 2),
                                _buildToolIcon(Icons.refresh),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SpaceSizer(horizontal: 2),

              Expanded(
                flex: 4,
                child: Container(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(right: 4),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  SizeConfig.horizontal(1.5),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.greyDisabled,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Informasi Pasien'),
                                    SpaceSizer(vertical: 1.5),
                                    _buildInfoRow(
                                      'Nama',
                                      widget.pasienData.namePatient,
                                    ),
                                    _buildInfoRow(
                                      'ID Medis',
                                      widget.pasienData.idPatient,
                                    ),
                                    _buildInfoRow(
                                      'Waktu Scan',
                                      '15/10/2025 • 09:30 WIB',
                                    ),

                                    Divider(
                                      height: 30,
                                      color: AppColors.greyDisabled,
                                    ),

                                    _buildSectionTitle('Prediksi AI'),
                                    SpaceSizer(vertical: 1.5),

                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.redAlert.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.redAlert.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            color: AppColors.redAlert,
                                            size: 30,
                                          ),
                                          SpaceSizer(horizontal: 1),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              PoppinsTextView(
                                                value: 'GLIOMA DETECTED',
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.redAlert,
                                                size:
                                                    SizeConfig
                                                        .safeBlockHorizontal *
                                                    1.0,
                                              ),
                                              PoppinsTextView(
                                                value: 'Confidence: 94.2%',
                                                size:
                                                    SizeConfig
                                                        .safeBlockHorizontal *
                                                    0.8,
                                                color: AppColors.black,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SpaceSizer(vertical: 1),
                                    PoppinsTextView(
                                      value:
                                          'Lokasi: Frontal Lobe, Left Hemisphere\nUkuran Estimasi: 2.4 cm x 1.8 cm',
                                      size:
                                          SizeConfig.safeBlockHorizontal * 0.75,
                                      color: AppColors.grey,
                                    ),
                                  ],
                                ),
                              ),

                              SpaceSizer(vertical: 2),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  SizeConfig.horizontal(1.5),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.greyDisabled,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSectionTitle('Mode Tampilan'),
                                    SpaceSizer(vertical: 1.5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildModeButton(
                                            '2D Slice',
                                            viewMode == '2D',
                                          ),
                                        ),
                                        SpaceSizer(horizontal: 1),
                                        Expanded(
                                          child: _buildModeButton(
                                            '3D Volume',
                                            viewMode == '3D',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SpaceSizer(vertical: 2),

                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                  SizeConfig.horizontal(1.5),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.greyDisabled,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildSectionTitle('Catatan Dokter'),
                                        if (isDokter)
                                          Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: AppColors.blueDark,
                                          )
                                        else
                                          Icon(
                                            Icons.lock_outline,
                                            size: 16,
                                            color: AppColors.grey,
                                          ),
                                      ],
                                    ),
                                    SpaceSizer(vertical: 1.5),

                                    if (isDokter)
                                      CustomTextField(
                                        controller: doctorNotesController,
                                        title: '',
                                        hintText: 'Tulis diagnosis...',
                                        minLines: 4,
                                        borderRadius: 0.5,
                                        fillColor: AppColors.greySecond
                                            .withValues(alpha: 0.1),
                                      )
                                    else
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.greySecond
                                              .withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: AppColors.greyDisabled,
                                          ),
                                        ),
                                        child: PoppinsTextView(
                                          value:
                                              doctorNotesController
                                                  .text
                                                  .isNotEmpty
                                              ? doctorNotesController.text
                                              : 'Belum ada catatan dari dokter.',
                                          color: AppColors.black.withValues(
                                            alpha: 0.7,
                                          ),
                                          size:
                                              SizeConfig.safeBlockHorizontal *
                                              0.8,
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              SpaceSizer(vertical: 2),
                            ],
                          ),
                        ),
                      ),

                      SpaceSizer(vertical: 1),

                      Row(
                        children: [
                          Expanded(
                            child: CustomFlatButton(
                              text: 'Kembali',
                              onTap: widget.onBack,
                              height: SizeConfig.safeBlockVertical * 4.5,
                              backgroundColor: AppColors.greySecond.withValues(
                                alpha: 0.2,
                              ),
                              borderColor: Colors.transparent,
                              textColor: AppColors.black.withValues(alpha: 0.7),
                              radius: 0.8,
                              textSize: SizeConfig.safeBlockHorizontal * 0.75,
                            ),
                          ),

                          if (isDokter) ...[
                            SpaceSizer(horizontal: 1),
                            Expanded(
                              child: CustomFlatButton(
                                icon: Icons.save,
                                text: 'Simpan',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Catatan dokter disimpan!'),
                                    ),
                                  );
                                },
                                height: SizeConfig.safeBlockVertical * 4.5,
                                backgroundColor: AppColors.blueDark,
                                textColor: Colors.white,
                                colorIconImage: Colors.white,
                                radius: 0.8,
                                textSize: SizeConfig.safeBlockHorizontal * 0.75,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return PoppinsTextView(
      value: title,
      fontWeight: FontWeight.bold,
      size: SizeConfig.safeBlockHorizontal * 0.9,
      color: AppColors.black,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PoppinsTextView(
            value: label,
            color: AppColors.grey,
            size: SizeConfig.safeBlockHorizontal * 0.75,
          ),
          PoppinsTextView(
            value: value,
            fontWeight: FontWeight.w600,
            size: SizeConfig.safeBlockHorizontal * 0.8,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() {
          viewMode = label.contains('2D') ? '2D' : '3D';
        });
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.blueDark : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.blueDark : AppColors.greyDisabled,
          ),
        ),
        child: PoppinsTextView(
          value: label,
          color: isActive ? Colors.white : AppColors.grey,
          fontWeight: FontWeight.bold,
          size: SizeConfig.safeBlockHorizontal * 0.75,
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
