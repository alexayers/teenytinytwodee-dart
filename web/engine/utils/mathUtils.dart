

import 'dart:html';
import 'dart:math';


 class  MathUtils {


  static num getDecimal(num d) {
    return d - d.floor();
  }

  static Point rotateVector(num vx, num vy, num angle) {
    return Point(
      vx * cos(angle) - vy * sin(angle),
      vx * sin(angle) + vy * cos(angle),
    );
  }


}
