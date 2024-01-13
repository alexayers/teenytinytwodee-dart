

import '../gameComponent.dart';

class DistanceComponent extends GameComponent {

  int distance;

  DistanceComponent(int value) : distance = value;

  @override
  String get name => "distance";

}
