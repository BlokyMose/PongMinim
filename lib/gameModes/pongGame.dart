import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pong_minim/ball.dart';
import 'package:pong_minim/brick.dart';
import 'package:pong_minim/vector2.dart';

enum WinState { none, player, enemy }

enum Direction { up, down, right, left }

class PongGame extends StatefulWidget {
  const PongGame({
    required super.key,
    required this.onResetGame,
  });

  final Function onResetGame;

  @override
  State<PongGame> createState() => PongGameState();
}

class PongGameState extends State<PongGame> {
  // in-game: data handlers
  bool isAwaken = false;
  bool isGameStarted = false;
  Size screenSize = const Size(1080, 1920);
  WinState winner = WinState.none;

  // update game: data handlers
  DateTime previousFrameTime = DateTime.now();
  double deltaTime = 0.0;

  // update game: constants
  double maxDeltaTime = 0.1;
  final brickAudioPlayer = AudioPlayer();
  final brickAudioSource = AssetSource("sfx/tap_2.mp3");
  final brickAudioVolume = 0.15;

  final borderAudioPlayer = AudioPlayer();
  final borderAudioSource = AssetSource("sfx/tap.mp3");
  final borderAudioVolume = 0.35;

  // bricks: constants
  double brickYRatio = 0.8;
  Vector2 brickSize = Vector2(100, 10);
  Color brickColor = Colors.white;

  // player: data handlers
  Vector2 playerPos = Vector2(0, 0);
  double playerVelocity = 0.0;

  // enemy: data handlers
  Vector2 enemyPos = Vector2(0, 0);
  double enemyVelocity = 0.0;

  // ball: data handlers
  Vector2 ballPos = Vector2(0, 0);
  Direction ballXDirection = Direction.right;
  Direction ballYDirection = Direction.down;

  // ball: constants
  double ballRadius = 15.0;
  double ballSpeed = 300;
  double ballSpeedFactor = 10;

  double borderBouncyVelocity = 300;
  double velocityFriction = 0.9;

  // Game Methods
  void awakeGame() {
    if (isAwaken) return;
    isAwaken = true;

    // Set initial variables
    screenSize = MediaQuery.of(context).size;
    playerPos.y = screenSize.height * brickYRatio / 2;
    enemyPos.y = -screenSize.height * brickYRatio / 2;
  }

