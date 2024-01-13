import '../../../rendering/rayCaster/camera.dart';
import '../../../rendering/rayCaster/worldMap.dart';
import '../../components/cameraComponent.dart';
import '../../gameEntity.dart';
import '../../gameSystem.dart';

class InteractionSystem implements GameSystem {
  final WorldMap _worldMap = WorldMap.instance;

  @override
  void processEntity(GameEntity gameEntity) {
    CameraComponent camera =
        gameEntity.getComponent("camera") as CameraComponent;

    interact(camera.camera);
    gameEntity.removeComponent("interaction");
  }

  void interact(Camera camera) {
    int checkMapX = (camera.xPos + camera.xDir).floor();
    int checkMapY = (camera.yPos + camera.yDir).floor();

    int checkMapX2 = (camera.xPos + camera.xDir * 2).floor();
    int checkMapY2 = (camera.yPos + camera.yDir * 2).floor();

    GameEntity gameEntity = _worldMap.getEntityAtPosition(checkMapX, checkMapY);

    if (gameEntity.hasComponent("door") ||
        gameEntity.hasComponent("pushWall") &&
            _worldMap.getDoorState(checkMapX, checkMapY) == DoorState.closed) {
      //Open door in front of camera
      _worldMap.setDoorState(checkMapX, checkMapY, DoorState.opening);
      return;
    }

    gameEntity = _worldMap.getEntityAtPosition(checkMapX2, checkMapY2);

    if (gameEntity.hasComponent("door") ||
        gameEntity.hasComponent("pushWall") &&
            _worldMap.getDoorState(checkMapX2, checkMapY2) ==
                DoorState.closed) {
      _worldMap.setDoorState(checkMapX2, checkMapY2, DoorState.opening);
      return;
    }

    gameEntity = _worldMap.getEntityAtPosition(checkMapX, checkMapY);

    if (gameEntity.hasComponent("door") ||
        gameEntity.hasComponent("pushWall") &&
            _worldMap.getDoorState(checkMapX, checkMapY) == DoorState.open) {
      //Open door in front of camera
      _worldMap.setDoorState(checkMapX, checkMapY, DoorState.closing);
      return;
    }

    gameEntity = _worldMap.getEntityAtPosition(checkMapX2, checkMapY2);

    if (gameEntity.hasComponent("door") ||
        gameEntity.hasComponent("pushWall") &&
            _worldMap.getDoorState(checkMapX2, checkMapY2) == DoorState.open) {
      _worldMap.setDoorState(checkMapX2, checkMapY2, DoorState.closing);
      return;
    }

    gameEntity =
        _worldMap.getEntityAtPosition(camera.xPos.floor(), camera.yPos.floor());

    if (gameEntity.hasComponent("door")) {
      //Avoid getting stuck in doors
      _worldMap.setDoorState(
          camera.xPos.floor(), camera.yPos.floor(), DoorState.opening);
    }
  }

  @override
  void removeIfPresent(GameEntity gameEntity) {
    // TODO: implement removeIfPresent
  }

  @override
  bool shouldRun(GameEntity gameEntity) {
    return gameEntity.hasComponent("camera") &&
        gameEntity.hasComponent("interaction");
  }
}
