import '../../engine/application/gameScreen.dart';
import '../../engine/application/globalState.dart';
import '../../engine/ecs/components/cameraComponent.dart';
import '../../engine/ecs/components/doorComponent.dart';
import '../../engine/ecs/components/floorComponent.dart';
import '../../engine/ecs/components/interactionComponent.dart';
import '../../engine/ecs/components/spriteComponent.dart';
import '../../engine/ecs/components/velocityComponent.dart';
import '../../engine/ecs/components/wallComponent.dart';
import '../../engine/ecs/gameEntity.dart';
import '../../engine/ecs/gameEntityBuilder.dart';
import '../../engine/ecs/gameEntityRegistry.dart';
import '../../engine/ecs/gameRenderSystem.dart';
import '../../engine/ecs/gameSystem.dart';
import '../../engine/ecs/system/entity/cameraSystem.dart';
import '../../engine/ecs/system/entity/interactionSystem.dart';
import '../../engine/ecs/system/render/rayCastRenderSystem.dart';
import '../../engine/input/keyboard.dart';
import '../../engine/input/mouse.dart';
import '../../engine/logger/logger.dart';
import '../../engine/rendering/rayCaster/camera.dart';
import '../../engine/rendering/rayCaster/renderPerformance.dart';
import '../../engine/rendering/rayCaster/worldMap.dart';
import '../../engine/rendering/sprite.dart';

class MainScreen implements GameScreen {
  List<GameSystem> _gameSystems = [];
  List<GameRenderSystem> _gameRenderSystems = [];
  late GameEntity _player;
  final GameEntityRegistry _gameEntityRegistry = GameEntityRegistry.instance;
  final WorldMap _worldMap = WorldMap.instance;
  final num _fixedMovementSpeed = 0.065;

  @override
  void init() {
    _gameSystems.add(CameraSystem());
    _gameSystems.add(InteractionSystem());

    _gameRenderSystems.add(RayCastRenderSystem());

    GameEntity wall =
    GameEntityBuilder("wall").addComponent(WallComponent())
        .addComponent(
        SpriteComponent(Sprite(128, 128, "../../assets/wall.png")))
        .build();

    GameEntity floor =
    GameEntityBuilder("floor").addComponent(FloorComponent()).build();

    GameEntity door = GameEntityBuilder("door")
        .addComponent(DoorComponent())
        .addComponent(
        SpriteComponent(Sprite(128, 128, "../../assets/door.png")))
        .build();

    GameEntity doorFrame = GameEntityBuilder("doorFrame")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
        Sprite(128, 128, "../../assets/doorFrame.png")))
        .build();

    _gameEntityRegistry.registerSingleton(doorFrame);

    List<int> grid = [
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
      1, 0, 0, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 3, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 1, 0, 0, 0, 0, 1,
      1, 1, 1, 0, 1, 1, 1, 1, 1, 1,
      1, 0, 1, 0, 1, 0, 0, 0, 0, 1,
      1, 0, 1, 0, 1, 1, 1, 0, 0, 1,
      1, 0, 1, 0, 0, 0, 0, 0, 0, 1,
      1, 0, 0, 0, 1, 0, 1, 0, 0, 1,
      1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

    Map<int, GameEntity> translationTable = {};

    translationTable[3] = door;
    translationTable[1] = wall;
    translationTable[0] = floor;

    _worldMap.loadMap(grid, translationTable);

    _player = GameEntityBuilder("player")
        .addComponent(CameraComponent(Camera(2, 2, 0, 1, 0.66)))
        .addComponent(VelocityComponent(0, 0))
        .build();


    _gameEntityRegistry.registerSingleton(_player);
  }

  @override
  void keyboard() {
    num moveSpeed = _fixedMovementSpeed * RenderPerformance.deltaTime;
    num moveX = 0;
    num moveY = 0;

    GameEntity player = _gameEntityRegistry.getSingleton("player");
    CameraComponent camera = player.getComponent("camera") as CameraComponent;
    VelocityComponent velocity = player.getComponent(
        "velocity") as VelocityComponent;

    if (isKeyDown(keyboardInput.up)) {
      moveX += camera.camera.xDir;
      moveY += camera.camera.yDir;
    }

    if (isKeyDown(keyboardInput.down)) {
      moveX -= camera.camera.xDir;
      moveY -= camera.camera.yDir;
    }
    if (isKeyDown(keyboardInput.left)) {
      velocity.rotateLeft = true;
    }

    if (isKeyDown(keyboardInput.right)) {
      velocity.rotateRight = true;
    }

    if (isKeyDown(keyboardInput.space)) {
      player.addComponent(InteractionComponent());
    }

    moveX *= moveSpeed;
    moveY *= moveSpeed;

    velocity.velX = moveX;
    velocity.velY = moveY;
  }

  @override
  void logicLoop() {
    keyboard();

    for (var system in _gameSystems) {
      system.processEntity(_player);
    }
  }

  @override
  void mouseClick(double x, double y, MouseButton mouseButton) {
    logger(LogType.debug, "mouseClick");
  }

  @override
  void mouseMove(double x, double y) {
    logger(LogType.debug, "mouseMove");
  }

  @override
  void onEnter() {
    logger(LogType.debug, "onEnter");
  }

  @override
  void onExit() {
    logger(LogType.debug, "onExit");
  }

  @override
  void renderLoop() {
    for (var system in _gameRenderSystems) {
      system.process();
    }
  }
}
