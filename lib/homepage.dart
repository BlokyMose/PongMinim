import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:pong_minim/ball.dart';
import 'package:pong_minim/brick.dart';
import 'package:pong_minim/comboSwipe.dart';
import 'package:pong_minim/coverScreen.dart';
import 'package:pong_minim/gameModes/pongGameInvert.dart';
import 'package:pong_minim/gameModes/pongGamePractice.dart';
import 'package:pong_minim/vector2.dart';
import 'package:pong_minim/gameModes/pongGame.dart';
import 'package:pong_minim/gameModes/pongGameAccelerate.dart';
import 'package:audioplayers/audioplayers.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

enum PongModeEnum { classic, accelerate, inverted, practice }

class HomePageState extends State<HomePage> {
  // out-game: constants
  final GlobalKey<PongGameState> pongGameClassicKey = GlobalKey();
  final GlobalKey<PongGameAccelerateState> pongGameAccelerateKey = GlobalKey();
  final GlobalKey<PongGameInvertState> pongGameInvertKey = GlobalKey();
  final GlobalKey<PongGamePracticeState> pongGamePracticeKey = GlobalKey();
  final bgm = AssetSource("bgm/Ambiment.mp3");
  final bgmVolume = 0.15;
  final creditDeveloper = "Raynhard M. Kemal";
  final creditBGM = '"Ambiment" Kevin MacLeod (incompetech.com)';
  final creditCCBY =
      'Licensed under Creative Commons: By Attribution 4.0 License\nhttp://creativecommons.org/licenses/by/4.0/';

  // out-game: data handlers
  GlobalKey<PongGameState> pongGameKey = GlobalKey();
  PongModeEnum pongMode = PongModeEnum.classic;
  bool isPortrait = true;
  bool isDragging = false;
  bool isInGame = false;

  // in-game data
  int ballSpeedBase = 30;
  int ballSpeedBaseMax = 100;
  int ballSpeedBaseMin = 10;

  // out-game: constants
  Duration resetDuration = const Duration(seconds: 1);
  Duration pongGameOpacityDuration = const Duration(seconds: 1);

  // ui: data handlers
  double appOpacity = 1.0;
  double pongGameOpacity = 1.0;
  double creditOpacity = 1.0;
  Vector2 modeSliderPos = Vector2(0, 100.0);
  int pongModeIndex = 0;

  // ui : constants
  final double pongModeSpeed = 200.0;
  final double pongModeSwipeDistance = 200.0;

  // update ui: data handlers
  DateTime previousFrameTimeUI = DateTime.now();
  double deltaTimeUI = 0.0;

  // update ui: constants
  final double velocityFrictionUI = 0.9;
  final double maxDeltaTimeUI = 0.1;

