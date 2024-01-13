import '../../engine/application/gameScreen.dart';
import '../../engine/ecs/components/animatedSpriteComponent.dart';
import '../../engine/ecs/components/cameraComponent.dart';
import '../../engine/ecs/components/doorComponent.dart';
import '../../engine/ecs/components/floorComponent.dart';
import '../../engine/ecs/components/properties/canDamageComponent.dart';
import '../../engine/ecs/components/properties/canInteractComponent.dart';
import '../../engine/ecs/components/spriteComponent.dart';
import '../../engine/ecs/components/transparentComponent.dart';
import '../../engine/ecs/components/velocityComponent.dart';
import '../../engine/ecs/components/wallComponent.dart';
import '../../engine/ecs/gameEntity.dart';
import '../../engine/ecs/gameEntityBuilder.dart';
import '../../engine/ecs/system/render/rayCastRenderSystem.dart';
import '../../engine/gameEvent/gameEventBus.dart';
import '../../engine/gameEvent/screenChangeEvent.dart';
import '../../engine/input/mouse.dart';
import '../../engine/logger/logger.dart';
import '../../engine/primitives/color.dart';
import '../../engine/rendering/font.dart';
import '../../engine/rendering/rayCaster/camera.dart';
import '../../engine/rendering/rayCaster/worldMap.dart';
import '../../engine/rendering/renderer.dart';
import '../../engine/rendering/sprite.dart';
import '../../fonts.dart';
import '../components/oxygenComponent.dart';
import '../systems/rendering/airLockParticleRenderSystem.dart';
import '../systems/rendering/dustRenderSystem.dart';
import '../systems/rendering/helmetRenderSystem.dart';
import 'gameScreenBase.dart';
import 'screens.dart';

class ScienceLabScreen extends GameScreenBase implements GameScreen {
  num _alphaFade = 1;
  int _fadeTick = 0;
  final int _fadeRate = 16;

  @override
  void init() {
    createPlayer();
    audioManager.register("stepMetal", "../../assets/sound/stepMetal.wav");
    audioManager.register("airBlast", "../../assets/sound/airBlast.wav");
    audioManager.register("slidingDoor", "../../assets/sound/slidingDoor.wav");
    audioManager.register("stationHum", "../../assets/sound/stationHum.wav", true);

    registerRenderSystems([
       RayCastRenderSystem(),
       DustRenderSystem(),
       AirLockParticleRenderSystem()
    ]);

    registerPostRenderSystems([
       HelmetRenderSystem()
    ]);


    logger(LogType.info, "ScienceLab Initialized");
  }

  void createPlayer() {
    camera = Camera(6.5, 1.8, 0, 1, 0.66);

    player = GameEntityBuilder("player")
        .addComponent(createInventory())
        .addComponent(OxygenComponent(50, 100))
        .addComponent(CameraComponent(camera))
        .addComponent(VelocityComponent(0, 0))
        .build();
  }

