import '../../engine/application/gameScreen.dart';
import '../../engine/ecs/components/animatedSpriteComponent.dart';
import '../../engine/ecs/components/cameraComponent.dart';
import '../../engine/ecs/components/damagedComponent.dart';
import '../../engine/ecs/components/floorComponent.dart';
import '../../engine/ecs/components/properties/canDamageComponent.dart';
import '../../engine/ecs/components/properties/canInteractComponent.dart';
import '../../engine/ecs/components/spriteComponent.dart';
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
import '../../engine/utils/mathUtils.dart';
import '../../fonts.dart';
import '../components/healthComponent.dart';
import '../components/hungerComponent.dart';
import '../components/oxygenComponent.dart';
import '../components/staminaComponent.dart';
import '../components/suitComponent.dart';
import '../components/whenDestroyedComponent.dart';
import '../components/whenRepairedComponent.dart';
import '../systems/rendering/helmetRenderSystem.dart';
import '../systems/rendering/stormRenderSystem.dart';
import 'gameScreenBase.dart';
import 'screens.dart';

class PlanetSurfaceScreen extends GameScreenBase implements GameScreen {
  num _alphaFade = 1;
  int _fadeTick = 0;
  int _fadeRate = 16;
  bool _firstEnter = true;

  @override
  void init() {
    audioManager.register("rockCrumble", "../../assets/sound/rockCrumble.wav");
    audioManager.register("drilling", "../../assets/sound/drilling.wav", true);
    audioManager.register("dirtStep", "../../assets/sound/stepDirt.wav");
    audioManager.register("error", "../../assets/sound/error.wav");
    audioManager.register("wind", "../../assets/sound/wind.wav", true);
    audioManager.register(
        "generatorRunning", "../../assets/sound/generatorRunning.wav", true);

    camera = Camera(67, 62, -0.66, 0.6, 0.66);

    player = GameEntityBuilder("player")
        .addComponent(createInventory())
        .addComponent(OxygenComponent(50, 100))
        .addComponent(SuitComponent(100, 100))
        .addComponent(HungerComponent(50, 100))
        .addComponent(StaminaComponent(50, 100))
        .addComponent(HealthComponent(50, 100))
        .addComponent(CameraComponent(camera))
        .addComponent(VelocityComponent(0, 0))
        .build();

    gameEntityRegistry.registerSingleton(player);

    registerRenderSystems([RayCastRenderSystem()]);

    registerPostRenderSystems([StormRenderSystem(), HelmetRenderSystem()]);
  }

  void createGameMap() {
    List<int> grid = [];

    for (int y = 0; y < 128; y++) {
      for (int x = 0; x < 128; x++) {
        if (y == 0 || y == 127 || x == 0 || x == 127) {
          grid.add(1);
        } else {
          if (MathUtils.getRandomBetween(1, 100) < 10) {
            grid.add(2);
          } else {
            grid.add(0);
          }
        }
      }
    }

    List<int> spaceStation = [
      7,
      0,
      0,
      0,
      0,
      3,
      3,
      5,
      3,
      3,
      3,
      0,
      0,
      0,
      3,
      3,
      0,
      0,
      0,
      3,
      3,
      3,
      3,
      3,
      3,
    ];

    int i = 0;
    int offsetY = 64;
    int offsetX = 64;
    int spaceStationWidth = 5;
    int spaceStationHeight = 5;

    for (int y = offsetY - 3; y < offsetY + spaceStationHeight + 3; y++) {
      for (int x = offsetX - 3; x < offsetX + spaceStationWidth + 3; x++) {
        int pos = x + (y * 128);
        grid[pos] = 0;
        i++;
      }
    }

    i = 0;

    for (int y = offsetY; y < offsetY + spaceStationHeight; y++) {
      for (int x = offsetX; x < offsetX + spaceStationWidth; x++) {
        int pos = x + (y * 128);
        grid[pos] = spaceStation[i];
        i++;
      }
    }

    WorldDefinition worldDefinition = WorldDefinition();

    worldDefinition.grid = grid;
    worldDefinition.skyColor = Colors.black;
    worldDefinition.skyBox = Sprite(512, 512, "../../assets/images/skyBox.png");
    worldDefinition.floorColor = Color(61, 27, 24);
    worldDefinition.translationTable = translationTable;
    worldDefinition.width = 128;
    worldDefinition.height = 128;
    worldDefinition.lightRange = 3.5;

    worldMap.loadMap(worldDefinition);
  }

