

import '../gameComponent.dart';

class PushWallComponent extends GameComponent {

  bool _openWall = false;

  void openWall() {
    _openWall = true;
  }

  bool isWallOpen() {
    return _openWall;
  }

  @override
  String get name => "pushWall";

}
