

import '../../ecs/components/doorComponent.dart';
import '../../ecs/components/pushWallComponent.dart';
import '../../ecs/gameEntity.dart';
import 'renderPerformance.dart';

enum DoorState {
  closed,
  opening,
  open,
  closing
}


class WorldMap {

  static WorldMap? _instance;
  late List<GameEntity> _gameMap = [];
  late final int _worldWidth = 10;
  late final int _worldHeight = 10;
  List<num> _doorOffsets = [];
  List<DoorState> _doorStates = [];

  WorldMap._privateConstructor();

  static WorldMap get instance {
    _instance ??= WorldMap._privateConstructor();
    return _instance!;
  }

  void loadMap(List<int> grid, Map<int, GameEntity> translationTable) {

    for (int y =0; y < _worldHeight; y++) {
      for (int x = 0; x < _worldWidth; x++) {
        int pos = x + (y * _worldWidth);
        int value = grid[pos];
        _gameMap.add(translationTable[value]!);
      }
    }

    for (int i = 0; i < _worldWidth * _worldHeight; i++) {
      _doorOffsets.add(0);
      _doorStates.add(DoorState.closed);
    }

  }

  void moveDoors() {

    for (int y = 0; y < _worldHeight; y++) {
      for (int x = 0; x < _worldWidth; x++) {

        GameEntity gameEntity = getEntityAtPosition(x, y);

        if (gameEntity.hasComponent("door")) { //Standard door
          if (getDoorState(x, y) == DoorState.opening) {//Open doors
            setDoorOffset(x, y, getDoorOffset(x, y) + RenderPerformance.deltaTime / 100);

            if (getDoorOffset(x, y) > 1) {
              setDoorOffset(x, y, 1);
              setDoorState(x, y, DoorState.open);//Set state to open

              DoorComponent door  = gameEntity.getComponent("door") as DoorComponent;
              door.openDoor();

              Future.delayed(Duration(seconds: 5), () {
                setDoorState(x, y, DoorState.closing);

                var door = gameEntity.getComponent("door") as DoorComponent;
                door.closeDoor();
              });

            }
          } else if (getDoorState(x, y) == DoorState.closing) {
            setDoorOffset(x, y, getDoorOffset(x, y) - RenderPerformance.deltaTime / 100);

            if (this.getDoorOffset(x, y) < 0) {
              this.setDoorOffset(x, y, 0);
              this.setDoorState(x, y, DoorState.closed);

              DoorComponent door  = gameEntity.getComponent("door") as DoorComponent;
              door.closeDoor();
            }
          }
        } else if (gameEntity.hasComponent("pushWall")) {
          if (getDoorState(x, y) == DoorState.opening) {
            setDoorOffset(x, y, getDoorOffset(x, y) + RenderPerformance.deltaTime / 100);

            if (getDoorOffset(x, y) > 2) {
              setDoorOffset(x, y, 2);
              setDoorState(x, y, DoorState.open);

              PushWallComponent pushWall  = gameEntity.getComponent("pushWall") as PushWallComponent;
              pushWall.openWall();
            }
          }
        }
      }
    }


  }

  GameEntity getEntityAtPosition(int x, int y) {
    return _gameMap[x + (y * _worldWidth)];
  }

  DoorState getDoorState(int x, int y) {
    return _doorStates[x + (y * _worldWidth)];
  }

  num getDoorOffset(int x, int y) {
    return _doorOffsets[x + (y * _worldWidth)];
  }

  void setDoorState(int x, int y, DoorState state) {
    _doorStates[x + (y * _worldWidth)] = state;
  }

  void setDoorOffset(int x, int y, num offset) {
    _doorOffsets[x + (y * _worldWidth)] = offset;
  }




  List<GameEntity> get gameMap => _gameMap;

}
