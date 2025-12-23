import 'package:axon_vision/pages/global_widgets/text_fonts/poppins_text_view.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:axon_vision/utils/space_sizer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextPasswordField extends StatefulWidget {
  const CustomTextPasswordField({
    super.key,
    required this.title,
    required this.hintText,
    this.controller,
    this.width,
    this.fillColor,
    this.borderRadius,
    this.titleFontWeight,
    this.isPasswordField = true,
  });

  final String title;
  final String hintText;
  final TextEditingController? controller;
  final double? width;
  final Color? fillColor;
  final double? borderRadius;
  final FontWeight? titleFontWeight;
  final bool isPasswordField;

  @override
  State<CustomTextPasswordField> createState() =>
      _CustomTextPasswordFieldState();
}

class _CustomTextPasswordFieldState extends State<CustomTextPasswordField> {
  // State lokal untuk menyembunyikan/menampilkan password
  bool isObscure = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width != null
          ? SizeConfig.safeBlockHorizontal * widget.width!
          : double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PoppinsTextView(
            value: widget.title,
            size: SizeConfig.safeBlockHorizontal * 0.9,
            fontWeight: widget.titleFontWeight ?? FontWeight.w600,
            color: AppColors.black,
          ),
          SpaceSizer(vertical: 1),

          // Input Field
          TextFormField(
            controller: widget.controller,
            obscureText: isObscure,
            maxLines: 1,
            style: GoogleFonts.poppins(
              fontSize: SizeConfig.safeBlockHorizontal * 0.9,
              color: AppColors.black,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: widget.fillColor ?? Colors.white,
              hintText: widget.hintText,
              hintStyle: GoogleFonts.poppins(
                fontSize: SizeConfig.safeBlockHorizontal * 0.8,
                color: AppColors.grey,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: SizeConfig.safeBlockVertical * 1.8,
                horizontal: SizeConfig.safeBlockHorizontal * 3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.safeBlockHorizontal * (widget.borderRadius ?? 1.5),
                ),
                borderSide: BorderSide(color: AppColors.greyDisabled),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.safeBlockHorizontal * (widget.borderRadius ?? 1.5),
                ),
                borderSide: BorderSide(color: AppColors.greyDisabled),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.safeBlockHorizontal * (widget.borderRadius ?? 1.5),
                ),
                borderSide: BorderSide(color: AppColors.blueDark),
              ),
              // Ikon Mata (Show/Hide)
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
