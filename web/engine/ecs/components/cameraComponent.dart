


import '../../rendering/rayCaster/camera.dart';
import '../gameComponent.dart';

class CameraComponent extends GameComponent {

  Camera camera;

  CameraComponent(this.camera);

  @override
  String get name => "camera";

}
