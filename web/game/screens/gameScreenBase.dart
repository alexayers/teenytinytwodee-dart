import 'dart:math';

import '../../engine/audio/audioManager.dart';
import '../../engine/ecs/components/cameraComponent.dart';
import '../../engine/ecs/components/holdingSpriteComponent.dart';
import '../../engine/ecs/components/interactions/interactingActionComponent.dart';
import '../../engine/ecs/components/inventoryComponent.dart';
import '../../engine/ecs/components/inventorySpriteComponent.dart';
import '../../engine/ecs/components/velocityComponent.dart';
import '../../engine/ecs/gameEntity.dart';
import '../../engine/ecs/gameEntityBuilder.dart';
import '../../engine/ecs/gameEntityRegistry.dart';
import '../../engine/ecs/gameRenderSystem.dart';
import '../../engine/ecs/gameSystem.dart';
import '../../engine/ecs/system/entity/cameraSystem.dart';
import '../../engine/ecs/system/entity/interactionSystem.dart';
import '../../engine/ecs/system/entity/pickUpDropSystem.dart';
import '../../engine/input/keyboard.dart';
import '../../engine/logger/logger.dart';
import '../../engine/primitives/color.dart';
import '../../engine/rendering/font.dart';
import '../../engine/rendering/rayCaster/camera.dart';
import '../../engine/rendering/rayCaster/renderPerformance.dart';
import '../../engine/rendering/rayCaster/worldMap.dart';
import '../../engine/rendering/renderer.dart';
import '../../engine/rendering/sprite.dart';
import '../../engine/utils/timerUtil.dart';
import '../../fonts.dart';
import '../components/drillComponent.dart';
import '../components/drillingActionComponent.dart';
import '../components/repairComponent.dart';
import '../systems/entity/drillSystem.dart';
import '../systems/entity/repairSystem.dart';

class GameScreenBase {
  late String walkSound;
  num _moveSpeed = 0.05;

  final AudioManager audioManager = AudioManager.instance;
  final GameEntityRegistry gameEntityRegistry = GameEntityRegistry.instance;
  final List<GameSystem> gameSystems = [];
  final List<GameRenderSystem> renderSystems = [];
  final List<GameRenderSystem> postRenderSystems = [];
  final WorldMap worldMap = WorldMap.instance;
  late GameEntity player;
  late Camera camera;

  num _moveSway = 0;
  bool _updateSway = false;
  late num _lastXPos;
  late num _lastYPos;
  int _moves = 0;
  List<GameEntity> requiresPower = [];
  bool _useTool = false;
  final Map<int, GameEntity> translationTable = {};
  final TimerUtil _walkTimer = TimerUtil(120);

  GameScreenBase() {
    registerSystems([
      CameraSystem(),
      InteractionSystem(),
      PickUpDropSystem(),
      RepairSystem(),
      DrillSystem()
    ]);

    audioManager.register("drill", "../../assets/sound/drill.wav");

    logger(LogType.info, "Systems registered");
  }

  void sway() {
    if (!_updateSway) {
      num sway = _moveSway % (pi * 2);
      num diff = 0;

      if (sway - pi <= 0) {
        diff = -pi / 30;
      } else {
        diff = pi / 30;
      }

      if (sway + diff < 0 || sway + diff > pi * 2) {
        _moveSway -= sway;
      } else {
        _moveSway += diff;
      }
      return;
    }

    if (_moves > 1) {
      _moveSway += pi / 25;
      _moveSway %= pi * 8;
    }
  }

  void keyboard() {
    num moveSpeed = _moveSpeed * RenderPerformance.deltaTime;
    num moveX = 0;
    num moveY = 0;

    GameEntity player = gameEntityRegistry.getSingleton("player");
    InventoryComponent inventory =
        player.getComponent("inventory") as InventoryComponent;
    CameraComponent camera = player.getComponent("camera") as CameraComponent;
    VelocityComponent velocity =
        player.getComponent("velocity") as VelocityComponent;

    if (isKeyDown(keyboardInput.one)) {
      inventory.currentItemIdx = 0;
    }

    if (isKeyDown(keyboardInput.two)) {
      inventory.currentItemIdx = 1;
    }

    if (isKeyDown(keyboardInput.three)) {
      inventory.currentItemIdx = 2;
    }

    if (isKeyDown(keyboardInput.four)) {
      inventory.currentItemIdx = 3;
    }

    if (isKeyDown(keyboardInput.five)) {
      inventory.currentItemIdx = 4;
    }

    if (isKeyDown(keyboardInput.six)) {
      inventory.currentItemIdx = 5;
    }

    if (isKeyDown(keyboardInput.up)) {
      moveX += camera.camera.xDir;
      moveY += camera.camera.yDir;
      _updateSway = true;
      _moves++;

      if (_walkTimer.hasTimePassed()) {
        _walkTimer.reset();
        audioManager.play(walkSound);
      }
    }

    if (isKeyDown(keyboardInput.down)) {
      moveX -= camera.camera.xDir;
      moveY -= camera.camera.yDir;
      _updateSway = true;
      _moves++;

      if (_walkTimer.hasTimePassed()) {
        _walkTimer.reset();
        audioManager.play(walkSound);
      }
    }

    if (isKeyDown(keyboardInput.left)) {
      velocity.rotateLeft = true;
    }

    if (isKeyDown(keyboardInput.right)) {
      velocity.rotateRight = true;
    }

    if (isKeyDown(keyboardInput.space)) {
      InventoryComponent inventory =
          player.getComponent("inventory") as InventoryComponent;
      GameEntity holdingItem = inventory.getCurrentItem()!;

      if (holdingItem.hasComponent("drill")) {
        player.addComponent(DrillingActionComponent());
        audioManager.play("drill");
        player.addComponent(InteractingActionComponent());
      } else {
        player.addComponent(InteractingActionComponent());
      }

      _useTool = true;
    }

    if (isKeyDown(keyboardInput.shift)) {
      moveX *= moveSpeed * 2;
      moveY *= moveSpeed * 2;
    } else {
      moveX *= moveSpeed;
      moveY *= moveSpeed;
    }

    velocity.velX = moveX;
    velocity.velY = moveY;

    _lastXPos = camera.camera.xPos;
    _lastYPos = camera.camera.yPos;
  }

