import '../engine/application/gameScreen.dart';
import '../engine/application/teenyTinyTwoDee.dart';
import 'screens/backStoryScreen.dart';
import 'screens/mainMenuScreen.dart';
import 'screens/planetSurfaceScreen.dart';
import 'screens/pressEnterScreen.dart';
import 'screens/scienceLabScreen.dart';
import 'screens/screens.dart';

class Game extends TeenyTinyTwoDeeApp {
  void init() {
    Map<String, GameScreen> gameScreens = {};

    gameScreens[Screens.pressEnter.name] = PressEnterScreen();
    gameScreens[Screens.backStory.name] = BackStoryScreen();
    gameScreens[Screens.mainMenu.name] = MainMenuScreen();
    gameScreens[Screens.planetSurface.name] = PlanetSurfaceScreen();
    gameScreens[Screens.scienceLab.name] = ScienceLabScreen();

    super.run(gameScreens, Screens.pressEnter.name);
  }
}
