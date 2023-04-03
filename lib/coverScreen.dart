import 'dart:math';

import 'package:flutter/material.dart';

class CoverScreen extends StatefulWidget {
  final bool gameHasStarted;
  final bool isPortrait;
  const CoverScreen(
      {super.key, required this.gameHasStarted, required this.isPortrait});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen> {
  double opacity = 1.0;
  int animationDuration = 1;
  double fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    startLooping();
  }

  @override
  void didUpdateWidget(CoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameHasStarted != widget.gameHasStarted) {
      checkGameState();
    }
  }

  void startLooping() async {
    while (mounted) {
      await Future.delayed(Duration(seconds: animationDuration));
      setState(() => opacity = opacity == 1.0 ? 0.25 : 1.0);
      if (widget.gameHasStarted) {
        opacity = 0.0;
        break;
      }
    }
  }

  void checkGameState() {
    if (widget.gameHasStarted) {
      opacity = 0.0;
    } else {
      opacity = 1.0;
      startLooping();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0.0, 0.0),
      child: Transform.rotate(
        angle: widget.isPortrait ? 0 : pi / 2,
        child: AnimatedOpacity(
          duration: Duration(seconds: animationDuration),
          opacity: opacity,
          curve: Curves.decelerate,
          child: Stack(
            children: [
              Transform.translate(
                offset: const Offset(0, 150),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 128,
                  child: const Text(
                    "↔",
                    style: TextStyle(
                      color: Color.fromARGB(124, 255, 255, 255),
                      fontSize: 48,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -130),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 128,
                  child: const Text(
                    "↕",
                    style: TextStyle(
                      color: Color.fromARGB(124, 255, 255, 255),
                      fontSize: 48,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
