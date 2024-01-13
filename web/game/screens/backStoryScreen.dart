import '../../engine/application/gameScreen.dart';
import '../../engine/audio/audioManager.dart';
import '../../engine/gameEvent/gameEventBus.dart';
import '../../engine/gameEvent/screenChangeEvent.dart';
import '../../engine/input/mouse.dart';
import '../../engine/primitives/color.dart';
import '../../engine/rendering/font.dart';
import '../../engine/rendering/renderer.dart';
import '../../fonts.dart';
import 'screens.dart';

class BackStoryScreen implements GameScreen {
  AudioManager audioManager = AudioManager.instance;
  int _characterPosition1 = 0;
  bool _startFadeOut = false;
  num _alphaFade = 0;
  int _visorLine = 0;
  int _tick = 0;
  final int _tickRate = 3;

  @override
  void init() {
    audioManager.register("message", "../../assets/sound/message.wav");
  }

  @override
  void keyboard() {
    // TODO: implement keyboard
  }

  @override
  void logicLoop() {
    // TODO: implement logicLoop
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
    audioManager.play("message");
  }

  @override
  void onExit() {
    // TODO: implement onExit
  }

  @override
  void renderLoop() {
    Renderer.rect(0, 0, Renderer.getCanvasWidth(), Renderer.getCanvasHeight(),
        Colors.black);

    int offsetY = 150;

    String line =
        "You are stranded on a small research outpost in the Vega Nexus system.";
    line +=
        " With limited resources and intense planetary storms your chance for rescue is slim.";
    line += " But not impossible...";
    String printLine = line.substring(0, _characterPosition1);

    _tick++;

    if (_tick == _tickRate && _characterPosition1 < line.length) {
      _tick = 0;
      _characterPosition1++;
    }

    if (_characterPosition1 >= line.length) {
      _startFadeOut = true;
    }

    List<String> lines = Renderer.getLines(printLine, 600);

    for (int i = 0; i < lines.length; i++) {
      Renderer.print(
          lines[i], 80, offsetY, Font(Fonts.oxanium.name, 16, Colors.white));
      offsetY += 30;
    }

    renderHelmetEffect();

    if (_startFadeOut) {
      _alphaFade += 0.01;
      Renderer.rect(0, 0, Renderer.getCanvasWidth(), Renderer.getCanvasHeight(),
          Color(112, 36, 21, _alphaFade));

      if (_alphaFade >= 1) {
        GameEventBus.publish(ScreenChangeEvent(Screens.planetSurface.name));
      }
    }
  }

  void renderHelmetEffect() {
    Color lineColor = Color(200, 240, 90, 0.223);

    for (int y = 0; y < Renderer.getCanvasHeight(); y += 64) {
      Renderer.line(0, y, Renderer.getCanvasWidth(), y, 1, lineColor);
    }

    for (int x = 0; x < Renderer.getCanvasWidth(); x += 64) {
      Renderer.line(x, 0, x, Renderer.getCanvasHeight(), 1, lineColor);
    }

    Renderer.rect(0, _visorLine, Renderer.getCanvasWidth(), 64, lineColor);
    _visorLine += 5;

    if (_visorLine > Renderer.getCanvasHeight()) {
      _visorLine = -100;
    }
  }
}
