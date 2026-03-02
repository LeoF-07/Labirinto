import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:labirinto/maze_page.dart';
import 'package:labirinto/swipe_selector.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Offset> offsets = [
    Offset(100.h, 120.w),
    Offset(130.h, 120.w),
    Offset(160.h, 120.w),
    Offset(160.h, 150.w),
    Offset(160.h, 180.w),
    Offset(130.h, 180.w),
    Offset(100.h, 180.w),
    Offset(100.h, 210.w),
    Offset(100.h, 240.w)
  ];
  
  final List charsOfTitle = "LABIRINTO".split("");

  Stack creaStackTitolo(){
    List<Positioned> children = [];

    for(int i = 0; i < charsOfTitle.length; i++){
      children.add(
        Positioned(
          top: offsets[i].dx,
          left: offsets[i].dy,
          child: Text(charsOfTitle[i], style: TextStyle(fontSize: 20.w)),
        )
      );
    }

    Stack stack = Stack(
      children: children,
    );
    return stack;
  }

  void startGame(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => MazePage()));
  }

  @override
  Widget build(BuildContext context) {
    Stack titolo = creaStackTitolo();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 300.h,
              margin: EdgeInsets.only(bottom: 30.h),
              child: titolo,
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(padding: EdgeInsets.only(bottom: 10.h), child: Text("Difficoltà", style: TextStyle(fontSize: 15.w))),
            ),
            SwipeSelector(),
            SizedBox(height: 200.h),
            ElevatedButton(
              onPressed: startGame,
              child: Text("Inizia Partita"),
            )
          ],
        )
      ),
    );
  }
}