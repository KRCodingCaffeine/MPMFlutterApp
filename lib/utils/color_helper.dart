import 'package:flutter/material.dart';

class ColorHelperClass {
  static LinearGradient getGradientFromStringColor(String colorString1 ,String colorString2) {
    Color color = getColorFromHexString(colorString1);
    Color color2 = getColorFromHexString2(colorString2);

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomLeft,
      colors: [color2, color],
    );
  }

  static Color getColorFromHexString(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  static Color getColorFromHexString2(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", ""); // Remove the '#' symbol
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor; // Add the alpha value if missing
    }
    return Color(int.parse(hexColor, radix: 16)); // Convert hex to Color
  }
}