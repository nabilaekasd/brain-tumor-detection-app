import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/dashboard_tabel_analisis.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/dashboard_tabel_data_pasien.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.dashboardController});

  final DashboardController dashboardController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER STATISTIK
          PoppinsTextView(
            value: 'Selamat Datang, User!',
            size: SizeConfig.safeBlockHorizontal * 1.2,
            fontWeight: FontWeight.bold,
          ),
          SpaceSizer(vertical: 3),

          Row(
            children: [
              Expanded(
                child: DashboardBlueCard(
                  title: 'Pasien Terdaftar',
                  subtitle: 'X',
                  icon: Icons.people_alt_outlined,
                ),
              ),
              SpaceSizer(horizontal: 2),
              Expanded(
                child: DashboardBlueCard(
                  title: 'Scan Menunggu',
                  subtitle: 'Y',
                  icon: Icons.access_time,
                ),
              ),
              SpaceSizer(horizontal: 2),
              Expanded(
                child: DashboardBlueCard(
                  title: 'Analisis Selesai',
                  subtitle: 'Z',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),

          SpaceSizer(vertical: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PoppinsTextView(
                value: 'Daftar Pasien Saya',
                size: SizeConfig.safeBlockHorizontal * 1.0,
                fontWeight: FontWeight.bold,
              ),
              CustomFlatButton(
                radius: 1.0,
                text: 'Lihat Semua Pasien',
                onTap: () {
                  dashboardController.changeMenu(1);
                },
                width: SizeConfig.safeBlockHorizontal * 10,
                height: SizeConfig.safeBlockVertical * 4,
                backgroundColor: AppColors.blueDark,
                textSize: SizeConfig.safeBlockHorizontal * 0.75,
              ),
            ],
          ),
          SpaceSizer(vertical: 1),

          // TABEL DAFTAR PASIEN
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyDisabled),
              borderRadius: BorderRadius.circular(8),
            ),
            width: double.infinity,

            child: dashboardController.pasienData.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: PoppinsTextView(
                        value: 'Data Tidak Ditemukan!',
                        size: SizeConfig.safeBlockHorizontal * 1.0,
                      ),
                    ),
                  )
                : const DashboardTabelDataPasien(isHideID: true),
          ),

          SpaceSizer(vertical: 4),
          // HEADER SCAN ANALISIS DAN TOMBOL REFRESH
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PoppinsTextView(
                value: 'Scan Sedang Dianalisis',
                size: SizeConfig.safeBlockHorizontal * 1.0,
                fontWeight: FontWeight.bold,
              ),
              CustomFlatButton(
                icon: Icons.refresh,
                colorIconImage: AppColors.blueDark,
                radius: 1.0,
                text: 'Refresh Status',
                onTap: () {},
                width: SizeConfig.safeBlockHorizontal * 10,
                height: SizeConfig.safeBlockVertical * 4,
                backgroundColor: AppColors.white,
                borderColor: AppColors.blueDark,
                textColor: AppColors.blueDark,
                textSize: SizeConfig.safeBlockHorizontal * 0.75,
              ),
            ],
          ),
          SpaceSizer(vertical: 1),

          // TABEL SCAN ANALISIS
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyDisabled),
              borderRadius: BorderRadius.circular(8),
            ),
            width: double.infinity,
            child: const DashboardTabelAnalisis(),
          ),
          SpaceSizer(vertical: 5),
        ],
      ),
    );
  }
}

class DashboardBlueCard extends StatelessWidget {
  const DashboardBlueCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.safeBlockVertical * 16,
      decoration: BoxDecoration(
        color: AppColors.blueCard,
        borderRadius: BorderRadius.all(
          Radius.circular(SizeConfig.horizontal(1)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueCard.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -SizeConfig.horizontal(1),
            bottom: -SizeConfig.vertical(1),
            child: Icon(
              icon,
              size: SizeConfig.safeBlockHorizontal * 6,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.horizontal(1.5),
              vertical: SizeConfig.vertical(1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PoppinsTextView(
                  value: title,
                  size: SizeConfig.safeBlockHorizontal * 0.8,
                  color: Colors.white,
                ),
                SpaceSizer(vertical: 0.5),
                PoppinsTextView(
                  value: subtitle,
                  size: SizeConfig.safeBlockHorizontal * 1.8,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
