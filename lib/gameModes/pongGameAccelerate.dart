import 'package:flutter/material.dart';
import 'package:pong_minim/gameModes/pongGame.dart';
import 'package:pong_minim/vector2.dart';

class PongGameAccelerate extends PongGame {
  PongGameAccelerate({required super.onResetGame, required super.key});

  @override
  PongGameAccelerateState createState() => PongGameAccelerateState();
}

class PongGameAccelerateState extends PongGameState {
  double acceleration = 10.0;
  late double acceleratedBallSpeed;

  @override
  Color get brickColor => Colors.deepOrange.shade300;

  @override
  double get ballSpeed => acceleratedBallSpeed;

  @override
  void startGame(int ballSpeedBase) {
    acceleratedBallSpeed = super.ballSpeed;
    super.startGame(ballSpeedBase);
  }

  @override
  void onBallChangeDirection(Direction newDirection) {
    acceleratedBallSpeed += acceleration;
  }
}
