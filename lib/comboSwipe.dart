import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ComboSwipe extends StatefulWidget {
  final bool isShowing;
  final bool isPortrait;
  final double x;
  final double y;
  final double cellWidth;
  final int selectedIndex;
  final bool isSwiping;
  final List<String> options;
  const ComboSwipe(
      {Key? key,
      required this.isShowing,
      required this.isPortrait,
      required this.x,
      required this.y,
      required this.cellWidth,
      required this.selectedIndex,
      required this.isSwiping,
      required this.options})
      : super(key: key);

  @override
  State<ComboSwipe> createState() => _ComboSwipeState();
}

class _ComboSwipeState extends State<ComboSwipe> {
  // variables
  double fontSize = 24.0;
  double selectedOpacity = 1.0;
  double unselectedOpacity = 0.0;
  double unselectedSwipingOpacity = 0.5;
  double opacitySpeed = 0.05;

  List<double> indexOpacity = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.options.length; i++) {
      indexOpacity.add(0.0);
    }
    indexOpacity[widget.selectedIndex] = selectedOpacity;
    Timer.periodic(Duration(milliseconds: 16), (timer) {
      for (int i = 0; i < widget.options.length; i++) {
        if (widget.selectedIndex == i) {
          indexOpacity[i] += opacitySpeed;
          if (indexOpacity[i] >= selectedOpacity) {
            indexOpacity[i] = selectedOpacity;
          }
        } else {
          if (widget.isSwiping) {
            if (indexOpacity[i] > unselectedSwipingOpacity) {
              indexOpacity[i] -= opacitySpeed;
            } else if (indexOpacity[i] <= unselectedSwipingOpacity) {
              indexOpacity[i] += opacitySpeed;
            }
          } else {
            if (indexOpacity[i] > unselectedOpacity) {
              indexOpacity[i] -= opacitySpeed;
              if (indexOpacity[i] <= unselectedOpacity) {
                indexOpacity[i] = unselectedOpacity;
              }
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> optionContainers = [];
    for (int i = 0; i < widget.options.length; i++) {
      optionContainers.add(Transform.translate(
                  offset: Offset(widget.cellWidth * i, 0),
                  child: SizedBox(
                    width: widget.cellWidth,
                    child: Text(
                      widget.options[i],
                      style: TextStyle(
                          fontSize: fontSize,
                          color:
                              Color.fromRGBO(255, 255, 255, indexOpacity[i])),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ));
    }
    return AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: widget.isShowing ? 1.0 : 0.0,
      child: Container(
        alignment: const Alignment(0, 0),
        child: Transform.rotate(
          angle: widget.isPortrait ? 0 : pi / 2,
          child: Transform.translate(
            offset: Offset(widget.x, widget.y),
            child: Stack(
              children: optionContainers,
            ),
          ),
        ),
      ),
    );
  }
}
