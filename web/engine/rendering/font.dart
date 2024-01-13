

import '../primitives/color.dart';

enum FontFamily {
  arial
}

enum FontStyle {
  bold,
  italic,
  normal
}

class Font {
  String family = FontFamily.arial.toString();
  int size = 12;
  FontStyle style = FontStyle.normal;
  Color color = Colors.white;
}
