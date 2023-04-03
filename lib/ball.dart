import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  final double x;
  final double y;
  final double radius;
  final bool isInGame;

  Ball({required this.x,required this.y,required this.radius,required this.isInGame});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, 0),
      child: Transform.translate(
        offset: Offset(x, y),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isInGame ? Colors.white : Colors.grey,
              boxShadow: const [
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 0.1,
                    blurStyle: BlurStyle.normal),
              ]),
          width: radius,
          height: radius,
        ),
      ),
    );
  }
}
