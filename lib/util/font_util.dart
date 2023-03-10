import 'package:fluent_ui/fluent_ui.dart';

TextStyle getFontStyle({double? size, FontWeight? fontWeight}) {
  return TextStyle(
      fontSize: size,
      fontFamily: "Source Sans Pro",
      locale: const Locale("zh", "CN"));
}

String getValidText(String text, int maxLen) {
  if (text.length > maxLen) {
    return "${text.substring(0, maxLen)}...";
  } else
    return text;
}
