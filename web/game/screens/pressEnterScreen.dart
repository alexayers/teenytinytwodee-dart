import '../../engine/application/gameScreen.dart';
import '../../engine/gameEvent/gameEventBus.dart';
import '../../engine/gameEvent/screenChangeEvent.dart';
import '../../engine/input/keyboard.dart';
import '../../engine/input/mouse.dart';
import '../../engine/primitives/color.dart';
import '../../engine/rendering/font.dart';
import '../../engine/rendering/renderer.dart';
import '../../fonts.dart';
import 'screens.dart';

class PressEnterScreen implements GameScreen {
  @override
  void init() {
    // TODO: implement init
  }

  @override
  void keyboard() {
    if (isKeyDown(keyboardInput.enter)) {
      GameEventBus.publish(ScreenChangeEvent(Screens.mainMenu.name));
    }
  }

  @override
  void logicLoop() {
    keyboard();
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
    // TODO: implement onEnter
  }

  @override
  void onExit() {
    // TODO: implement onExit
  }

  @override
  void renderLoop() {
    Renderer.print(
        "Press enter to begin", 250, 50, Font(Fonts.oxanium.name, 20, Colors.white));

    Renderer.print(
        "Number keys navigate inventory", 250, 90, Font(Fonts.oxanium.name, 20, Colors.white));
    Renderer.print(
        "Space to interact or use", 250, 140, Font(Fonts.oxanium.name, 20, Colors.white));
  }
}
