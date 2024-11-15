import 'package:flutter/cupertino.dart';
import 'package:verifyone/core/utils/constants/colors.dart';

Widget titles(
    String text,
    double size, {
      int? maxLines,
      TextAlign textAlign = TextAlign.left,
    }) {
  return Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.textblack,
      fontSize: size,
    ),
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    textAlign: textAlign,
  );
}
