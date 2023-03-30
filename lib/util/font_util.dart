import 'package:fluent_ui/fluent_ui.dart';

TextStyle getFontStyle({double? size, FontWeight? fontWeight, Color? color}) {
  return TextStyle(
      color: color,
      fontSize: size,
      fontFamily: "Source Sans Pro",
      locale: const Locale("zh", "CN"));
}

TextStyle getCodeFontStyle(
    {double? size, FontWeight? fontWeight, Color? color}) {
  return TextStyle(
      color: color,
      fontSize: size,
      fontFamily: "JetBrainsMono",
      locale: const Locale("zh", "CN"));
}

String getValidText(String text, int maxLen) {
  if (text.length > maxLen) {
    return "${text.substring(0, maxLen)}...";
  } else {
    return text;
  }
}