  @override
  void initState() {
    super.initState();
    AudioPlayer bgmPlayer = AudioPlayer();
    bgmPlayer.setReleaseMode(ReleaseMode.loop);
    bgmPlayer.play(bgm, volume: bgmVolume);

    // Set isPortrait event
    accelerometerEvents.listen((event) {
      setState(() {
        double x = event.x.abs();
        double y = event.y.abs();

        if ((x - y).abs() > 4.5) {
          isPortrait = !(x > y);
        }
      });
    });

    Future.delayed(const Duration(seconds: 2), () => creditOpacity = 0.0);

    // Update UI
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() => updateUI(timer));
    });
  }

  // UI Methods
  void updateUI(timer) {
    updateDeltaTimeUI();
    updatePongModeX();
  }

  void updateDeltaTimeUI() {
    deltaTimeUI =
        DateTime.now().difference(previousFrameTimeUI).inMilliseconds / 1000;
    deltaTimeUI = deltaTimeUI > maxDeltaTimeUI ? maxDeltaTimeUI : deltaTimeUI;
    previousFrameTimeUI = DateTime.now();
  }

  void updatePongModeX() {
    if (isDragging) return;

    pongModeIndex = ((-(modeSliderPos.x - (pongModeSwipeDistance / 2)) /
            pongModeSwipeDistance))
        .floor()
        .abs();

    if (pongModeIndex >= PongModeEnum.values.length) {
      pongModeIndex = PongModeEnum.values.length - 1;
    }

    switch (pongModeIndex) {
      case 1:
        pongGameKey = pongGameAccelerateKey;
        break;
      case 2:
        pongGameKey = pongGameInvertKey;
        break;
      case 3:
        pongGameKey = pongGamePracticeKey;
        break;
      default:
        pongGameKey = pongGameClassicKey;
    }

    double targetX = -pongModeIndex * pongModeSwipeDistance;
    if ((modeSliderPos.x - targetX).abs() < 5) {
      modeSliderPos.x = targetX;
    } else {
      if (modeSliderPos.x < targetX) {
        modeSliderPos.x += pongModeSpeed * deltaTimeUI;
      } else if (modeSliderPos.x > targetX) {
        modeSliderPos.x -= pongModeSpeed * deltaTimeUI;
      }
    }
  }

  void onTap() {
    if (isInGame) return;
    setState(() {
      isInGame = true;
      pongGameKey.currentState?.startGame(ballSpeedBase);
    });
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      isDragging = true;
      if (!isInGame) {
        if (isPortrait) {
          onSlidePongMode(details.delta.dx);
        } else {
          ballSpeedBase += details.delta.dx.round();
          ballSpeedBase = boundBallSpeedBase(ballSpeedBase);
        }
      } else {
        pongGameKey.currentState?.moveBricksByHorizontalDrag(
            details.globalPosition.dy, details.delta.dx);
      }
    });
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      isDragging = true;
      if (!isInGame) {
        if (!isPortrait) {
          onSlidePongMode(details.delta.dy);
        } else {
          ballSpeedBase -= details.delta.dy.round();
          ballSpeedBase = boundBallSpeedBase(ballSpeedBase);
        }
      }
    });
  }

  int boundBallSpeedBase(int ballSpeedBase) {
    if (ballSpeedBase > ballSpeedBaseMax) {
      return ballSpeedBaseMax;
    } else if (ballSpeedBase < ballSpeedBaseMin) {
      return ballSpeedBaseMin;
    }
    return ballSpeedBase;
  }

  void onSlidePongMode(double delta) {
    modeSliderPos.x += delta;
    pongGameOpacity = 0.0;
    boundPongModeXToBorder();
  }

  void boundPongModeXToBorder() {
    if (modeSliderPos.x > pongModeSwipeDistance / 2) {
      modeSliderPos.x = pongModeSwipeDistance / 2;
    } else if (modeSliderPos.x <
        -pongModeSwipeDistance * (PongModeEnum.values.length) +
            (pongModeSwipeDistance / 2)) {
      modeSliderPos.x = -pongModeSwipeDistance * (PongModeEnum.values.length) +
          (pongModeSwipeDistance / 2);
    }
  }

  void onDragEnd(DragEndDetails details) {
    setState(() {
      pongGameOpacity = 1.0;
      isDragging = false;
    });
  }

  void onResetGame() async {
    setState(() {
      appOpacity = 0.0;
    });
    await Future.delayed(resetDuration);
    setState(() {
      appOpacity = 1.0;
      pongGameKey.currentState?.resetGame();
      isInGame = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    late Widget pongGame;
    switch (pongModeIndex) {
      case 1:
        pongGame = PongGameAccelerate(
          key: pongGameKey,
          onResetGame: onResetGame,
        );
        break;
      case 2:
        pongGame = PongGameInvert(
          key: pongGameKey,
          onResetGame: onResetGame,
        );
        break;
      case 3:
        pongGame = PongGamePractice(
          key: pongGameKey,
          onResetGame: onResetGame,
        );
        break;
      default:
        pongGame = PongGame(
          key: pongGameKey,
          onResetGame: onResetGame,
        );
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => onTap(),
        onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(details),
        onVerticalDragUpdate: (details) => onVerticalDragUpdate(details),
        onHorizontalDragEnd: (details) => onDragEnd(details),
        onVerticalDragEnd: (details) => onDragEnd(details),
        child: Scaffold(
          backgroundColor: Colors.grey[900],
          body: AnimatedOpacity(
            duration: resetDuration,
            opacity: appOpacity,
            curve: standardEasing,
            child: Center(
              child: Stack(
                children: [
                  CoverScreen(
                    isPortrait: isPortrait,
                    gameHasStarted: isInGame,
                  ),
                  Transform.rotate(
                    angle: isPortrait ? 0 : pi / 2,
                    child: AnimatedOpacity(
                      duration: const Duration(seconds: 1),
                      opacity: !isInGame ? 1 : 0,
                      child: Container(
                        alignment: const Alignment(0, 0),
                        child: Transform.translate(
                          offset: const Offset(0, -100),
                          child: RichText(
                              text: TextSpan(
                                  text: ballSpeedBase.toString(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24),
                                  children: const [
                                TextSpan(
                                    text: " speed",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))
                              ])),
                        ),
                      ),
                    ),
                  ),
                  ComboSwipe(
                    isShowing: !isInGame,
                    isPortrait: isPortrait,
                    x: modeSliderPos.x,
                    y: modeSliderPos.y,
                    cellWidth: pongModeSwipeDistance,
                    selectedIndex: pongModeIndex,
                    isSwiping: isDragging && !isInGame,
                    options: PongModeEnum.values
                        .map((value) => value.toString().split('.').last)
                        .toList(),
                  ),
                  AnimatedOpacity(
                      duration: pongGameOpacityDuration,
                      opacity: pongGameOpacity,
                      child: pongGame),
                  AnimatedOpacity(
                    duration: const Duration(seconds: 2),
                    opacity: creditOpacity,
                    child: Container(
                      alignment: const Alignment(0, 0),
                      child: Transform.translate(
                        offset: Offset(0, 250),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              style: const TextStyle(
                                  color: Color.fromARGB(125, 255, 255, 255),
                                  fontSize: 12),
                              children: [
                                TextSpan(text: "dev:\n${creditDeveloper}\n\n"),
                                TextSpan(text: "bgm:\n${creditBGM}\n"),
                                TextSpan(
                                    text: creditCCBY,
                                    style: TextStyle(fontSize: 8)),
                              ]),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