  void startGame(int ballSpeedBase) {
    if (isGameStarted) return;
    isGameStarted = true;
    ballSpeed = ballSpeedBase * ballSpeedFactor;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() => updateGame(timer));
    });
  }

  void updateGame(timer) {
    updateDeltaTime();
    updateBricksVelocity();
    boundBricksToBorders();

    // Update ball
    ballYDirection = getBallYDirection();
    ballXDirection = getBallXDirection();
    ballPos += moveBallBy(ballXDirection, ballYDirection);

    winner = getWinner();
    if (winner != WinState.none) {
      timer.cancel();
      widget.onResetGame();
    }
  }

  void resetGame() {
    setState(() {
      isGameStarted = false;
      ballPos = Vector2.zero();
      playerPos.x = 0.0;
      enemyPos.x = 0.0;
      ballXDirection =
          Random().nextInt(2) == 0 ? Direction.right : Direction.left;
      ballYDirection = Random().nextInt(2) == 0 ? Direction.up : Direction.down;
    });
  }

  void updateDeltaTime() {
    deltaTime =
        DateTime.now().difference(previousFrameTime).inMilliseconds / 1000;
    deltaTime = deltaTime > maxDeltaTime ? maxDeltaTime : deltaTime;
    previousFrameTime = DateTime.now();
  }

  void updateBricksVelocity() {
    playerPos.x += playerVelocity * deltaTime;
    playerVelocity *= velocityFriction;

    enemyPos.x += enemyVelocity * deltaTime;
    enemyVelocity *= velocityFriction;
  }

  void boundBricksToBorders() {
    if (playerPos.x > screenSize.width / 2 + brickSize.x / 2) {
      playerPos.x = screenSize.width / 2 + brickSize.x / 2;
    } else if (playerPos.x < -screenSize.width / 2 - brickSize.x / 2) {
      playerPos.x = -screenSize.width / 2 - brickSize.x / 2;
    }

    if (playerPos.x + brickSize.x / 2 > screenSize.width / 2) {
      playerVelocity = -borderBouncyVelocity;
    } else if (playerPos.x - brickSize.x / 2 < -screenSize.width / 2) {
      playerVelocity = borderBouncyVelocity;
    }

    if (enemyPos.x > screenSize.width / 2 + brickSize.x / 2) {
      enemyPos.x = screenSize.width / 2 + brickSize.x / 2;
    } else if (enemyPos.x < -screenSize.width / 2 - brickSize.x / 2) {
      enemyPos.x = -screenSize.width / 2 - brickSize.x / 2;
    }

    if (enemyPos.x + brickSize.x / 2 > screenSize.width / 2) {
      enemyVelocity = -borderBouncyVelocity;
    } else if (enemyPos.x - brickSize.x / 2 < -screenSize.width / 2) {
      enemyVelocity = borderBouncyVelocity;
    }
  }

  Direction getBallYDirection() {
    if (ballPos.y + ballRadius / 2 >= playerPos.y - brickSize.y &&
        ballPos.y - ballRadius / 2 <= playerPos.y + brickSize.y &&
        playerPos.x - (brickSize.x / 2) <= ballPos.x &&
        playerPos.x + (brickSize.x / 2) >= ballPos.x) {
      onBallChangeDirection(Direction.up);
      brickAudioPlayer.play(brickAudioSource, volume: brickAudioVolume);
      return Direction.up;
    } else if (ballPos.y + ballRadius / 2 >= enemyPos.y - brickSize.y &&
        ballPos.y - ballRadius / 2 <= enemyPos.y + brickSize.y &&
        enemyPos.x - (brickSize.x / 2) <= ballPos.x &&
        enemyPos.x + (brickSize.x / 2) >= ballPos.x) {
      onBallChangeDirection(Direction.down);
      brickAudioPlayer.play(brickAudioSource, volume: brickAudioVolume);
      return Direction.down;
    } else {
      return ballYDirection;
    }
  }

  Direction getBallXDirection() {
    if (ballPos.x + ballRadius / 2 >= screenSize.width / 2) {
      onBallChangeDirection(Direction.left);
      borderAudioPlayer.play(borderAudioSource, volume: borderAudioVolume);
      return Direction.left;
    } else if (ballPos.x - ballRadius / 2 <= -screenSize.width / 2) {
      onBallChangeDirection(Direction.right);
      borderAudioPlayer.play(borderAudioSource, volume: borderAudioVolume);
      return Direction.right;
    } else {
      return ballXDirection;
    }
  }

  Vector2 moveBallBy(Direction xDirection, Direction yDirection) {
    Vector2 moveDelta = Vector2.zero();
    if (yDirection == Direction.down) {
      moveDelta.y += ballSpeed * deltaTime;
    } else if (yDirection == Direction.up) {
      moveDelta.y -= ballSpeed * deltaTime;
    }

    if (xDirection == Direction.left) {
      moveDelta.x -= ballSpeed * deltaTime;
    } else if (xDirection == Direction.right) {
      moveDelta.x += ballSpeed * deltaTime;
    }

    return moveDelta;
  }

  WinState getWinner() {
    if (ballPos.y >= screenSize.height / 2 + ballRadius) {
      return WinState.enemy;
    } else if (ballPos.y < -screenSize.height / 2 - ballRadius) {
      return WinState.player;
    } else {
      return WinState.none;
    }
  }

  void moveBricksByHorizontalDrag(double positionY, double delta) {
    setState(() {
      if (positionY > screenSize.height / 2) {
        playerPos.x += delta;
        playerVelocity = 0.0;
      } else if (positionY < screenSize.height / 2) {
        enemyPos.x += delta;
        enemyVelocity = 0.0;
      }
    });
  }

  void onBallChangeDirection(Direction newDirection) {}

  @override
  Widget build(BuildContext context) {
    awakeGame();
    return Stack(
      children: [
        Brick(
            x: enemyPos.x,
            y: enemyPos.y,
            width: brickSize.x,
            height: brickSize.y,
            color: brickColor,
            isInGame: isGameStarted),
        Brick(
            x: playerPos.x,
            y: playerPos.y,
            width: brickSize.x,
            height: brickSize.y,
            color: brickColor,
            isInGame: isGameStarted),
        Ball(
            x: ballPos.x,
            y: ballPos.y,
            radius: ballRadius,
            isInGame: isGameStarted)
      ],
    );
  }
}
