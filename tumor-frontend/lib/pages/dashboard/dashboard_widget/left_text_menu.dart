import 'package:axon_vision/pages/global_widgets/custom/custom_ripple_button.dart';
import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';

class LeftTextMenu extends StatelessWidget {
  final Function(int) onMenuTap;
  final int activeIndex;
  const LeftTextMenu({
    super.key,
    required this.onMenuTap,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpaceSizer(vertical: 2),

        _buildMenuItem(
          index: 0,
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          isActive: activeIndex == 0,
        ),

        SpaceSizer(vertical: 2),

        _buildMenuItem(
          index: 1,
          label: 'Data Pasien',
          icon: Icons.people_outline,
          isActive: [1, 2, 3, 4].contains(activeIndex),
        ),

        SpaceSizer(vertical: 2),

        _buildMenuItem(
          index: 5,
          label: 'Pengaturan Profil',
          icon: Icons.settings_outlined,
          isActive: activeIndex == 5,
        ),
        SpaceSizer(vertical: 20),

        Divider(color: AppColors.grey.withValues(alpha: 0.5), thickness: 0.5),

        SpaceSizer(vertical: 2),

        Padding(
          padding: EdgeInsets.only(left: SizeConfig.horizontal(1)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PoppinsTextView(
                value: 'Axon Vision v1.0.0',
                size: SizeConfig.safeBlockHorizontal * 0.7,
                color: AppColors.grey,
                fontWeight: FontWeight.w500,
              ),
              PoppinsTextView(
                value: '© 2025 All Rights Reserved',
                size: SizeConfig.safeBlockHorizontal * 0.6,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required int index,
    required String label,
    required bool isActive,
    required IconData icon,
  }) {
    return CustomRippleButton(
      onTap: () => onMenuTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.bgColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.vertical(1.2),
          horizontal: SizeConfig.horizontal(1),
        ),
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.horizontal(0.5)),
        child: Row(
          children: [
            Icon(
              icon,
              size: SizeConfig.safeBlockHorizontal * 1.2,
              color: isActive ? AppColors.bgColor : AppColors.grey,
            ),
            SpaceSizer(horizontal: 1),

            Expanded(
              child: PoppinsTextView(
                value: label,
                size: SizeConfig.safeBlockHorizontal * 0.85,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.bgColor : AppColors.grey,
              ),
            ),
            if (isActive)
              Container(
                width: 3,
                height: SizeConfig.safeBlockHorizontal * 1.2,
                decoration: BoxDecoration(
                  color: AppColors.bgColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
