import 'dart:math' as math;

import '../../ecs/components/animatedSpriteComponent.dart';
import '../../ecs/components/spriteComponent.dart';
import '../../ecs/gameEntity.dart';
import '../../ecs/gameEntityRegistry.dart';
import '../../logger/logger.dart';
import '../../primitives/color.dart';
import '../renderer.dart';
import '../sprite.dart';
import 'camera.dart';
import 'transparentWall.dart';
import 'worldMap.dart';

class RayCaster {
  final List<num> _cameraXCoords = [];
  final List<num> _zBuffer = [];
  final List<TransparentWall> _transparentWalls = [];
  final WorldMap worldMap = WorldMap.instance;

  RayCaster() {
    for (int x = 0; x < Renderer.getCanvasWidth(); x++) {
      double cameraX = 2 * x / Renderer.getCanvasWidth() - 1;
      _cameraXCoords.add(cameraX);
    }
  }

  void drawWall(Camera camera, int x) {
    WorldMap worldMap = WorldMap.instance;
    num rayDirX = camera.xDir + camera.xPlane * _cameraXCoords[x];
    num rayDirY = camera.yDir + camera.yPlane * _cameraXCoords[x];
    int mapX = camera.xPos.floor();
    int mapY = camera.yPos.floor();
    num sideDistX;
    num sideDistY;
    num deltaDistX = (1 / rayDirX).abs();
    num deltaDistY = (1 / rayDirY).abs();
    num perpWallDist = 0;
    int stepX;
    int stepY;
    int hit = 0;
    int side = 0;
    num wallXOffset = 0;
    num wallYOffset = 0;
    num wallX = 0;
    int rayTex = 0;
    GameEntity? gameEntity;

    if (rayDirX < 0) {
      stepX = -1;
      sideDistX = (camera.xPos - mapX) * deltaDistX;
    } else {
      stepX = 1;
      sideDistX = (mapX + 1.0 - camera.xPos) * deltaDistX;
    }
    if (rayDirY < 0) {
      stepY = -1;
      sideDistY = (camera.yPos - mapY) * deltaDistY;
    } else {
      stepY = 1;
      sideDistY = (mapY + 1.0 - camera.yPos) * deltaDistY;
    }

    while (hit == 0) {
      if (sideDistX < sideDistY) {
        sideDistX += deltaDistX;
        mapX += stepX;
        side = 0;
      } else {
        sideDistY += deltaDistY;
        mapY += stepY;
        side = 1;
      }

      gameEntity = worldMap.getEntityAtPosition(mapX, mapY);

      if (!gameEntity.hasComponent("floor")) {
        if (gameEntity.hasComponent("door") &&
            worldMap.getDoorState(mapX, mapY) != DoorState.open) {
          hit = 1;
          if (side == 1) {
            wallYOffset = 0.5 * stepY;
            perpWallDist =
                (mapY - camera.yPos + wallYOffset + (1 - stepY) / 2) / rayDirY;
            wallX = camera.xPos + perpWallDist * rayDirX;
            wallX -= wallX.floor();
            if (sideDistY - (deltaDistY / 2) < sideDistX) {
              if (1.0 - wallX <= worldMap.getDoorOffset(mapX, mapY)) {
                hit = 0;
                wallYOffset = 0;
              }
            } else {
              mapX += stepX;
              side = 0;
              rayTex = 4;
              wallYOffset = 0;
            }
          } else {
            wallXOffset = 0.5 * stepX;
            perpWallDist =
                (mapX - camera.xPos + wallXOffset + (1 - stepX) / 2) / rayDirX;
            wallX = camera.yPos + perpWallDist * rayDirY;
            wallX -= wallX.floor();
            if (sideDistX - (deltaDistX / 2) < sideDistY) {
              if (1.0 - wallX < worldMap.getDoorOffset(mapX, mapY)) {
                hit = 0;
                wallXOffset = 0;
              }
            } else {
              mapY += stepY;
              side = 1;
              rayTex = 4;
              wallXOffset = 0;
            }
          }
        } else if (gameEntity.hasComponent("pushWall") &&
            worldMap.getDoorState(mapX, mapY) != DoorState.open) {
          if (side == 1 &&
              sideDistY -
                      (deltaDistY * (1 - worldMap.getDoorOffset(mapX, mapY))) <
                  sideDistX) {
            hit = 1;
            wallYOffset = worldMap.getDoorOffset(mapX, mapY) * stepY;
          } else if (side == 0 &&
              sideDistX -
                      (deltaDistX * (1 - worldMap.getDoorOffset(mapX, mapY))) <
                  sideDistY) {
            hit = 1;
            wallXOffset = worldMap.getDoorOffset(mapX, mapY) * stepX;
          }
        } else if (gameEntity.hasComponent("transparentWall")) {
          if (side == 1) {
            if (sideDistY - (deltaDistY / 2) < sideDistX) {
              bool wallDefined = false;
              for (int i = 0; i < _transparentWalls.length; i++) {
                if (_transparentWalls[i].xMap == mapX &&
                    _transparentWalls[i].yMap == mapY) {
                  _transparentWalls[i].cameraXCoords.add(x);
                  wallDefined = true;
                  break;
                }
              }
              if (!wallDefined) {
                TransparentWall tpWall = TransparentWall(
                    camera, mapX, mapY, side, x, _cameraXCoords);
                _transparentWalls.add(tpWall);
              }
            }
          } else {
            if (sideDistX - (deltaDistX / 2) < sideDistY) {
              bool wallDefined = false;
              for (int i = 0; i < _transparentWalls.length; i++) {
                if (_transparentWalls[i].xMap == mapX &&
                    _transparentWalls[i].yMap == mapY) {
                  _transparentWalls[i].cameraXCoords.add(x);
                  wallDefined = true;
                  break;
                }
              }
              if (!wallDefined) {
                TransparentWall tpWall = TransparentWall(
                    camera, mapX, mapY, side, x, _cameraXCoords);
                _transparentWalls.add(tpWall);
              }
            }
          }
        } else if (!gameEntity.hasComponent("door") &&
            !gameEntity.hasComponent("pushWall")) {
          GameEntity adjacentGameEntityUp =
              worldMap.getEntityAtPosition(mapX, mapY - stepY);
          GameEntity adjacentGameEntityAcross =
              worldMap.getEntityAtPosition(mapX - stepX, mapY);

          if (side == 1 && adjacentGameEntityUp.hasComponent("door")) {
            rayTex = 4;
          } else if (side == 0 &&
              adjacentGameEntityAcross.hasComponent("door")) {
            rayTex = 4;
          }

          hit = 1;
        }
      }
    }

    perpWallDist = calculatePerpWall(side, mapX, mapY, camera, wallXOffset,
        wallYOffset, stepX, stepY, rayDirX, rayDirY);

    int lineHeight = (Renderer.getCanvasHeight() / perpWallDist).round();
    double drawStart =
        -lineHeight / 2 + (Renderer.getCanvasHeight() / 2).round();

    if (side == 0) {
      wallX = camera.yPos + perpWallDist * rayDirY;
    } else if (side == 1 || side == 2) {
      wallX = camera.xPos + perpWallDist * rayDirX;
    }

    wallX -= wallX.floor();

    if (gameEntity!.hasComponent("door")) {
      wallX += worldMap.getDoorOffset(mapX, mapY);
    }

    // Swap texture out for door frame
    if (rayTex == 4) {
      gameEntity = GameEntityRegistry.instance.getSingleton("doorFrame");
    }

    SpriteComponent sprite;
    Sprite wallTexture;

    if (gameEntity.hasComponent("sprite")) {
      sprite = gameEntity.getComponent("sprite") as SpriteComponent;
      wallTexture = sprite.sprite;
    } else if (gameEntity.hasComponent("animatedSprite")) {
      AnimatedSpriteComponent animatedSprite  = gameEntity.getComponent("animatedSprite") as AnimatedSpriteComponent;
      wallTexture = animatedSprite.currentSprite();
    } else {
      // throw new Error("No gameEntity found");
      return;
    }

    int texX = (wallX * wallTexture.image.width!).floor();
    if (side == 0 && rayDirX > 0) {
      texX = wallTexture.image.width! - texX - 1;
    } else if (side == 1 && rayDirY < 0) {
      texX = wallTexture.image.width! - texX - 1;
    }

    Renderer.renderClippedImage(wallTexture.image, texX, 0, 1,
        wallTexture.image.height!, x, drawStart, 1, lineHeight);
    renderShadows(perpWallDist, x, drawStart, lineHeight);

    _zBuffer.add(perpWallDist);
  }

