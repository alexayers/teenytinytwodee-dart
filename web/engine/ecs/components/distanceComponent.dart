import '../gameComponent.dart';

class DistanceComponent implements GameComponent {
  int distance;

  DistanceComponent(int value) : distance = value;

  @override
  String get name => "distance";
}
