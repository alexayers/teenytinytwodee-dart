import 'dart:html';

import 'renderer.dart';

class Sprite {
  int width;
  int height;
  ImageElement image;

  Sprite(this.width, this.height, String imageFile) : image = ImageElement() {
    image.src = imageFile;
  }

  void render(num x, num y, int width, int height, [bool flip = false]) {
    Renderer.renderImage(image, x, y, width, height, flip);
  }
}
