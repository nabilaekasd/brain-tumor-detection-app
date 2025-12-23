import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/enums.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoppinsTextView extends StatelessWidget {
  const PoppinsTextView({
    super.key,
    required this.value,
    this.color,
    this.size,
    this.fontStyle,
    this.fontWeight,
    this.alignText,
    this.textAlign,
    this.overFlow,
    this.textDecoration,
    this.decorationColor,
    this.maxLines,
    this.height,
  });

  final String value;
  final Color? color;
  final double? size;
  final FontStyle? fontStyle;
  final FontWeight? fontWeight;
  final AlignTextType? alignText;
  final TextAlign? textAlign;
  final TextOverflow? overFlow;
  final TextDecoration? textDecoration;
  final Color? decorationColor;
  final int? maxLines;
  final double? height;

  @override
  Widget build(BuildContext context) {
    TextAlign finalAlign =
        textAlign ??
        (alignText == AlignTextType.center
            ? TextAlign.center
            : alignText == AlignTextType.right
            ? TextAlign.right
            : alignText == AlignTextType.justify
            ? TextAlign.justify
            : TextAlign.left);

    return Text(
      value,
      overflow: overFlow,
      maxLines: maxLines,
      textAlign: finalAlign,
      style: GoogleFonts.poppins(
        decoration: textDecoration,
        decorationColor: decorationColor,
        color: color ?? AppColors.black,
        fontSize: size ?? SizeConfig.safeBlockHorizontal * 4,
        fontStyle: fontStyle ?? FontStyle.normal,
        fontWeight: fontWeight ?? FontWeight.normal,
        height: height,
      ),
    );
  }
}

class PoppinsStyle {
  TextStyle labelStyle() {
    return GoogleFonts.poppins(
      color: Colors.white,
      fontSize: SizeConfig.safeBlockHorizontal * 1.1,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle dropdownStyle() {
    return GoogleFonts.poppins(
      color: Colors.white,
      fontSize: SizeConfig.safeBlockHorizontal * 1.2,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold,
    );
  }

  TextStyle textfieldStyle() {
    return GoogleFonts.poppins(
      color: Colors.black,
      fontSize: SizeConfig.safeBlockHorizontal * 0.8,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
    );
  }

  TextStyle unSelectedStyle() {
    return GoogleFonts.poppins(
      color: Colors.black54,
      fontSize: SizeConfig.safeBlockHorizontal * 1,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
    );
  }
}
