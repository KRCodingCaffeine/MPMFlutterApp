import 'package:flutter/material.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/dimensions.dart';
import 'package:mpm/utils/fontfamilys.dart';

class TextStyleClass{
  static  TextStyle primary16style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeDefault,
    color: ColorHelperClass.getColorFromHex(ColorResources.primary_color),
    fontStyle: FontStyle.normal,

  );
  static  TextStyle white16style = TextStyle(
    fontFamily: FontFamilys.fontboldss,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeDefault,
    color: ColorResources.white,
    fontStyle: FontStyle.normal,

  );static  TextStyle white14style = TextStyle(
    fontFamily: FontFamilys.fontboldss,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeSmall,
    color: ColorResources.white,
    fontStyle: FontStyle.normal,

  );
  static  TextStyle black16style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeDefault,
    color: ColorResources.black,
    fontStyle: FontStyle.normal,

  );
  static  TextStyle black20style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeExtraLarge,
    color: ColorResources.black,
    fontStyle: FontStyle.normal,
  );
  static  TextStyle black14style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.w300,
    fontSize: Dimensions.fontSizeSmall2,
    color: ColorResources.black,
    fontStyle: FontStyle.normal,

  );
  static  TextStyle black12style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.w500,
    fontSize: Dimensions.fontSizeSmall,
    color: ColorResources.black,
    fontStyle: FontStyle.normal,

  );
  static  TextStyle pink12style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeSmall,
    color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
    fontStyle: FontStyle.normal,
  );

static  TextStyle pink16style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeDefault,
    color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
    fontStyle: FontStyle.normal,
  );
static  TextStyle pink14style = TextStyle(
    fontFamily: FontFamilys.fontfamily,
    fontWeight: FontWeight.bold,
    fontSize: Dimensions.fontSizeSmall,
    color: ColorHelperClass.getColorFromHex(ColorResources.pink_color),
    fontStyle: FontStyle.normal,
  );
}