  void renderShadows(num perpWallDist, int x, num drawStart, int lineHeight) {
    double lightRange = 6;
    double calculatedAlpha = math.max((perpWallDist + 0.002) / lightRange, 0);

    Renderer.rect(x.toInt(), drawStart.toInt(), 1, lineHeight + 1,
        Color(0, 0, 0, calculatedAlpha));
  }

  double calculatePerpWall(
      int side,
      int mapX,
      int mapY,
      Camera camera,
      num wallXOffset,
      num wallYOffset,
      int stepX,
      int stepY,
      num rayDirX,
      num rayDirY) {
    double perpWallDist = 0;

    if (side == 0) {
      perpWallDist =
          (mapX - camera.xPos + wallXOffset + (1 - stepX) / 2) / rayDirX;
    } else if (side == 1) {
      perpWallDist =
          (mapY - camera.yPos + wallYOffset + (1 - stepY) / 2) / rayDirY;
    }

    return perpWallDist;
  }

  void drawSpritesAndTransparentWalls(Camera camera) {}

  void drawSkyBox(Color groundColor, Color skyColor) {
    // Sky
    final skyBox = worldMap.worldDefinition.skyBox;

    if (skyBox != null) {
      Renderer.renderImage(skyBox.image, 0, 0, Renderer.getCanvasWidth(), Renderer.getCanvasHeight());
    } else {
      // Sky
      Renderer.rect(0, 0, Renderer.getCanvasWidth(), Renderer.getCanvasHeight() / 2, worldMap.worldDefinition.skyColor);

    }

    // Ground
    Renderer.rect(0, Renderer.getCanvasHeight() / 2, Renderer.getCanvasWidth(), Renderer.getCanvasHeight(), worldMap.worldDefinition.floorColor);
  }

  void combSort(List<int> order, List<double> dist) {
    int amount = order.length;
    int gap = amount;
    bool swapped = false;

    while (gap > 1 || swapped) {
      gap = (gap * 10) ~/ 13; // Integer division
      if (gap == 9 || gap == 10) {
        gap = 11;
      }
      if (gap < 1) {
        gap = 1;
      }
      swapped = false;
      for (int i = 0; i < amount - gap; i++) {
        int j = i + gap;

        if (dist[i] < dist[j]) {
          var tempDist = dist[i];
          dist[i] = dist[j];
          dist[j] = tempDist;

          var tempOrder = order[i];
          order[i] = order[j];
          order[j] = tempOrder;

          swapped = true;
        }
      }
    }
  }
}
