import 'package:axon_vision/controllers/dashboard_controller.dart';
import 'package:axon_vision/pages/dashboard/dashboard_widget/dashboard_tabel_data_pasien.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_flat_button.dart';
import 'package:axon_vision/pages/global_widgets/custom/custom_text_field.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DaftarPasienMenu extends StatelessWidget {
  const DaftarPasienMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      init: DashboardController(),
      builder: (dashboardController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JUDUL HALAMAN KECIL
          Padding(
            padding: EdgeInsets.only(bottom: SizeConfig.vertical(1)),
            child: PoppinsTextView(
              value: 'Manajemen Data Pasien',
              size: SizeConfig.safeBlockHorizontal * 1.0,
              fontWeight: FontWeight.w600,
              color: AppColors.blueDark,
            ),
          ),

          // === AREA FILTER & PENCARIAN ===
          Container(
            padding: EdgeInsets.all(SizeConfig.horizontal(1.5)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.greyDisabled.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                // 1. SEARCH BAR
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: dashboardController.searchController,
                    width: 100,
                    title: '',
                    borderRadius: 0.5,
                    hintText: 'Cari Nama atau ID Pasien...',
                    hintTextSize: SizeConfig.safeBlockHorizontal * 0.8,
                    hintTextFontweight: FontWeight.w400,
                    prefixIcon: Icon(Icons.search, color: AppColors.grey),
                    fillColor: AppColors.greySecond.withValues(alpha: 0.3),
                  ),
                ),

                SpaceSizer(horizontal: 1.5),

                // 2. DROPDOWN FILTER STATUS
                Expanded(
                  flex: 1,
                  child: Container(
                    height: SizeConfig.safeBlockVertical * 5.5,
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.horizontal(1),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.greyDisabled),
                      borderRadius: BorderRadius.circular(
                        SizeConfig.horizontal(0.5),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Semua Status',
                        icon: Icon(Icons.filter_list, color: AppColors.grey),
                        isExpanded: true,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: SizeConfig.safeBlockHorizontal * 0.8,
                        ),
                        onChanged: (String? newValue) {
                          // Logika filter disini
                        },
                        items: <String>['Semua Status', 'Aktif', 'Tidak Aktif']
                            .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ),
                ),

                SpaceSizer(horizontal: 1.5),

                // 3. TOMBOL REFRESH
                CustomFlatButton(
                  icon: Icons.refresh,
                  text: 'Muat Ulang',
                  onTap: () {
                    dashboardController.searchPatients(
                      dashboardController.searchController.text,
                    );
                  },
                  radius: 0.5,
                  width: SizeConfig.blockSizeHorizontal * 9,
                  height: SizeConfig.safeBlockVertical * 5.5,
                  backgroundColor: AppColors.bgColor,
                  textSize: SizeConfig.safeBlockHorizontal * 0.8,
                ),
              ],
            ),
          ),

          SpaceSizer(vertical: 2),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.greyDisabled),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: dashboardController.pasienData.isEmpty
                ? SizedBox(
                    height: SizeConfig.safeBlockVertical * 30,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 50,
                            color: AppColors.grey,
                          ),
                          SpaceSizer(vertical: 1),
                          PoppinsTextView(
                            value: 'Data Tidak Ditemukan',
                            size: SizeConfig.safeBlockHorizontal * 1.0,
                            color: AppColors.grey,
                          ),
                        ],
                      ),
                    ),
                  )
                : const DashboardTabelDataPasien(isHideID: false),
          ),

          SpaceSizer(vertical: 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PoppinsTextView(
                value:
                    'Halaman 1 dari ${dashboardController.getPasienPageCount().toInt()}',
                size: SizeConfig.safeBlockHorizontal * 0.7,
                color: AppColors.grey,
              ),

              Row(
                children: [
                  PoppinsTextView(
                    value:
                        'Menampilkan ${dashboardController.pasienData.length} data',
                    size: SizeConfig.safeBlockHorizontal * 0.7,
                    color: AppColors.grey,
                  ),
                  SpaceSizer(horizontal: 1),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyDisabled),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_left, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: AppColors.greyDisabled,
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_right, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SpaceSizer(vertical: 2),
        ],
      ),
    );
  }
}
