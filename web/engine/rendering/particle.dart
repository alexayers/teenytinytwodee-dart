


import '../primitives/color.dart';

class Particle {

  num x;
  num y;
  num width;
  num height;
  num alpha;
  num lifeSpan;
  num decayRate;
  num velX;
  num velY;
  Color color = Color(255,255,255);

  Particle(this.x, this.y, this.width, this.height, this.alpha, this.lifeSpan, this.decayRate, this.velX, this.velY, this.color);

}
