import 'package:flutter/material.dart';
import 'package:pong_minim/gameModes/pongGame.dart';
import 'package:pong_minim/vector2.dart';

class PongGamePractice extends PongGame {
  PongGamePractice({required super.onResetGame, required super.key});

  @override
  PongGamePracticeState createState() => PongGamePracticeState();
}

class PongGamePracticeState extends PongGameState {
  @override
  void updateGame(timer) {
    enemyPos.x = ballPos.x;
    super.updateGame(timer);
  }
}