  void createGameMap() {
    List<int> grid = [];

    int width = 20;
    int height = 20;

    grid = [
      1,
      1,
      1,
      1,
      1,
      1,
      21,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      16,
      16,
      16,
      16,
      4,
      0,
      4,
      11,
      0,
      0,
      6,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1,
      1,
      16,
      0,
      0,
      13,
      4,
      0,
      4,
      12,
      0,
      0,
      3,
      0,
      15,
      15,
      15,
      15,
      15,
      15,
      1,
      1,
      16,
      0,
      16,
      16,
      4,
      0,
      4,
      11,
      0,
      0,
      2,
      15,
      2,
      8,
      8,
      8,
      8,
      8,
      1,
      1,
      2,
      3,
      2,
      6,
      4,
      22,
      4,
      2,
      2,
      3,
      2,
      2,
      2,
      8,
      0,
      0,
      0,
      8,
      1,
      1,
      0,
      0,
      0,
      0,
      5,
      0,
      5,
      0,
      0,
      0,
      0,
      0,
      0,
      8,
      0,
      0,
      0,
      8,
      1,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      8,
      0,
      0,
      0,
      8,
      1,
      1,
      14,
      2,
      3,
      2,
      14,
      6,
      2,
      0,
      2,
      6,
      2,
      0,
      0,
      8,
      8,
      20,
      8,
      8,
      1,
      1,
      10,
      10,
      0,
      10,
      10,
      2,
      2,
      3,
      2,
      2,
      2,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1,
      1,
      10,
      0,
      0,
      0,
      10,
      2,
      0,
      0,
      2,
      2,
      2,
      2,
      6,
      2,
      2,
      3,
      2,
      2,
      1,
      1,
      10,
      0,
      0,
      0,
      10,
      2,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1,
      1,
      10,
      10,
      10,
      10,
      10,
      2,
      0,
      0,
      0,
      0,
      2,
      2,
      6,
      14,
      2,
      2,
      6,
      2,
      1,
      1,
      17,
      18,
      17,
      2,
      2,
      2,
      2,
      2,
      2,
      0,
      2,
      7,
      7,
      7,
      7,
      7,
      7,
      2,
      1,
      1,
      0,
      0,
      17,
      9,
      9,
      9,
      9,
      9,
      2,
      0,
      2,
      7,
      0,
      0,
      0,
      0,
      7,
      2,
      1,
      1,
      17,
      19,
      17,
      9,
      0,
      0,
      0,
      9,
      2,
      19,
      2,
      7,
      7,
      7,
      0,
      7,
      7,
      2,
      1,
      1,
      0,
      0,
      17,
      9,
      0,
      0,
      0,
      9,
      17,
      0,
      17,
      17,
      18,
      17,
      19,
      17,
      17,
      17,
      1,
      1,
      0,
      0,
      18,
      9,
      9,
      0,
      9,
      9,
      17,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1,
      1,
      0,
      0,
      17,
      17,
      17,
      19,
      17,
      17,
      17,
      18,
      17,
      17,
      14,
      17,
      19,
      17,
      14,
      17,
      1,
      1,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      17,
      0,
      0,
      0,
      0,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1,
      1
    ];

    WorldDefinition worldDefinition = WorldDefinition();

    worldDefinition.grid = grid;
    worldDefinition.skyColor = Colors.drkGray;
    worldDefinition.skyBox = null;
    worldDefinition.floorColor = Color(120, 120, 120);
    worldDefinition.translationTable = translationTable;
    worldDefinition.width = width;
    worldDefinition.height = height;
    worldDefinition.lightRange = 7;

    worldMap.loadMap(worldDefinition);
  }