  void logicLoop() {
    keyboard();

    for (var gameSystem in gameSystems) {
      if (gameSystem.shouldRun(player)) {
        gameSystem.processEntity(player);
      }
    }

    if (camera.xPos == _lastXPos && camera.yPos == _lastYPos) {
      _updateSway = false;
      _moves = 0;
    }
  }

  InventoryComponent createInventory() {
    InventoryComponent inventory = InventoryComponent(6);

    GameEntity drill = GameEntityBuilder("drill")
        .addComponent(DrillComponent(10))
        .addComponent(InventorySpriteComponent(
            Sprite(0, 0, "../../assets/images/tools/drillInventory.png")))
        .addComponent(HoldingSpriteComponent(
            Sprite(0, 0, "../../assets/images/tools/drill.png")))
        .build();

    GameEntity wrench = GameEntityBuilder("wrench")
        .addComponent(RepairComponent(50))
        .addComponent(InventorySpriteComponent(
            Sprite(0, 0, "../../assets/images/tools/wrenchInventory.png")))
        .addComponent(HoldingSpriteComponent(
            Sprite(0, 0, "../../assets/images/tools/wrench.png")))
        .build();

    inventory.addItem(drill);
    inventory.addItem(wrench);

    return inventory;
  }

  void holdingItem() {
    InventoryComponent inventory =
        player.getComponent("inventory") as InventoryComponent;
    GameEntity? holdingItem = inventory.getCurrentItem();

    if (holdingItem != null) {
      double xOffset = sin(_moveSway / 2) * 40;
      double yOffset = cos(_moveSway) * 30;

      HoldingSpriteComponent holdingItemSprite =
          holdingItem.getComponent("holdingSprite") as HoldingSpriteComponent;
      holdingItemSprite.sprite.render(280 + xOffset, 110 + yOffset, 512, 512);
    }
  }

  void addEntity(int id, GameEntity gameEntity) {
    translationTable[id] = gameEntity;
    gameEntityRegistry.register(gameEntity);
  }

  void wideScreen() {
    Renderer.rect(0, 0, Renderer.getCanvasWidth(), 40, Colors.black);

    Renderer.rect(0, Renderer.getCanvasHeight() - 40, Renderer.getCanvasWidth(),
        40, Colors.black);

    int offsetX = 550;
    int offsetY = 50;

    InventoryComponent inventory =
        player.getComponent("inventory") as InventoryComponent;
    int inventoryBoxSize = 32;

    for (int i = 0; i < inventory.maxItems; i++) {
      if (i == inventory.currentItemIdx) {
        Renderer.rect(offsetX - 1, Renderer.getCanvasHeight() - (offsetY + 1),
            inventoryBoxSize + 2, inventoryBoxSize + 2, Colors.white);
      } else {
        Renderer.rect(offsetX - 1, Renderer.getCanvasHeight() - (offsetY + 1),
            inventoryBoxSize + 2, inventoryBoxSize + 2, Colors.white);
      }

      Renderer.rect(offsetX, Renderer.getCanvasHeight() - offsetY,
          inventoryBoxSize, inventoryBoxSize, Color(190, 190, 190, 0.45));

      if (inventory.inventory[i] != null) {
        InventorySpriteComponent inventorySprite = inventory.inventory[i]!
            .getComponent("inventorySprite") as InventorySpriteComponent;
        Renderer.renderImage(
            inventorySprite.sprite.image,
            offsetX,
            Renderer.getCanvasHeight() - offsetY,
            inventoryBoxSize - 4,
            inventoryBoxSize - 4);
      }

      offsetX += inventoryBoxSize + 6;
    }
  }

  void debug() {
    Renderer.print("X: ${camera.xPos} Y: ${camera.yPos}", 10, 20,
        Font(Fonts.oxanium.name, 10, Colors.white));
    Renderer.print("dirX: ${camera.xDir} dirY: ${camera.yDir}", 10, 40,
        Font(Fonts.oxanium.name, 10, Colors.white));
  }

  void registerSystems(List<GameSystem> systems) {
    for (var systems in gameSystems) {
      gameSystems.add(systems);
    }
  }

  void registerRenderSystems(List<GameRenderSystem> gameRenderSystems) {
    for (var gameRenderSystem in gameRenderSystems) {
      renderSystems.add(gameRenderSystem);
    }
  }

  void registerPostRenderSystems(List<GameRenderSystem> gameRenderSystems) {
    for (var gameRenderSystem in gameRenderSystems) {
      postRenderSystems.add(gameRenderSystem);
    }
  }
}
