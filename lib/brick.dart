import 'package:flutter/material.dart';

class Brick extends StatelessWidget {
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final bool isInGame;

  Brick({required this.x,required this.y,required this.width,required this.height,required this.color,required this.isInGame});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: const Alignment(0, 0),
      child: Transform.translate(
        offset: Offset(x, y),
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: isInGame ? color : color.withAlpha(127),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 0.1,
                    blurStyle: BlurStyle.normal),
              ]),
        ),
      ),
    );
  }
}
