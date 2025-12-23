import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/hasil_analisis_pasien.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/home_dashboard.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/left_text_menu.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/data_pasien_menu_detail.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/pengaturan_profil.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/upload_scan_mri.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/daftar_pasien_menu.dart';
import 'package:axon_vision/pages/global_widgets/frame/frame_scaffold.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/asset_list.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    int notificationCount = 3;

    return FrameScaffold(
      heightBar: 0,
      elevation: 0,
      color: AppColors.black,
      statusBarColor: AppColors.black,
      colorScaffold: AppColors.white,
      statusBarBrightness: Brightness.light,
      view: GetBuilder<DashboardController>(
        init: DashboardController(),
        builder: (DashboardController dashboardController) => Center(
          child: Container(
            width: SizeConfig.safeBlockHorizontal * 90,
            height: SizeConfig.safeBlockVertical * 96,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(SizeConfig.safeBlockHorizontal * 1.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // SIDEBAR ANIMATED
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: dashboardController.isSidebarExpanded.value
                        ? SizeConfig.safeBlockHorizontal * 15
                        : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFf0F4FA),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          SizeConfig.safeBlockHorizontal * 1.5,
                        ),
                        bottomLeft: Radius.circular(
                          SizeConfig.safeBlockHorizontal * 1.5,
                        ),
                      ),
                    ),

                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: SizeConfig.safeBlockHorizontal * 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: SizeConfig.horizontal(2),
                                top: SizeConfig.vertical(3),
                                bottom: SizeConfig.vertical(2),
                              ),
                              child: Image.asset(
                                AssetList.axonLogo,
                                fit: BoxFit.contain,
                                width: SizeConfig.safeBlockHorizontal * 12,
                                height: SizeConfig.safeBlockVertical * 12,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: SizeConfig.horizontal(2),
                              ),
                              child: LeftTextMenu(
                                onMenuTap: (index) {
                                  dashboardController.changeMenu(index);
                                },
                                activeIndex:
                                    dashboardController.activeMenuIndex,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => dashboardController.isSidebarExpanded.value
                      ? Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.horizontal(1),
                          ),
                          width: 1,
                          height: double.infinity,
                          color: AppColors.greyDisabled.withValues(alpha: 0.5),
                        )
                      : const SizedBox.shrink(),
                ),

                // AREA KONTEN (KANAN)
                Expanded(
                  child: Column(
                    children: [
                      // FIXED HEADER
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.vertical(2),
                          horizontal: SizeConfig.horizontal(2),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.greyDisabled.withValues(
                                alpha: 0.5,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //TOMBOL MENU
                            IconButton(
                              onPressed: () {
                                dashboardController.toggleSidebar();
                              },
                              icon: Icon(
                                dashboardController.isSidebarExpanded.value
                                    ? Icons.menu_open
                                    : Icons.menu,
                                color: AppColors.black,
                              ),
                              tooltip: 'Toggle Sidebar',
                            ),
                            SpaceSizer(horizontal: 1),

                            PoppinsTextView(
                              value: dashboardController.activeMenuIndex == 0
                                  ? 'Dashboard'
                                  : dashboardController.activeMenuIndex == 5
                                  ? 'Pengaturan Profil'
                                  : 'Detail Pasien',
                              size: SizeConfig.safeBlockHorizontal * 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                            const Spacer(),

                            PoppinsTextView(
                              value: 'Halo, User',
                              size: SizeConfig.safeBlockHorizontal * 0.9,
                              fontWeight: FontWeight.w500,
                            ),
                            SpaceSizer(horizontal: 1),

                            // INFO USER
                            PopupMenuButton<String>(
                              offset: const Offset(0, 50),
                              tooltip: 'Profil Menu',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onSelected: (value) {
                                if (value == 'notifikasi') {
                                  debugPrint("Buka Notifikasi");
                                } else if (value == 'logout') {
                                  context.goNamed('login');
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'notifikasi',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.notifications_outlined,
                                            color: AppColors.blueDark,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('Notifikasi'),
                                          const Spacer(),

                                          if (notificationCount > 0)
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppColors.redAlert,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '$notificationCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem<String>(
                                      value: 'logout',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.logout,
                                            color: AppColors.redAlert,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Logout',
                                            style: TextStyle(
                                              color: AppColors.redAlert,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                              child: Badge(
                                isLabelVisible: notificationCount > 0,
                                label: Text('$notificationCount'),
                                backgroundColor: AppColors.redAlert,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                  ),
                                  child: CircleAvatar(
                                    radius:
                                        SizeConfig.safeBlockHorizontal * 1.3,
                                    backgroundColor: AppColors.bgColor,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size:
                                          SizeConfig.safeBlockHorizontal * 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SpaceSizer(horizontal: 1),
                          ],
                        ),
                      ),

                      //SCROLLABLE CONTENT
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.horizontal(2),
                            vertical: SizeConfig.vertical(2),
                          ),
                          physics: dashboardController.activeMenuIndex == 4
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [_buildActiveMenu(dashboardController)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveMenu(DashboardController dashboardController) {
    switch (dashboardController.activeMenuIndex) {
      case 0:
        return Home(dashboardController: dashboardController);
      case 1:
        return const DaftarPasienMenu();
      case 2:
        return DataPasienMenuDetail(
          dashboardController: dashboardController,
          pasienData: dashboardController.selectedPasien!,
          onBack: () {
            dashboardController.backToPasienList();
          },
        );
      case 3:
        return UploadScanMri(
          dashboardController: dashboardController,
          pasienData: dashboardController.selectedPasien!,
          onBack: () {
            dashboardController.backToPasienList();
          },
        );
      case 4:
        return HasilAnalisisPasien(
          dashboardController: dashboardController,
          pasienData: dashboardController.selectedPasien!,
          onBack: () {
            dashboardController.backToPasienList();
          },
        );
      case 5:
        return const PengaturanProfil();

      default:
        return Home(dashboardController: dashboardController);
    }
  }
}
