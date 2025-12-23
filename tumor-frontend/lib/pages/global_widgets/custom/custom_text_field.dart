import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.width,
    required this.title,
    this.controller,
    this.hintText,
    this.fillColor,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatter,
    this.borderRadius,
    this.textSize,
    this.hintTextSize,
    this.hintTextFontweight,
    this.titleTextSize,
    this.titleFontWeight,
    this.minLines,
    this.maxLines,
    this.obscureText = false,
    this.onChanged,
  });

  final double? width;
  final String title;
  final String? hintText;
  final TextEditingController? controller;
  final Color? fillColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;
  final double? borderRadius;
  final double? textSize;
  final double? hintTextSize;
  final FontWeight? hintTextFontweight;
  final double? titleTextSize;
  final FontWeight? titleFontWeight;
  final int? minLines;
  final int? maxLines;
  final bool obscureText;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width != null
          ? SizeConfig.safeBlockHorizontal * width!
          : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            PoppinsTextView(
              value: title,
              size: titleTextSize ?? SizeConfig.safeBlockHorizontal * 0.9,
              fontWeight: titleFontWeight ?? FontWeight.w600,
              color: AppColors.black,
            ),
            SpaceSizer(vertical: 1),
          ],

          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatter,
            minLines: minLines ?? 1,
            maxLines: obscureText ? 1 : (maxLines ?? 1),
            obscureText: obscureText,
            onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: textSize ?? SizeConfig.safeBlockHorizontal * 0.9,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: fillColor ?? Colors.white,
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                fontSize: hintTextSize ?? SizeConfig.safeBlockHorizontal * 0.8,
                fontWeight: hintTextFontweight ?? FontWeight.normal,
                color: AppColors.grey,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,

              contentPadding: EdgeInsets.symmetric(
                vertical: SizeConfig.safeBlockVertical * 2.0,
                horizontal: SizeConfig.safeBlockHorizontal * 1.5,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.safeBlockHorizontal * (borderRadius ?? 0.8),
                ),
                borderSide: BorderSide(color: AppColors.greyDisabled),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.safeBlockHorizontal * (borderRadius ?? 0.8),
                ),
                borderSide: BorderSide(color: AppColors.greyDisabled),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.safeBlockHorizontal * (borderRadius ?? 0.8),
                ),
                borderSide: BorderSide(color: AppColors.blueDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
