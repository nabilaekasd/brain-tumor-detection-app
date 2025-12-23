import 'package:axon_vision/controllers/login_controller.dart';
import 'package:axon_vision/utils/app_colors.dart';
import 'package:axon_vision/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../text_fonts/inter_text_view.dart';

class CustomTextPasswordField extends StatelessWidget {
  const CustomTextPasswordField({
    super.key,
    required this.title,
    this.height,
    this.titleFontWeight,
    this.width,
    this.textSize,
    this.borderRadius,
    this.labelText,
    this.hintText,
    this.textColor,
    this.hintTextColor,
    this.borderColor,
    this.borderSideColor,
    this.isPasswordField = false,
    this.suffixIcon,
    this.onChanged,
    this.fillColor,
    this.autofillHint,
    this.textInputAction,
    this.contentPadding,
    this.prefixIcon,
    this.controller,
    this.passwordController,
    this.textAlignVertical,
    this.onFieldSubmitted,
    this.minLines,
    this.focus,
    this.style,
    this.iconSize,
    this.keyboardType,
  });
  final String title;
  final double? height;
  final double? iconSize;
  final FontWeight? titleFontWeight;
  final double? width;
  final double? textSize;
  final double? borderRadius;
  final String? labelText;
  final String? hintText;
  final Color? textColor;
  final Color? hintTextColor;
  final Color? borderColor;
  final Color? fillColor;
  final Color? borderSideColor;
  final bool? isPasswordField;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final Iterable<String>? autofillHint;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefixIcon;
  final TextEditingController? controller;
  final TextEditingController? passwordController;
  final TextAlignVertical? textAlignVertical;
  final Function(String)? onFieldSubmitted;
  final int? minLines;
  final FocusNode? focus;
  final TextStyle? style;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    final LoginController loginController = Get.put(LoginController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title == '')
          const SizedBox.shrink()
        else
          InterTextView(
            value: title,
            size: textSize ?? SizeConfig.safeBlockHorizontal * 0.9,
            fontWeight: titleFontWeight ?? FontWeight.w500,
            color: textColor ?? AppColors.black,
          ),

        SizedBox(height: SizeConfig.vertical(1)),

        SizedBox(
          width: SizeConfig.horizontal(width ?? 25),
          height: height ?? SizeConfig.vertical(7),
          // ignore: use_if_null_to_convert_nulls_to_bools
          child: Obx(
            () => TextFormField(
              autofillHints: autofillHint,
              minLines: minLines,
              controller: controller,
              focusNode: focus,
              cursorColor: AppColors.maroon,
              onChanged: onChanged,
              keyboardType: TextInputType.text,
              textInputAction: textInputAction,

              // ignore: avoid_bool_literals_in_conditional_expressions, use_if_null_to_convert_nulls_to_bools
              obscureText: loginController.isObscurePassword.value =
                  loginController.isObscurePassword.value,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(left: 10),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(SizeConfig.horizontal(borderRadius ?? 0.5)),
                  ),
                ),
                prefixIcon: prefixIcon,
                suffixIcon: IconButton(
                  iconSize: iconSize,
                  onPressed: () {
                    loginController.isObscurePassword.value =
                        !loginController.isObscurePassword.value;
                  },
                  icon: Icon(
                    loginController.isObscurePassword.isFalse
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  color: loginController.isObscurePassword.isFalse
                      ? AppColors.black
                      : AppColors.greyDisabled,
                ),
                fillColor: fillColor ?? AppColors.greyDisabled,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(SizeConfig.horizontal(borderRadius ?? 0.5)),
                  ),
                ),
                labelText: hintText,
                floatingLabelBehavior: FloatingLabelBehavior.never,
                labelStyle: InterStyle().labelStyle(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
