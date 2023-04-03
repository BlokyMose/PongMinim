import 'package:flutter/material.dart';
import 'package:pong_minim/gameModes/pongGame.dart';
import 'package:pong_minim/vector2.dart';

class PongGameInvert extends PongGame {
  PongGameInvert({required super.onResetGame, required super.key});

  @override
  PongGameInvertState createState() => PongGameInvertState();
}

class PongGameInvertState extends PongGameState {
  @override
  Color get brickColor => Colors.teal;

  @override
  void moveBricksByHorizontalDrag(double positionY, double delta) {
    super.moveBricksByHorizontalDrag(positionY, -delta);
  }
}