  void createTranslationMap() {
    GameEntity floor =
        GameEntityBuilder("floor").addComponent(FloorComponent()).build();

    addEntity(0, floor);

    GameEntity wall = GameEntityBuilder("wall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/spaceStationWall.png")))
        .build();

    addEntity(1, wall);

    GameEntity innerLabWall = GameEntityBuilder("innerLabWall")
        .addComponent(WallComponent())
        .addComponent(CanDamageComponent(
            Sprite(0, 0, "../../assets/images/damageRock.png")))
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/innerLabWall.png")))
        .build();

    addEntity(2, innerLabWall);

    GameEntity labDoor = GameEntityBuilder("labDoor")
        .addComponent(DoorComponent())
        .addComponent(CanInteractComponent(() {
          audioManager.play("slidingDoor");
        }))
        .addComponent(
            SpriteComponent(Sprite(0, 0, "../../assets/images/labDoor.png")))
        .build();

    addEntity(3, labDoor);

    GameEntity airLock = GameEntityBuilder("airLock")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/airlock.png")))
        .build();

    addEntity(4, airLock);

    GameEntity airLockWarning = GameEntityBuilder("airLockWarning")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/airLockWarning.png")))
        .build();

    addEntity(5, airLockWarning);

    GameEntity airFilter = GameEntityBuilder("airFilter")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/airFilter.png")))
        .build();

    addEntity(6, airFilter);

    GameEntity workShopWall = GameEntityBuilder("workShopWall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/workShopWall.png")))
        .build();

    addEntity(7, workShopWall);

    GameEntity freezerWall = GameEntityBuilder("freezerWall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/freezerWall.png")))
        .build();

    addEntity(8, freezerWall);

    GameEntity generatorWall = GameEntityBuilder("generatorWall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/generatorWall.png")))
        .build();

    addEntity(9, generatorWall);

    GameEntity dataCenterWall = GameEntityBuilder("dataCenterWall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/dataCenterWall.png")))
        .build();

    addEntity(10, dataCenterWall);

    GameEntity kitchenCabinet = GameEntityBuilder("kitchenCabinet")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/kitchenCabinet.png")))
        .build();

    addEntity(11, kitchenCabinet);

    GameEntity kitchenOven = GameEntityBuilder("kitchenOven")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/kitchenOven.png")))
        .build();

    addEntity(12, kitchenOven);

    GameEntity bed = GameEntityBuilder("bed")
        .addComponent(WallComponent())
        .addComponent(
            SpriteComponent(Sprite(128, 128, "../../assets/images/bed.png")))
        .build();

    addEntity(13, bed);

    GameEntity glass = GameEntityBuilder("glass")
        .addComponent(WallComponent())
        .addComponent(TransparentComponent())
        .addComponent(
            SpriteComponent(Sprite(128, 128, "../../assets/images/glass.png")))
        .build();

    addEntity(14, glass);

    GameEntity plants = GameEntityBuilder("plants")
        .addComponent(WallComponent())
        .addComponent(
            SpriteComponent(Sprite(128, 128, "../../assets/images/plants.png")))
        .build();

    addEntity(15, plants);

    GameEntity bedRoom = GameEntityBuilder("bedRoom")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/bedRoom.png")))
        .build();

    addEntity(16, bedRoom);

    GameEntity backRoom = GameEntityBuilder("backRoom")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/backRoom.png")))
        .build();

    addEntity(17, backRoom);

    GameEntity backRoomFilter = GameEntityBuilder("backRoomFilter")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/backRoomFilter.png")))
        .build();

    addEntity(18, backRoomFilter);

    GameEntity backRoomDoor = GameEntityBuilder("backRoomDoor")
        .addComponent(WallComponent())
        .addComponent(DoorComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/backRoomDoor.png")))
        .build();

    addEntity(19, backRoomDoor);

    GameEntity freezerDoor = GameEntityBuilder("freezerDoor")
        .addComponent(WallComponent())
        .addComponent(DoorComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/freezerDoor.png")))
        .build();

    addEntity(20, freezerDoor);

    GameEntity airLockDoorInterior = GameEntityBuilder("airLockDoorInterior")
        .addComponent(WallComponent())
        .addComponent(CanInteractComponent(() {
          GameEventBus.publish(ScreenChangeEvent(Screens.planetSurface.name));
        }))
        .addComponent(AnimatedSpriteComponent(0, 0, [
          "../../assets/images/airLockDoorPowered.png",
          "../../assets/images/airLockDoorPowered1.png",
          "../../assets/images/airLockDoorPowered2.png",
          "../../assets/images/airLockDoorPowered3.png",
          "../../assets/images/airLockDoorPowered4.png",
          "../../assets/images/airLockDoorPowered5.png",
          "../../assets/images/airLockDoorPowered6.png",
          "../../assets/images/airLockDoorPowered7.png",
          "../../assets/images/airLockDoorPowered8.png",
          "../../assets/images/airLockDoorPowered8.png",
          "../../assets/images/airLockDoorPowered7.png",
          "../../assets/images/airLockDoorPowered6.png",
          "../../assets/images/airLockDoorPowered5.png",
          "../../assets/images/airLockDoorPowered4.png",
          "../../assets/images/airLockDoorPowered3.png",
          "../../assets/images/airLockDoorPowered2.png",
          "../../assets/images/airLockDoorPowered1.png"
        ]))
        .build();

    addEntity(21, airLockDoorInterior);

    GameEntity innerAirLock = GameEntityBuilder("innerAirLock")
        .addComponent(WallComponent())
        .addComponent(DoorComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/innerAirLock.png")))
        .build();

    addEntity(22, innerAirLock);

    GameEntity doorFrame  = GameEntityBuilder("doorFrame")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(Sprite(128, 128, "../../assets/images/doorFrame.png")))
        .build();

    gameEntityRegistry.registerSingleton(doorFrame);
  }


  @override
  void mouseClick(double x, double y, MouseButton mouseButton) {
    // TODO: implement mouseClick
  }

  @override
  void mouseMove(double x, double y) {
    // TODO: implement mouseMove
  }

  @override
  void onEnter() {
    createTranslationMap();
    createGameMap();

    walkSound = "stepMetal";
    audioManager.play("airBlast");
    audioManager.play("stationHum");
    logger(LogType.info, "Entered Science Lab Screen");

    player = gameEntityRegistry.getSingleton("player");
    camera = Camera(6.5, 1.8, 0, 1, 0.66);
    player.addComponent(CameraComponent(camera));
  }

  @override
  void onExit() {
    audioManager.play("airBlast");
    audioManager.stop("stationHum");
  }

  @override
  void renderLoop() {

    for (var renderSystem in renderSystems) {
      renderSystem.process();
    }

    for (var gameEntity in translationTable.values) {
      if (gameEntity.hasComponent("animatedSprite")) {
        AnimatedSpriteComponent animatedSprite = gameEntity
            .getComponent("animatedSprite") as AnimatedSpriteComponent;
        animatedSprite.nextFrame();
      }
    }

    sway();
    holdingItem();

    for (var renderSystem in postRenderSystems) {
      renderSystem.process();
    }

    title();

    wideScreen();
  }

  void title() {
    if (_alphaFade > 0.1) {

      _fadeTick++;

      if (_fadeTick == _fadeRate) {
        _fadeTick = 0;
        _alphaFade -= 0.19;
      }

      Renderer.print("Delta Lab", 50, 250, Font(
        Fonts.oxaniumBold.name,
        100,
        Color(0, 0, 0, _alphaFade)
      ));
    }
  }
}
