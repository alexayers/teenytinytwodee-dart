

import 'dart:html';

class Sprite {

  int width;
  int height;
  ImageElement image;

  Sprite(this.width, this.height, String imageFile) : image = ImageElement() {
    image.src = imageFile;
  }

}
