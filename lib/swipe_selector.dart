import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum Direction {right, left}

class SwipeSelector extends StatefulWidget {
  const SwipeSelector({super.key});

  @override
  State<SwipeSelector> createState() => SwipeSelectorState();
}

class SwipeSelectorState extends State<SwipeSelector> {
  int index = 1;
  Direction direction = Direction.left;

  final List<String> items = ["Facile", "Medio", "Difficile"];
  TextStyle selectedTextStyle = TextStyle(fontSize: 30.w);
  TextStyle normalTextStyle = TextStyle(fontSize: 15.w);

  void selectNext() {
    setState(() {
      index = (index + 1) % items.length;
      direction = Direction.left;
      //shiftLeft();
    });
  }

  void selectPrevious() {
    setState(() {
      index = (index - 1 + items.length) % items.length;
      direction = Direction.right;
      //shiftRight();
    });
  }

  /*
  void shiftLeft() {
    setState(() {
      for (int i = 0; i < offsets.length; i++) {
        offsets[i] = offsets[i].translate(-50.w, 0.0);
      }
    });
  }

  void shiftRight() {
    setState(() {
      for (int i = 0; i < offsets.length; i++) {
        offsets[i] = offsets[i].translate(50.w, 0.0);
      }
    });
  }

  final List offsets = [
    Offset(80.w, 50.h),
    Offset(150.w, 50.h),
    Offset(260.w, 50.h)
  ];
  */

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
        /*
        Offset(150.w, 0.h),
        Offset(255.w, 0.h),
        Offset(320.w, 0.h)
        */
      //];
    } else if (index == 1){
      offsets = [90.w, 150.w, 260.w];
        /*
        Offset(90.w, 0.h),
        Offset(150.w, 0.h),
        Offset(260.w, 0.h)
      ];

         */
    } else {
      offsets = [30.w, 90.w, 150.w];
        /*
        Offset(30.w, 0.h),
        Offset(90.w, 0.h),
        Offset(150.w, 0.h)
      ];

         */
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