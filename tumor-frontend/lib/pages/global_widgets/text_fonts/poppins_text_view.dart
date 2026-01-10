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
    this.size, // Ini parameter lama (biar kodingan lain aman)
    this.fontSize, // Ini parameter baru (biar tombol Apply/Cancel bisa set ukuran)
    this.fontStyle,
    this.fontWeight,
    this.alignText,
    this.textAlign,
    this.overFlow,
    this.textDecoration,
    this.decorationColor,
    this.maxLines,
    this.height,
    // HAPUS bagian 'required int fontSize' yang bikin error itu
  });

  final String value;
  final Color? color;
  final double? size; // Variable lama
  final double? fontSize; // Variable baru (Tipe double, bukan int)
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
    TextAlign finalAlign = textAlign ??
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

        // --- LOGIKA CERDAS ---
        // 1. Cek apakah 'fontSize' diisi? (oleh tombol Cancel/Apply)
        // 2. Jika tidak, cek apakah 'size' diisi? (oleh halaman lain)
        // 3. Jika tidak ada juga, pakai ukuran default (SizeConfig)
        fontSize: fontSize ?? size ?? SizeConfig.safeBlockHorizontal * 4,

        fontStyle: fontStyle ?? FontStyle.normal,
        fontWeight: fontWeight ?? FontWeight.normal,
        height: height,
      ),
    );
  }
}

// --- BAGIAN INI BIARKAN SAJA (TIDAK PERLU DIUBAH) ---
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