  void createTranslationMap() {
    GameEntity floor =
        GameEntityBuilder("floor").addComponent(FloorComponent()).build();

    addEntity(0, floor);

    GameEntity wall = GameEntityBuilder("wall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/planetWall.png")))
        .build();

    addEntity(1, wall);

    GameEntity rock = GameEntityBuilder("rock")
        .addComponent(WallComponent())
        .addComponent(WhenDestroyedComponent(() {
          audioManager.play("rockCrumble");
        }))
        .addComponent(CanDamageComponent(
            Sprite(0, 0, "../../assets/images/damageRock.png")))
        .addComponent(
            SpriteComponent(Sprite(128, 128, "../../assets/images/rock.png")))
        .build();

    addEntity(2, rock);

    GameEntity spaceStationWall = GameEntityBuilder("spaceStationWall")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/spaceStationWall.png")))
        .build();

    addEntity(3, spaceStationWall);

    GameEntity airLockWarning = GameEntityBuilder("airLockWarning")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/airLockWarning.png")))
        .build();

    addEntity(4, airLockWarning);

    GameEntity airLockDoor = GameEntityBuilder("airLockDoorInterior")
        .addComponent(WallComponent())
        .addComponent(CanInteractComponent(() {
          GameEventBus.publish(ScreenChangeEvent(Screens.scienceLab.name));
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

    addEntity(5, airLockDoor);

    requiresPower.add(airLockDoor);

    GameEntity airLockComputer = GameEntityBuilder("airLockComputer")
        .addComponent(WallComponent())
        .addComponent(CanInteractComponent())
        .addComponent(AnimatedSpriteComponent(128, 128, [
          "../../assets/images/airLockComputer.png",
          "../../assets/images/airLockComputer1.png",
          "../../assets/images/airLockComputer2.png",
          "../../assets/images/airLockComputer3.png",
          "../../assets/images/airLockComputer4.png",
          "../../assets/images/airLockComputer5.png",
          "../../assets/images/airLockComputer6.png",
        ]))
        .build();

    addEntity(6, airLockComputer);

    GameEntity generator = GameEntityBuilder("generator")
        .addComponent(WallComponent())
        .addComponent(CanInteractComponent())
        .addComponent(CanDamageComponent(
            Sprite(0, 0, "../../assets/images/damagedGenerator.png")))
        .addComponent(WhenRepairedComponent(() {
          //   GlobalState.updateState("powerSupplyFunctional", true);
          audioManager.play("generatorRunning");
          logger(LogType.info, "Power restored");
        }))
        .addComponent(DamagedComponent(
            100, Sprite(128, 128, "../../assets/images/damagedGenerator.png")))
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/generator.png")))
        .build();

    addEntity(7, generator);

    GameEntity doorFrame = GameEntityBuilder("doorFrame")
        .addComponent(WallComponent())
        .addComponent(SpriteComponent(
            Sprite(128, 128, "../../assets/images/doorFrame.png")))
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
    audioManager.play("wind");
    createTranslationMap();
    createGameMap();
    walkSound = "dirtStep";

    if (_firstEnter) {
      camera = Camera(67, 62, -0.66, 0.6, 0.66);
      _firstEnter = false;
    } else {
      camera = Camera(66.39, 64.99, 0.696, -0.889, 0.66);
    }

    player.addComponent(CameraComponent(camera));
    createInventory();
  }

  @override
  void onExit() {
    audioManager.stop("wind");
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

    if (_alphaFade > 0.1) {
      _fadeTick++;

      if (_fadeTick == _fadeRate) {
        _fadeTick = 0;
        _alphaFade -= 0.09;
      }

      Renderer.print("The Outpost", 100, 250,
          Font(Fonts.oxaniumBold.name, 100, Color(255, 255, 255, _alphaFade)));
    }

    wideScreen();
  }
}
