import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/models/data_pasien_model.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';

class DataPasienMenuDetail extends StatelessWidget {
  const DataPasienMenuDetail({
    super.key,
    required this.dashboardController,
    required this.pasienData,
    required this.onBack,
  });
  final DashboardController dashboardController;
  final DataPasienModel pasienData;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back, color: AppColors.black),
              tooltip: 'Kembali',
            ),
            SpaceSizer(horizontal: 1),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PoppinsTextView(
                  value: 'Detail Pasien',
                  size: SizeConfig.safeBlockHorizontal * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueDark,
                ),
                PoppinsTextView(
                  value: 'Lihat informasi lengkap dan riwayat pemeriksaan',
                  size: SizeConfig.safeBlockHorizontal * 0.8,
                  color: AppColors.grey,
                ),
              ],
            ),
          ],
        ),
        SpaceSizer(vertical: 3),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(SizeConfig.horizontal(2)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyDisabled),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: SizeConfig.safeBlockHorizontal * 6,
                height: SizeConfig.safeBlockHorizontal * 6,
                decoration: BoxDecoration(
                  color: AppColors.bgColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: SizeConfig.safeBlockHorizontal * 3,
                  color: AppColors.bgColor,
                ),
              ),
              SpaceSizer(horizontal: 2),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PoppinsTextView(
                          value: pasienData.namePatient,
                          size: SizeConfig.safeBlockHorizontal * 1.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        _buildStatusBadge(pasienData.status),
                      ],
                    ),
                    SpaceSizer(vertical: 2),

                    Row(
                      children: [
                        _buildInfoItem('ID Pasien', pasienData.idPatient),
                        SpaceSizer(horizontal: 4),
                        _buildInfoItem(
                          'Tanggal Lahir',
                          pasienData.tanggalLahir,
                        ),
                        SpaceSizer(horizontal: 4),
                        _buildInfoItem('Jenis Kelamin', 'Laki-laki'),
                        SpaceSizer(horizontal: 4),
                        _buildInfoItem('Terakhir Periksa', '15 Okt 2025'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SpaceSizer(vertical: 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppColors.blueDark,
                  size: SizeConfig.safeBlockHorizontal * 1.5,
                ),
                SpaceSizer(horizontal: 1),
                PoppinsTextView(
                  value: 'Riwayat Scan MRI',
                  size: SizeConfig.safeBlockHorizontal * 1.1,
                  color: AppColors.black,
                ),
              ],
            ),

            if (dashboardController.userRole == 'radiolog')
              CustomFlatButton(
                icon: Icons.cloud_upload_outlined,
                text: 'Upload MRI Baru',
                onTap: () {
                  dashboardController.handledChangeScreenDynamic(pasienData);
                  dashboardController.changeMenu(3);
                },
                radius: 0.8,
                width: SizeConfig.blockSizeHorizontal * 14,
                height: SizeConfig.safeBlockVertical * 5,
                backgroundColor: AppColors.bgColor,
                textColor: Colors.white,
                colorIconImage: Colors.white,
                textSize: SizeConfig.safeBlockHorizontal * 0.8,
              ),
          ],
        ),
        SpaceSizer(vertical: 2),

        Column(
          children: [
            _buildScanHistoryCard(
              'MRI Brain Contrast',
              '15 Oktober 2025 - 09:30 WIB',
              'Selesai',
              true,
            ),
            SpaceSizer(vertical: 1.5),
            _buildScanHistoryCard(
              'MRI Brain Plain',
              '10 Januari 2025 - 14:00 WIB',
              'Selesai',
              true,
            ),
          ],
        ),
        SpaceSizer(vertical: 5),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PoppinsTextView(
          value: label,
          size: SizeConfig.safeBlockHorizontal * 0.75,
          color: AppColors.grey,
        ),
        SizedBox(height: SizeConfig.vertical(0.5)),
        PoppinsTextView(
          value: value,
          size: SizeConfig.safeBlockHorizontal * 0.9,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'aktif';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.horizontal(1),
        vertical: SizeConfig.vertical(0.5),
      ),
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
        size: SizeConfig.safeBlockHorizontal * 0.7,
        color: isActive ? Colors.green : Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildScanHistoryCard(
    String title,
    String date,
    String status,
    bool hasResult,
  ) {
    Color statusColor;
    Color statusBgColor;

    String statusLower = status.toLowerCase();
    if (statusLower.contains('selesai')) {
      statusColor = Colors.green;
      statusBgColor = Colors.green.withValues(alpha: 0.1);
    } else if (statusLower.contains('analisis') ||
        statusLower.contains('proses')) {
      statusColor = AppColors.blueDark;
      statusBgColor = AppColors.blueDark.withValues(alpha: 0.1);
    } else {
      statusColor = Colors.orange;
      statusBgColor = Colors.orange.withValues(alpha: 0.1);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.vertical(2.0),
        horizontal: SizeConfig.horizontal(2.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyDisabled.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeConfig.horizontal(1.0)),
            decoration: BoxDecoration(
              color: AppColors.blueCard.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.blueDark,
              size: SizeConfig.safeBlockHorizontal * 1.5,
            ),
          ),
          SpaceSizer(horizontal: 2.0),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PoppinsTextView(
                  value: title,
                  size: SizeConfig.safeBlockHorizontal * 0.95,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                SizedBox(height: SizeConfig.vertical(0.8)),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 12, color: AppColors.grey),
                    SizedBox(width: 4),
                    PoppinsTextView(
                      value: date,
                      size: SizeConfig.safeBlockHorizontal * 0.75,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: PoppinsTextView(
                  value: status,
                  size: SizeConfig.safeBlockHorizontal * 0.75,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              SpaceSizer(horizontal: 2),

              CustomFlatButton(
                text: 'Lihat Hasil Analisis',
                onTap: () {
                  dashboardController.changeMenu(4);
                },
                width: SizeConfig.blockSizeHorizontal * 8,
                height: SizeConfig.safeBlockVertical * 4.5,
                radius: 0.6,
                backgroundColor: Colors.transparent,
                borderColor: AppColors.blueDark,
                textColor: AppColors.blueDark,
                textSize: SizeConfig.safeBlockHorizontal * 0.75,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
