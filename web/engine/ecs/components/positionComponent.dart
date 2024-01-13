import '../gameComponent.dart';

class PositionComponent extends GameComponent {

  int x;
  int y;

  PositionComponent(int valueX, int valueY) : x = valueX, y = valueY;

  @override
  String get name => "position";

}
