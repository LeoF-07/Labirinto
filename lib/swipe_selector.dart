import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Classe SwipeSelector, implementa il selettore della difficoltà che funziona con gli swipe
class SwipeSelector extends StatefulWidget {
  const SwipeSelector({super.key});

  @override
  State<SwipeSelector> createState() => SwipeSelectorState();
}

class SwipeSelectorState extends State<SwipeSelector> {
  int index = 1;

  final List<String> items = ["Facile", "Medio", "Difficile"];
  TextStyle selectedTextStyle = TextStyle(fontSize: 30.w);
  TextStyle normalTextStyle = TextStyle(fontSize: 15.w);

  void selectNext() {
    setState(() {
      index = (index + 1) % items.length;
    });
  }

  void selectPrevious() {
    setState(() {
      index = (index - 1 + items.length) % items.length;
    });
  }

  double notSelectedWidth = 70.w;
  double notSelectedHeight = 50.h;
  double selectedWidth = 120.w;
  double selectedHeight = 50.h;


  @override
  Widget build(BuildContext context) {
    List<AnimatedPositioned> positioneds = [];

    List<double> offsets;

    if(index == 0){
      offsets = [150.w, 255.w, 320.w];
    } else if (index == 1){
      offsets = [90.w, 150.w, 260.w];
    } else {
      offsets = [30.w, 90.w, 150.w];
    }

    for (int i = 0; i < 3; i++) {
      positioneds.add(
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          left: offsets[i],
          height: index == i ? selectedHeight : notSelectedHeight,
          width: index == i ? selectedWidth : notSelectedWidth,
          child: Container(
            alignment: Alignment.centerLeft,
            //color: Colors.white,
            child: Text(
              items[i],
              style: index == i ? selectedTextStyle : normalTextStyle,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity;
        if (v == null) return;

        if (v < 0) selectNext();
        if (v > 0) selectPrevious();
      },
      child: Container(
        width: double.infinity,
        height: 50.h,
        margin: EdgeInsets.only(bottom: 50.h, left: 10.w, right: 10.w),
        decoration: BoxDecoration(color: Colors.orange, /*border: Border.all(width: 0.8.w),*/ borderRadius: BorderRadius.circular(10.w)),
        child: Stack(children: positioneds),
      ),
    );
  }

}