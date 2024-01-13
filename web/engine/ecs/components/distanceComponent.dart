import '../gameComponent.dart';

class DistanceComponent implements GameComponent {
  num distance;

  DistanceComponent(num value) : distance = value;

  @override
  String get name => "distance";
}
